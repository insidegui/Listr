//
//  CLIReceiver.swift
//  Listr
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

#if DEBUG

import UIKit
import MultipeerKit

final class CLIReceiver {

    private var app: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    static let serviceType = "listrctl"

    private lazy var transceiver: MultipeerTransceiver = {
        var config = MultipeerConfiguration.default

        config.serviceType = Self.serviceType

        return MultipeerTransceiver(configuration: config)
    }()

    func start() {
        transceiver.receive(AddItemCommand.self, using: response(handleAddItem))
        transceiver.receive(ListItemsCommand.self, using: response(handleListItems))
        transceiver.receive(DumpDatabaseCommand.self, using: response(handleDumpDatabase))
        transceiver.receive(ReplaceDatabaseCommand.self, using: response(handleReplaceDatabase))

        transceiver.resume()
    }

    private func response<T: Codable>(_ handler: @escaping (T) -> CLIResponse) -> (T) -> Void {
        return { [weak self] (command: T) in
            let result = handler(command)

            self?.transceiver.broadcast(result)
        }
    }

    private func handleAddItem(_ command: AddItemCommand) -> CLIResponse {
        app.store.addItem(with: command.title)

        return .empty
    }

    private func handleListItems(_ command: ListItemsCommand) -> CLIResponse {
        let list = app.store.items.map { item in
            "\(item.done ? "[✓]" : "[ ]" ) \(item.title)"
        }.joined(separator: "\n")

        return .message(list)
    }

    private func handleDumpDatabase(_ command: DumpDatabaseCommand) -> CLIResponse {
        do {
            return .data(try app.store.dump())
        } catch {
            return .message("Failed to dump store: \(error)")
        }
    }


    private func handleReplaceDatabase(_ command: ReplaceDatabaseCommand) -> CLIResponse {
        do {
            try app.store.replace(with: command.data)

            return .empty
        } catch {
            return .message("Failed to replace store: \(error)")
        }
    }

}

#endif
