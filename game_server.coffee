sio = require("socket.io")
Game = require './game'

exports.listen = (app, Game) ->
  io = sio.listen(app)

  io.sockets.on "connection", (socket) ->

    socket.on "keys", (keys) ->
      io.sockets.volatile.emit "gstate", keys
