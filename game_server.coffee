sio = require("socket.io")

gameFromUrl = (Game, url) ->
  urlParts = url.split("/")
  gameId = urlParts[urlParts.length - 2]
  gameSalt = urlParts[urlParts.length - 1]
  Game.find gameId, gameSalt

exports.listen = (app, Game) ->

  io = sio.listen(app)

  io.sockets.on "connection", (socket) ->
    socket.game = gameFromUrl(Game, socket.handshake.headers.referer)
    socket.game.playerConnected(socket)

    socket.game.sendGameState()

    socket.on "keys", (keys) ->
      return unless @game
      @game.playerInput(@, keys)
      @game.sendGameState()

