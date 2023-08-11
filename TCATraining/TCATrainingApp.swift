//
//  TCATrainingApp.swift
//  TCATraining
//
//  Created by Hidemasa Kobayashi on 2023/08/11.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCATrainingApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            CounterView(store: TCATrainingApp.store)
        }
    }
}
