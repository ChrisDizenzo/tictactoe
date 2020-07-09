//
//  socketMana.swift
//  tictactoe
//
//  Created by DiZenzo on 7/4/20.
//  Copyright © 2020 DiZenzo. All rights reserved.
//

import Foundation
import SocketIO

let serverConnection = socketManager()


/// Manages the socket connection to send data and handle data sent to phone
class socketManager {

    
    /// You can use the following sockets for debuging with local server clients
    
    //let manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:4000")!)
    //let manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:4000")!, config: [.log(true), .compress])
    
    /// The ipaddress here is the host server ip (used direct ip and not https for simplicity of implementation)
    let manager = SocketManager(socketURL: URL(string: "http://172.6.249.239:4000")!)
    var socket:SocketIOClient
    var rooms:[room] = []
    var player: Int = 0
    var gameBoard:[Int] = [0,0,0,0,0,0,0,0,0]
    var rematch = 0
    var gameOver = false
    
    init(){
        socket = manager.defaultSocket
        initializeSocketHandlers()
        socket.connect()
    }
    
    /// This function initializes the handlers for incoming messages on the socket.
    /// Handlers use NotificationCenter to call functions in other views
    func initializeSocketHandlers(){
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        /// When newRooms is called, the socket pushes an array of all the rooms and the client fills their array with the data
        socket.on("newRooms"){
            data,ack in
            let arr = data[0] as! NSArray
            var tempVal:NSDictionary
            self.rooms = []
            for val in arr {
                tempVal = val as! NSDictionary
                let temp = room(id: tempVal["id"] as! Int,
                                title: tempVal["title"] as! String,
                                host: tempVal["host"] as! String,
                                occupancy: tempVal["occupancy"] as! Int
                )
                self.rooms.append(temp)
            }
            NotificationCenter.default.post(name: Notification.Name("reload"), object: nil)
        }
        
        /// When a user joins a room they need the game board and what player type they are
        /// player 0 = spectator
        /// player 1 = X
        /// player 2 = O
        socket.on("joinedRoom"){
            data,ack in
            print("Joined room: ")
            let temp = data[0] as! NSDictionary
            self.player = temp["player"] as! Int
            if (temp["success"] as! Bool){
                self.gameBoard = temp["gameBoard"] as! [Int]
            }
            NotificationCenter.default.post(name: Notification.Name("reloadGameBoard"), object: nil)
        }
        
        /// Tells player they won, and emits change over NotificationCenter
        socket.on("grantWin"){
            data,ack in
            self.gameOver = true
            NotificationCenter.default.post(name: Notification.Name("gameWin"), object: nil)
        }
        
        /// Tells player they lost, and emits change over NotificationCenter
        socket.on("grantLoss"){
            data,ack in
            self.gameOver = true
            NotificationCenter.default.post(name: Notification.Name("gameLost"), object: nil)
        }
        
        
        /// Handles moves made, updates the gameboard, and Notifies to reload the game board
        socket.on("madeMove"){
            data,ack in
            let move = data[0] as! Int
            let player = data[1] as! Int
            self.gameBoard[move] = player
            NotificationCenter.default.post(name: Notification.Name("reloadGameBoard"), object: nil)
        }
        
        /// This DOES NOT reset the game, it notifies the client to load the rematch button and update progress view
        socket.on("calledReset"){
            data,ack in
            let _rematch = data[0] as! Int
            self.rematch = _rematch
            NotificationCenter.default.post(name: Notification.Name("reloadRematch"), object: nil)
        }
        
        /// This handles the game when it is reset to the start
        socket.on("gameReset"){
            data,ack in
            self.gameBoard = [0,0,0,0,0,0,0,0,0]
            self.gameOver = false
            NotificationCenter.default.post(name: Notification.Name("reloadGameBoard"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("removeRematch"), object: nil)
        }
        
        /// This handles the incoming messages from sent chats and calls view to make text box passing object through userInfo of the chat text
        socket.on("sendChat"){
            data,ack in
            let chat = data[0] as! String
            let userInfo : [String: String] = [ "chat" : chat ]
            NotificationCenter.default.post(name: Notification.Name("showChat"), object: nil, userInfo: userInfo)
            
        }
    }
    
    /// Emit on socket to join room of index
    ///
    /// - parameter row: index of  row to join
    func joinRoom(row:Int){
        socket.emit("joinRoom", rooms[row].id)
    }
    
    /// Emit on socket to create new Room
    ///
    /// - parameter title: Desired name of the room
    /// - parameter host: Desired hostname of the room (not implemented yet)
    func createRoom(title:String,host: String){
        socket.emit("createRoom", title, host)
    }
    
    /// Emit on socket to make a move
    ///
    /// - parameter move: index of the move on the gameboard array
    func makeMove(move: Int){
        socket.emit("playerMove" , move, self.player)
    }
    
    /// Emit on socket to reset the game
    func callReset(){
        socket.emit("callReset", player)
    }
    
    /// Emit on socket to join room of index
    ///
    /// - parameter chat: Desired message to send to the room
    func sendChat(chat: String){
        socket.emit("sendChat" , chat)
    }
}
