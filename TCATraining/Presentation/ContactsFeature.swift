//
//  ContactsFeature.swift
//  TCATraining
//
//  Created by Hidemasa Kobayashi on 2023/08/12.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name : String
}

struct ContactsFeature: Reducer {
    struct State: Equatable {
        var contacts: IdentifiedArrayOf<Contact> = []
        @PresentationState var destination: Destination.State?
    }

    enum Action: Equatable {
        case addButtonTapped
        case deleteButtonTapped(id: Contact.ID)
        case destination(PresentationAction<Destination.Action>)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .addContact(
                  AddContactFeature.State(
                    contact: Contact(id: self.uuid(), name: "")
                ))
                return .none
            case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
                state.contacts.append(contact)
                return .none
            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                state.contacts.remove(id: id)
                return .none
            case .destination:
                return .none
            case let .deleteButtonTapped(id: id):
                state.destination = .alert(.deleteConfirmation(id: id))
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension ContactsFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case addContact(AddContactFeature.State)
            case alert(AlertState<ContactsFeature.Action.Alert>)
        }

        enum Action: Equatable {
            case addContact(AddContactFeature.Action)
            case alert(ContactsFeature.Action.Alert)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.addContact, action: /Action.addContact) {
                AddContactFeature()
            }
        }
    }
}

extension AlertState where Action == ContactsFeature.Action.Alert {
    static func deleteConfirmation(id: UUID) -> Self {
        Self {
            TextState("Are you sure?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                TextState("Delete")
            }
        }
    }
}

struct ContactView: View {
    let store: StoreOf<ContactsFeature>

    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: \.contacts) { viewStore in
                List {
                    ForEach(viewStore.state) { contact in
                        HStack {
                            Text(contact.name)
                            Spacer()
                            Button {
                                viewStore.send(.deleteButtonTapped(id: contact.id))
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        Text(contact.name)
                    }
                }
                .navigationTitle("Contacts")
                .toolbar {
                    Button {
                        viewStore.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(
            store: self.store.scope(state: \.$destination, action: { .destination($0) }),
            state: /ContactsFeature.Destination.State.addContact,
            action: ContactsFeature.Destination.Action.addContact
        ) { addContactStore in
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
        .alert(
            store: self.store.scope(state: \.$destination, action: { .destination($0) }),
            state: /ContactsFeature.Destination.State.alert,
            action: ContactsFeature.Destination.Action.alert
        )
    }
}

//struct ContactViewPreview: PreviewProvider {
//  static var previews: some View {
//    ContactView(
//      store: Store(initialState: ContactsFeature.State()) {
//        ContactsFeature()
//      }
//    )
//  }
//}
