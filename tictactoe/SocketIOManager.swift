//
//  SocketIOManager.swift
//  tictactoe
//
//  Created by DiZenzo on 7/4/20.
//  Copyright © 2020 DiZenzo. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    
    var manager : SocketManager
    var socket : SocketIOClient
    
    override init() {
        super.init()
        self.manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
    }
    
    func connect(){
        socket.connect()
    }
    
    func close(){
        socket.disconnect()
    }
}
