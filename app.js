const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io')(server);
var usernames = [];

app.use(express.static(__dirname + '/public'));

server.listen(process.env.PORT || 8080);

app.get('/', function(req, res){
    res.sendFile(__dirname + '/index.html');
});

io.sockets.on('connection', function(socket){
    socket.on('new user', function(data, callback){
        if(usernames.indexOf(data) != -1){
            callback(false)
        } else {
            callback(true)
            socket.username = data;
            usernames.push(socket.username);
            updateUsernames();
        }
    });

    function updateUsernames(){
        io.sockets.emit('usernames', usernames);
    }

    socket.on('send message', function(data){
        io.sockets.emit('new message',{msg: data, user: socket.username});
    });

    // on disconnect

    socket.on('disconnect', function(data){
        if(!socket.username) return;
        usernames.splice(usernames.indexOf(socket.username), 1);
        updateUsernames();
    });
});