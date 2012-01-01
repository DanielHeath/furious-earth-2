sio = require("socket.io")
Game = require './game'

exports.listen = (app) ->
  io = sio.listen(app)
  nicknames = {}
  games = {}

  io.sockets.on "connection", (socket) ->

    socket.on "user message", (msg) ->
      socket.broadcast.emit "user message", socket.nickname, msg

    socket.on "join", (nick, gameName, fn) ->
      game = games[gameName] ?= new Game(gameName)
      if game.full()
        console.log "Game is full"
        fn("#gamename-err")
      else if nicknames[nick]
        fn("#nickname-err")
      else
        fn(false)
        nicknames[nick] = socket.nickname = nick
        socket.broadcast.emit "announcement", "#{nick} joined game #{game.name}"
        io.sockets.emit "nicknames", nicknames

    socket.on "disconnect", ->
      return  unless socket.nickname
      delete nicknames[socket.nickname]

      socket.broadcast.emit "announcement", socket.nickname + " disconnected"
      socket.broadcast.emit "nicknames", nicknames
