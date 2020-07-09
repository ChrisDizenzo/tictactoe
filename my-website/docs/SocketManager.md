---
id: SocketManager
title: SocketManager
---

The socket Manager handles the sends and recieves over the socket. Each socket recieve posts a notification to be handled by the corresponding view controller that requires the data so all data is updated in realtime.

## socketManager Recieves: 

| Namespace                     |      data                 |
| ----------------------------- | :-----------:             |
| newRooms                      |   [rooms]                 |
| joinedRoom                    |   {name: Int, success: Bool, gameBoard: [Int]}               |
| grantWin                      |   (None)                  |
| grantLoss                     |   (None)                  |
| madeMove                      |   (Int,Int,[Int])         |
| calledReset                   |   (Int)                   |
| gameReset                     |   (None)                  |
| sendChat                      |   (String)                |

## socketManager Emits: 

| Namespace                     |      data                 |
| ----------------------------- | :-----------:             |
| joinRoom                      |   (Int)                   |
| createRoom                    |   (String,String)         |
| makeMove                      |   (Int,String)            |
| callReset                     |   (Int)                   |
| sendChat                      |   (String)                |

