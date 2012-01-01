module.exports = class Game
  constructor: (@name) ->
    @players = []

  addPlayer: (playerName) ->
    if @full()
      return false
    @players.push(playerName)

  full: ->
    @players.length > 2