
# Game IDs
firstId = 1
nextId = ->
  firstId++

# Storing games privately
allGames = []

# Constants (as percentage of playing field)
ShipRadius = 5
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

  tick: =>

    for sid, player of @_players
      player.tick()

    @sendGameState()

  sendGameState: ->
    for socket in @sockets()
      socket.volatile.emit("gstate", @gameState())

  playerConnected: (socket) ->
    @_players[socket.id] = new Player(
      socket: socket
      color: @_playerColors[@numPlayers]
      position: @_startPositions[@numPlayers]
    )
    @numPlayers++

  playerInput: (socket, keys) ->
    @_players[socket.id].keysPressed(keys)

  gameState: ->
    {
      tickDuration: TickDuration
      players: player.state() for sid, player of @_players
    }

class Player
  constructor: (opts) ->
    @keys = []
    @socket = opts.socket
    @color = opts.color
    [@px, @py] = opts.position
    @dx = @dy = 0
    @health = 100 # Everything in percentages keeps it classy

  keysPressed: (@keys) ->

  tick: ->
    @dy -= 0.3 if "up" in @keys
    @dy += 0.3 if "down" in @keys
    @dx += 0.3 if "right" in @keys
    @dx -= 0.3 if "left" in @keys

    @px += @dx
    @py += @dy

  state: ->
    {
      color: @color
      health: @health
      px: @px
      py: @py
      radius: ShipRadius
    }
