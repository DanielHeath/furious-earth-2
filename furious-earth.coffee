_ = require('underscore')

# Game IDs
firstId = 1
nextId = ->
  firstId++

# Storing games privately
allGames = []

# Constants (as percentage of playing field)
TickDuration = 25

module.exports = class Game

  @find: (id, salt) ->
    # in development mode, always serve up a game after a refresh.
    if allGames[id]?.salt is salt
      allGames[id]
    else
      new Game()

  constructor: () ->
    @_players = {}
    @numPlayers = 0
    @_playerColors = ["red", "blue", "yellow", "green"]
    @_startPositions = [[10, 10], [90, 90], [90, 10], [10, 90]]
    @id = nextId()
    @salt = "#{ Math.floor(Math.random()*10000001) }"
    allGames[@id] = @

    @updatePlayersInterval = setInterval(@tick, TickDuration)

  sockets: ->
    player.socket for sid, player of @_players

  players: ->
    player for sid, player of @_players

  tick: =>
    players = @players()
    for player in players
      player.accellerate()
    for player in players
      player.collideWithWalls()

    while player = players.pop()
      player.collideWithPlayers(players)

    @sendGameState()

  sendGameState: ->
    for socket in @sockets()
      socket.volatile.emit("gstate", @gameState())

  playerConnected: (socket) ->
    @_players[socket.id] = new Player(
      socket: socket
      color: @_playerColors[@numPlayers]
      position: @_startPositions[@numPlayers]
      game: this
    )
    @numPlayers++

  playerInput: (socket, keys) ->
    @_players[socket.id].keysPressed(keys)

  gameState: ->
    {
      tickDuration: TickDuration
      players: player.state() for sid, player of @_players
    }

Player = require './furious-earth/player'