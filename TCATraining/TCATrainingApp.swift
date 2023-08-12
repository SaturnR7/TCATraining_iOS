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
    static let counterStore = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    static let contactsStore = Store(initialState: ContactsFeature.State()) {
        ContactsFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
//            CounterView(store: TCATrainingApp.counterStore)
            ContactView(store: TCATrainingApp.contactsStore)
        }
    }
}
