//
//  ListStore.swift
//  Listr
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

/**
 NOTE: This employs UserDefaults to save potentially large amounts of data,
 in a real app, you wouldn't want to do this, but store your data directly on
 the filesystem or use some sort of database like CoreData.
 */

import Foundation
import os.log

final class ListStore: ObservableObject {

    private let log = OSLog(subsystem: "Listr", category: String(describing: ListStore.self))

    @Published fileprivate(set) var items: [ListItem] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        load()
    }

    private let defaultsKey = "listItems"

    private func load() {
        guard let data = defaults.data(forKey: defaultsKey) else { return }

        do {
            items = try PropertyListDecoder().decode([ListItem].self, from: data)
        } catch {
            os_log("Failed to decode list items from user defaults: %{public}@", log: self.log, type: .error, String(describing: error))
        }
    }

    private func save() {
        do {
            let data = try PropertyListEncoder().encode(items)

            defaults.set(data, forKey: defaultsKey)
        } catch {
            os_log("Failed to encode list items for saving: %{public}@", log: self.log, type: .error, String(describing: error))
        }
    }

    func toggleDone(for item: ListItem) {
        guard let idx = items.firstIndex(of: item) else { return }

        var mutableItem = item
        mutableItem.done.toggle()
        items[idx] = mutableItem

        save()
    }

    func addItem(with title: String) {
        let item = ListItem(id: UUID(), title: title, done: false)
        items.append(item)

        save()
    }

    #if DEBUG
    func dump() throws -> Data {
        try PropertyListEncoder().encode(items)
    }

    func replace(with data: Data) throws {
        items = try PropertyListDecoder().decode([ListItem].self, from: data)
    }
    #endif

}

extension ListStore {

    static let mockStore: ListStore = {
        let s = ListStore()
        s.items = [
            ListItem(id: UUID(), title: "Item 1", done: false),
            ListItem(id: UUID(), title: "Item 2", done: true),
            ListItem(id: UUID(), title: "Item 3", done: false)
        ]
        return s
    }()

}
