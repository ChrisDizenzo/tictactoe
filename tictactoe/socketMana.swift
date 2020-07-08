//
//  socketMana.swift
//  tictactoe
//
//  Created by DiZenzo on 7/4/20.
//  Copyright © 2020 DiZenzo. All rights reserved.
//

import Foundation
import SocketIO

let serverConn = socketMana()

class socketMana {
    
//    let manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:4000")!)
//    let manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:4000")!, config: [.log(true), .compress])
    let manager = SocketManager(socketURL: URL(string: "http://172.6.249.239:4000")!)
    var socket:SocketIOClient
    var rooms:[room]
    var player: Int = 0
    var gameBoard:[Int] = [0,0,0,0,0,0,0,0,0]
    var rematch = 0
    var gameOver = false
    
    init(){
        socket = manager.defaultSocket
        rooms = []
        initializeSocketHandlers()
        socket.connect()
    }
    
    func initializeSocketHandlers(){
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
               
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
        
        socket.on("grantWin"){
            data,ack in
            self.gameOver = true
            NotificationCenter.default.post(name: Notification.Name("gameWin"), object: nil)
        }
        
        socket.on("grantLoss"){
            data,ack in
            self.gameOver = true
            NotificationCenter.default.post(name: Notification.Name("gameLost"), object: nil)
        }
        
        socket.on("madeMove"){
            data,ack in
            let move = data[0] as! Int
            let player = data[1] as! Int
            self.gameBoard[move] = player
            NotificationCenter.default.post(name: Notification.Name("reloadGameBoard"), object: nil)
        }
        
        socket.on("calledReset"){
            data,ack in
            let _rematch = data[0] as! Int
            self.rematch = _rematch
            NotificationCenter.default.post(name: Notification.Name("reloadRematch"), object: nil)
        }
        
        socket.on("gameReset"){
            data,ack in
            self.gameBoard = [0,0,0,0,0,0,0,0,0]
            self.gameOver = false
            NotificationCenter.default.post(name: Notification.Name("reloadGameBoard"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("removeRematch"), object: nil)
        }
        
        socket.on("sendChat"){
            data,ack in
            let chat = data[0] as! String
            let userInfo : [String: String] = [ "chat" : chat ]
            NotificationCenter.default.post(name: Notification.Name("showChat"), object: nil, userInfo: userInfo)
            
        }
    }
    
    func joinRoom(row:Int){
        socket.emit("joinRoom", rooms[row].id)
    }
    
    func createRoom(title:String,host: String){
        serverConn.socket.emit("createRoom", title, host)
    }
    
    func makeMove(move: Int){
        socket.emit("playerMove" , move, self.player)
    }
    
    func callReset(){
        socket.emit("callReset", player)
    }
    
    func sendChat(chat: String){
        socket.emit("sendChat" , chat)
    }
}
extension Notification.Name {
    public static let myNotificationKey = Notification.Name(rawValue: "myNotificationKey")
}
