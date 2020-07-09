//
//  room.swift
//  tictactoe
//
//  Created by DiZenzo on 7/4/20.
//  Copyright © 2020 DiZenzo. All rights reserved.
//

import Foundation

/// Stores a room with its information for the table view data source
struct room: Codable,Hashable,Identifiable {
    var id:    Int
    var title: String
    var host:  String
    var occupancy:  Int
    
}
