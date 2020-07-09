const port = 4040

// Use this if localhost
//const host = '127.0.0.1'

// This is the host machine ip
const host = '172.6.249.239'

const express = require('express')
const app = express()
const server = require('http').Server(app)
const io = require('socket.io')(server)

app.use(express.json())

server.listen(port)
console.log("listening on: " +host + ":" + port)

// Rooms stores objects for each room, each of datatype similar to room.swift
var rooms = []

// This stores the reference of the id of the room, to the index in the room array
// This was used to ensure consistency in joining the socket rooms, and ensuring no user got their room id changed while in the room 
var idToRoom = {}

// Stores the players' roles for each socket
// player 0 = spectator
// player 1 = X
// player 2 = O
// Ensuring no user with a different role can make moves
var socketsRoles = {}

// Server check if running
app.get('/', (req,res) =>{
    res.send('<h1> Hello world </h1>')
})

io.on('connection', (socket) =>{
    console.log("user connected")

    socket.join(0)
    socket.emit("newRooms", rooms)
    socketsRoles[socket.id] = 0

    // Handles when a player disconnects
    // Grant win to other player if they are in a gameroom, if in a room alone then delete the room
    socket.on('disconnect', function(){
        console.log("user disconnected")
        if (socket.room != undefined & socket.room != 0){
            rooms[idToRoom[socket.room]].occupancy-=1
                socket.broadcast.to(socket.room).emit("grantWin")
            if (rooms[idToRoom[socket.room]].occupancy == 0){
                removeRoom(socket.room)
            }
        }
    })

    // Handles the player making moves, checks roles, gameState for wins and draws, and sends moves to all players in the room
    socket.on("playerMove" , (move,player)=>{
        if (rooms[idToRoom[socket.room]].turn == player && rooms[idToRoom[socket.room]].gameBoard[move] == 0){
            socket.broadcast.to(socket.room).emit("madeMove", move,player)    
            rooms[idToRoom[socket.room]].gameBoard[move] = player
            rooms[idToRoom[socket.room]].turn = (rooms[idToRoom[socket.room]].turn == 2) ? 1:2


            if (checkBoardForWin(rooms[idToRoom[socket.room]].gameBoard)){
                socket.emit("grantWin")
                socket.broadcast.to(socket.room).emit("grantLoss")
                rooms[idToRoom[socket.room]].turn = 0
            } else if (checkBoardForTie(rooms[idToRoom[socket.room]].gameBoard)){
                socket.emit("grantLoss")
                socket.broadcast.to(socket.room).emit("grantLoss")
                rooms[idToRoom[socket.room]].turn = 0
            }
            socket.emit("madeMove", move, player)   
        }
    })
    
    // Handles the creating of a room
    // Makes new data for room, pushes the id to idToRoom, adds to rooms array, sends new rooms array
    // Currently it is sending the entire array whenever a new room is made, this isnt efficient but the redundancy ensures consistency across clients
    socket.on("createRoom", (title,host)=>{
        console.log("No idea what this is gonna be: " + title + " or this? " + host)
        var newID = makeid()
        var temp = {
            id: newID,
            title: title,
            host: host,
            occupancy: 0,
            turn: 1,
            gameBoard: createGameBoard(),
            reset: 0
        }
        idToRoom[newID] = rooms.length
        rooms.push(temp)
        
        io.sockets.emit("newRooms", getSend())
    })

    // Handles sending of chats
    socket.on("sendChat", (chat) =>{
        socket.broadcast.to(socket.room).emit("sendChat",chat)
        socket.emit("sendChat",chat)
    })

    // Handles joining a room
    socket.on("joinRoom", (id)=>{
        console.log("Joining room: " + id + " leaving " + socket.room )
        var out = {success: false, player: 0}

        // Break out if they are already in the room they want to join
        if (socket.room == id) {return}
        try{
            // Check if they are leaving a room, if so then reduce occupancy and change player roles, possibly delete the room if empty
            if (socket.room != undefined & socket.room != 0){
                rooms[idToRoom[socket.room]].occupancy-=1
                socket.broadcast.to(socket.room).emit("grantWin")
                if (rooms[idToRoom[socket.room]].occupancy == 0){
                    removeRoom(socket.room)
                }
                socketsRoles[socket.id] = 0
            }
            socket.leave(socket.room)

            // When joining a room a new player role must be assigned, this is handled by a seperate function getPlayerFromRoom()
            socket.join(id)
            socket.room = id
            rooms[idToRoom[id]].occupancy += 1
            out.gameBoard = rooms[idToRoom[id]].gameBoard
            if (rooms[idToRoom[id]].occupancy <= 2){
                out.player = getPlayerFromRoom(id)
                socketsRoles[socket.id] = getPlayerFromRoom(id)
            }
            
            out.success = true

        }catch (except){
            console.log("I broke on joining room")
            console.log(except)
        }
        // Returns the out, and the out object returns whether joining the room was successful or not, which is helpful for client consistency and debugging
        socket.emit("joinedRoom", out)
        io.sockets.emit("newRooms", getSend())
        
    })

    // Handler for the rematch button
    // If the player has already clicked the button then the player unselects rematch 
    // If two players want a rematch then they are able to rematch
    socket.on("callReset",(player)=>{
        switch (rooms[idToRoom[socket.room]].reset) {
            case 0:
                rooms[idToRoom[socket.room]].reset = player
                socket.broadcast.to(socket.room).emit("calledReset",rooms[idToRoom[socket.room]].reset)
                socket.emit("calledReset",rooms[idToRoom[socket.room]].reset)
                break;
            case player:
                rooms[idToRoom[socket.room]].reset = 0
                socket.broadcast.to(socket.room).emit("calledReset",rooms[idToRoom[socket.room]].reset)
                socket.emit("calledReset",rooms[idToRoom[socket.room]].reset)
                break;
            default:
                rooms[idToRoom[socket.room]].gameBoard = createGameBoard()
                rooms[idToRoom[socket.room]].turn = 1
                rooms[idToRoom[socket.room]].reset = 0
                socket.broadcast.to(socket.room).emit("gameReset")
                socket.emit("gameReset")
                break;
        }
    })

    

})

// This function removes a room give the id
// First must remove the room from the array, and change all the references in the idToRoom object to correctly point to the new array objects
function removeRoom(id){
    console.log(JSON.stringify(idToRoom))
    Object.keys(idToRoom).forEach((key) =>{
        if (idToRoom[key] > idToRoom[id]){
            idToRoom[key] -= 1
        }
    })
    console.log("LOOOOOOKINGG FORRR ID: " + id)
    rooms.splice(idToRoom[id],1)
    delete idToRoom[id]
    console.log(JSON.stringify(idToRoom))
    console.log(rooms)
}

// Just a simple getter for all the rooms, but excludes data the client doesn't yet need
function getSend(){
    var outArr = []
    for (i = 0; i < rooms.length; i++){
        outArr.push({
            id: rooms[i].id,
            title: rooms[i].title,
            host: rooms[i].host,
            occupancy: rooms[i].occupancy,
        })
    }
    return outArr
}

// Generates a player role for a room of id
// Must loop through every socket in the room, determine their ids, and make a role decision based on the roles of the users in the room
// Returns int 0,1,2 depending on player role in room
function getPlayerFromRoom(id){
    var clients = io.sockets.adapter.rooms[id]
    var clientKeys = Object.keys(clients.sockets)
    var isPlayer1 = false
    var isPlayer2 = false
    console.log("getting player from room: " + JSON.stringify(clients))
    console.log(clientKeys)
    for (i = 0; i < clientKeys.length; i++){
        console.log(socketsRoles[clientKeys[i]])
        if (socketsRoles[clientKeys[i]] == 1){
            isPlayer1 = true
        }else if (socketsRoles[clientKeys[i]] == 2){
            isPlayer2 = true
        }
    }
    console.log((isPlayer1,isPlayer2))
    if (!isPlayer1){
        return 1
    }else if (!isPlayer2){
        return 2
    }else {
        return 0
    }
}

// Simple function that checks board for win.
// Returns boolean
function checkBoardForWin(board){
    // Okay I know this is a little hardcoded but I'm not in numpy and this is a pretty fast solution both to write and to execute

    let wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
    
    for (i = 0; i < wins.length; i++){
        if (board[wins[i][0]] != 0 && board[wins[i][0]] == board[wins[i][1]] && board[wins[i][1]] == board[wins[i][2]]){
            return true
        }
    }
    return false
}

// Checks for a tie 
// returns boolean
function checkBoardForTie(board){
    if (board.includes(0)){
        return false
    }
    return true
}

// Just consistend makeid function for random id
function makeid() {
    return Math.floor(Math.random()*100000);
 }

// simple function to return an empty gameboard
function createGameBoard(){
     return [0,0,0,0,0,0,0,0,0]
}
 
