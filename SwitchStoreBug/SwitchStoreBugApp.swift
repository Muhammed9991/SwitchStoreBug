//
//  SwitchStoreBugApp.swift
//  SwitchStoreBug
//
//  Created by Muhammed Mahmood on 09/11/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct SwitchStoreBugApp: App {
    var body: some Scene {
        WindowGroup {
            ParentView(store: Store(initialState: ParentFeature.State()){
                ParentFeature()
            })
        }
    }
}
