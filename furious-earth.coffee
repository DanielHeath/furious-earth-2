firstId = 1
nextId = ->
  firstId++

allGames = []

module.exports = class Game

  @find: (id, salt) ->
    allGames[id] if allGames[id]?.salt is salt

  constructor: () ->
    @players = []
    @id = nextId()
    @salt = "#{ Math.floor(Math.random()*10000001) }"
    allGames[@id] = @

  addPlayer: (playerName) ->
    if @full()
      return false
    @players.push(playerName)

  full: ->
    @players.length > 2
