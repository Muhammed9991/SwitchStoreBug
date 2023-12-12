import SwiftUI
import ComposableArchitecture

struct ParentView: View {
    @Bindable var store: StoreOf<ParentFeature>
    var body: some View {
        VStack {
            
            if let childStore = self.store.scope(state: \.content, action: \.content) {
                switch childStore.state {
                case .red:
                    if let store = childStore.scope(state: \.red, action: \.red) {
                        RedView(store: store)
                    }
                case .blue:
                    if let store = childStore.scope(state: \.blue, action: \.blue) {
                        BlueView(store: store)
                    }
                }
            }
            
            Button {
                self.store.send(.onButtonTapped)
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
        .onChange(of: self.store.buttonState) { _, _ in
            self.store.send(.updateContent)
        }
    }
}

@Reducer
struct ParentFeature {
    @ObservableState
    struct State: Equatable, Sendable {
        var buttonState: Bool = true
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
        .ifLet(\.content, action: \.content) {
            ChildFeature()
        }
    }
}

@Reducer
struct ChildFeature {
    @ObservableState
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
        VStack {
            Text("RedView")
            
            if let text = self.store.text {
                Text(text)
            }
            
        }
        .task {
            print("RedView onAppear")
            self.store.send(.onAppear)
        }
        
    }
}

@Reducer
struct RedFeature {
    @ObservableState
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
        VStack {
            Text("BlueView")
            
            if let text = self.store.text {
                Text(text)
            }
        }
        .task {
            print("BlueView onAppear")
            self.store.send(.onAppear)
        }
    }
}

@Reducer
struct BlueFeature {
    @ObservableState
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
