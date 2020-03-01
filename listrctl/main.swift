//
//  main.swift
//  listrctl
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import ArgumentParser

CLITransmitter.current.start()

struct ListrCTL: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "listrctl",
        abstract: "Interfaces with Listr running on a device or simulator.",
        subcommands: [
            Item.self,
            Store.self
    ])

    struct Item: ParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "item",
            abstract: "Commands for manipulating items.",
            subcommands: [
                List.self,
                Add.self
        ])

        struct List: ParsableCommand {

            static let configuration = CommandConfiguration(
                commandName: "list",
                abstract: "Lists all items."
            )

            func run() throws {
                send(ListItemsCommand())
            }

        }

        struct Add: ParsableCommand {

            static let configuration = CommandConfiguration(
                commandName: "add",
                abstract: "Adds an item with the specified title."
            )

            @Argument(help: "The title for the new item.")
            var title: String

            func run() throws {
                send(AddItemCommand(title: title))
            }

        }

    }

    struct Store: ParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "store",
            abstract: "Manipulate the data store.",
            subcommands: [
                Dump.self,
                Replace.self
            ]
        )

        struct Dump: ParsableCommand {

            static let configuration = CommandConfiguration(
                commandName: "dump",
                abstract: "Dumps the contents of the store as a property list."
            )

            @Argument(help: "The output path.")
            var path: String

            func run() throws {
                CLITransmitter.current.outputPath = path

                send(DumpDatabaseCommand())
            }

        }

        struct Replace: ParsableCommand {

            static let configuration = CommandConfiguration(
                commandName: "replace",
                abstract: "Replaces the contents of the store with the contents from the specified property list."
            )

            @Argument(help: "The path to the store property list.")
            var path: String

            func run() throws {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))

                send(ReplaceDatabaseCommand(data: data))
            }

        }

    }

}

ListrCTL.main()
