
# Game IDs
firstId = 1
nextId = ->
  firstId++

# Storing games privately
allGames = []

# Constants (as percentage of playing field)
ShipRadius = 5

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
      players: player.state() for sid, player of @_players
    }



class Player
  constructor: (opts) ->
    @socket = opts.socket
    @color = opts.color
    [@px, @py] = opts.position
    @health = 100 # Everything in percentages keeps it classy

  keysPressed: (keys) ->

  state: ->
    {
      color: @color
      health: @health
      px: @px
      py: @py
    }
