//
//  ListItem.swift
//  Listr
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation

struct ListItem: Hashable, Codable, Identifiable {
    let id: UUID
    var title: String
    var done: Bool
}
