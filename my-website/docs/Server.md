---
id: Server
title: Server.js
sidebar_label: Server.js
---

The server.js is found in the tictacServe folder. It includes the package.json for running local debuging, just be sure to change the host ip before executing the server.js

## Stored Data

1. rooms: Stores objects for each room similar to room.swift
1. idToRoom: stores object with key of room's id and value of the index in the rooms array
1. socketsRoles: Stores object with key of room's id and value of an object that stores keys of player ids and values of their player state
    - player 0 = spectator
    - player 1 = X
    - player 2 = O

## socketManager Emits: 

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

## socketManager Recieves: 

| Namespace                     |      data                 |
| ----------------------------- | :-----------:             |
| joinRoom                      |   (Int)                   |
| createRoom                    |   (String,String)         |
| makeMove                      |   (Int,String)            |
| callReset                     |   (Int)                   |
| sendChat                      |   (String)                |

## Some Additional Information
Player's moves are checked on server side to ensure proper moves are made by the proper players. 

Game wins and loses are checked serverside to ensure no tomfoolery by clients to cheat to win.

Players roles are calculated in order of first to enter room. for more information see getPlayerFromRoom(id)


