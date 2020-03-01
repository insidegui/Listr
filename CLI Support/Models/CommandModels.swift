//
//  CommandModels.swift
//  Listr
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

#if DEBUG

import Foundation

struct ListItemsCommand: Hashable, Codable { }

struct AddItemCommand: Hashable, Codable {
    let title: String
}

struct DumpDatabaseCommand: Hashable, Codable {
    
}

struct ReplaceDatabaseCommand: Hashable, Codable {
    let data: Data
}

#endif
