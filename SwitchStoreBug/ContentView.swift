import SwiftUI
import ComposableArchitecture

struct ParentView: View {
    let store: StoreOf<ParentFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                IfLetStore(self.store.scope(state: \.content, action: { .content($0) }), then: { store in
                    SwitchStore(store) { state in
                        switch state {
                        case .red:
                            CaseLet(
                                /ChildFeature.State.red,
                                action: ChildFeature.Action.red
                            ) { store in
                                RedView(store: store)
                            }
                        case .blue:
                            CaseLet(
                                /ChildFeature.State.blue,
                                action: ChildFeature.Action.blue
                            ) { store in
                                BlueView(store: store)
                            }
                        }
                    }
                })
                
                Button {
                    viewStore.send(.onButtonTapped)
                } label: {
                    VStack {
                        Text("Button")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                
            }
            .onChange(of: viewStore.buttonState) { _, _ in
                viewStore.send(.updateContent)
            }
        }
    }
}

struct ParentFeature: Reducer {
    struct State: Equatable, Sendable {
        @BindingState var buttonState: Bool = true
        var content: ChildFeature.State?
    }
    enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case content(ChildFeature.Action)
        case updateContent
        case onAppear
        case onButtonTapped
    }
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding, .content:
                return .none
                
            case .onAppear:
                state.buttonState = true
                state.content = .red(RedFeature.State())
                return .none
                
            case .updateContent:
                if state.buttonState {
                    state.content = .red(RedFeature.State())
                } else {
                    state.content = .blue(BlueFeature.State())
                }
                return .none
                
            case .onButtonTapped:
                state.buttonState.toggle()
                return .none
            }
        }
    }
}

struct ChildFeature: Reducer {
    enum State: Equatable, Sendable {
        case red(RedFeature.State)
        case blue(BlueFeature.State)
    }
    enum Action: Equatable, Sendable {
        case red(RedFeature.Action)
        case blue(BlueFeature.Action)
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .red:
                return .none
            case .blue:
                return .none
            }
        }
        .ifCaseLet(/State.red, action: /Action.red) {
            RedFeature()
        }
        .ifCaseLet(/State.blue, action: /Action.blue) {
            BlueFeature()
        }
    }
}

struct RedView: View {
    let store: StoreOf<RedFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("RedView")
                
                if let text = viewStore.text {
                    Text(text)
                }
                
            }
            .task {
                print("RedView onAppear")
                viewStore.send(.onAppear)
            }
        }
    }
}

struct RedFeature: Reducer {
        struct State: Equatable, Sendable {
            var text: String?
        }
        enum Action: Equatable, Sendable {
            case onAppear
        }
       
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {

                case .onAppear:
                    state.text = "RedView On appear ran"
                    return .none
                }
            }
        }
}

struct BlueView: View {
    let store: StoreOf<BlueFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("BlueView")
                
                if let text = viewStore.text {
                    Text(text)
                }
            }
            .task {
                print("BlueView onAppear")
                viewStore.send(.onAppear)
            }
        }
    }
}

struct BlueFeature: Reducer {
        struct State: Equatable, Sendable {
            var text: String?
        }
        enum Action: Equatable, Sendable {
            case onAppear
        }
       
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .onAppear:
                    state.text = "BlueView On appear ran"
                    return .none
                    
                }
            }
        }
}

#Preview {
    ParentView(store: Store(initialState: ParentFeature.State()){
        ParentFeature()
    })
}
