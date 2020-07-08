const port = 4040
//const host = '127.0.0.1'
const host = '172.6.249.239'

const express = require('express')
const app = express()
const server = require('http').Server(app)
const io = require('socket.io')(server)

app.use(express.json())

server.listen(port)

console.log("listening on: " +host + ":" + port)

var rooms = []
var idToRoom = {}
var socketsRoles = {}

app.get('/', (req,res) =>{
    res.send('<h1> Hello world </h1>')
})

io.on('connection', (socket) =>{
    console.log("user connected")

    socket.join(0)
    socket.emit("newRooms", rooms)
    socketsRoles[socket.id] = 0

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

    socket.on("playerMove" , (move,player)=>{
        // console.log(socket.room + " making moves")
        // console.log(player + " trying to make move: " + move)
        // console.log(rooms)
        // console.log(JSON.stringify(idToRoom))
        // console.log(rooms[idToRoom[socket.room]])
        if (rooms[idToRoom[socket.room]].turn == player && rooms[idToRoom[socket.room]].gameBoard[move] == 0){
            socket.broadcast.to(socket.room).emit("madeMove", move,player)    
            rooms[idToRoom[socket.room]].gameBoard[move] = player
            rooms[idToRoom[socket.room]].turn = (rooms[idToRoom[socket.room]].turn == 2) ? 1:2


            if (checkBoardForWin(rooms[idToRoom[socket.room]].gameBoard)){
                socket.emit("grantWin")
                socket.broadcast.to(socket.room).emit("grantLoss")
                rooms[idToRoom[socket.room]].turn = 0
            } else if (checkBoardForTie(board)){
                socket.emit("grantLoss")
                socket.broadcast.to(socket.room).emit("grantLoss")
                rooms[idToRoom[socket.room]].turn = 0
            }
            socket.emit("madeMove", move, player)   
        }
    })
    
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

    socket.on("sendChat", (chat) =>{
        socket.broadcast.to(socket.room).emit("sendChat",chat)
        socket.emit("sendChat",chat)
    })

    socket.on("joinRoom", (id)=>{
        console.log("Joining room: " + id + " leaving " + socket.room )
        var out = {success: false, player: 0}
        if (socket.room == id) {return}
        try{
            if (socket.room != undefined & socket.room != 0){
                rooms[idToRoom[socket.room]].occupancy-=1
                socket.broadcast.to(socket.room).emit("grantWin")
                if (rooms[idToRoom[socket.room]].occupancy == 0){
                    removeRoom(socket.room)
                }
                socketsRoles[socket.id] = 0
            }
            socket.leave(socket.room)

            socket.join(id)
            socket.room = id
            rooms[idToRoom[id]].occupancy += 1
            out.gameBoard = rooms[idToRoom[id]].gameBoard
            if (rooms[idToRoom[id]].occupancy <= 2){
                socketsRoles[socket.id] = getPlayerFromRoom(id)
                socketsRoles[socket.id] = getPlayerFromRoom(id)
            }
            
            out.success = true

        }catch (except){
            console.log("I broke on joining room")
            console.log(except)
        }
        socket.emit("joinedRoom", out)
        io.sockets.emit("newRooms", getSend())
        
    })

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

function getPlayerFromRoom(id){
    var clients = io.sockets.adapter.rooms[id]
    var clientKeys = Object.keys(clients.sockets)
    console.log("getting player from room: " + JSON.stringify(clients))
    console.log(clientKeys)
    for (i = 0; i < clientKeys.length; i++){
        console.log(clients.sockets[clientKeys[i]])
        console.log(socketsRoles[clientKeys[i]])
        if (socketsRoles[clientKeys[i]] == 1){
            return 2
        }else if (socketsRoles[clientKeys[i]] == 2){
            return 1
        }
    }
    return 0
}

function checkBoardForWin(board){
    let wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]

    for (i = 0; i < wins.length; i++){
        if (board[wins[i][0]] != 0 && board[wins[i][0]] == board[wins[i][1]] && board[wins[i][1]] == board[wins[i][2]]){
            return true
        }
    }
    return false
}

function checkBoardForTie(board){
    if (board.includes(0)){
        return false
    }
    return true
}

function makeid() {
    return Math.floor(Math.random()*100000);
 }

function createGameBoard(){
     return [0,0,0,0,0,0,0,0,0]
}
 
