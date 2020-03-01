//
//  ContentView.swift
//  Listr
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import SwiftUI

struct AddView: View {

    @EnvironmentObject var store: ListStore

    @State private var title = ""

    var onDone: () -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Item title", text: $title)
            }
            .navigationBarTitle("Add Item")
            .navigationBarItems(
                leading: Button(action: cancel, label: { Text("Cancel") }),
                trailing: Button(action: save, label: { Text("Done") })
            )
        }
    }

    private func save() {
        store.addItem(with: title)

        onDone()
    }

    private func cancel() {
        onDone()
    }

}

struct ContentView: View {
    @EnvironmentObject var store: ListStore

    @State private var showingAddView = false

    private let feedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        NavigationView {
            List {
                ForEach(store.items) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        if item.done { Image(systemName: "checkmark") }
                    }.contentShape(Rectangle()).onTapGesture {
                        self.store.toggleDone(for: item)
                        self.feedback.impactOccurred()
                    }
                }
            }
            .navigationBarTitle("Todo")
            .navigationBarItems(trailing:
                Button(action: add, label: { Text("Add") }).contentShape(Rectangle())
            )
        }.sheet(isPresented: $showingAddView, content: {
            AddView(onDone: self.hideAddView).environmentObject(self.store)
        })
    }

    private func add() {
        showingAddView.toggle()
    }

    private func hideAddView() {
        showingAddView = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ListStore.mockStore)
    }
}
