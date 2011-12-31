sio = require("socket.io")

exports.listen = (app) ->

  io = sio.listen(app)
  nicknames = {}
  io.sockets.on "connection", (socket) ->
    socket.on "user message", (msg) ->
      socket.broadcast.emit "user message", socket.nickname, msg

    socket.on "nickname", (nick, fn) ->
      if nicknames[nick]
        fn true
      else
        fn false
        nicknames[nick] = socket.nickname = nick
        socket.broadcast.emit "announcement", nick + " connected"
        io.sockets.emit "nicknames", nicknames

    socket.on "disconnect", ->
      return  unless socket.nickname
      delete nicknames[socket.nickname]

      socket.broadcast.emit "announcement", socket.nickname + " disconnected"
      socket.broadcast.emit "nicknames", nicknames
