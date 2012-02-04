ShipRadius = 5

module.exports = class Player
  constructor: (opts) ->
    @game = opts.game
    @socket = opts.socket
    @color = opts.color
    [@px, @py] = opts.position
    @dx = @dy = 0
    @health = 100 # Everything in percentages keeps it classy
    @keys = []

  keysPressed: (@keys) ->

  accellerate: ->
    # Thrusters on
    @dy -= 0.3 if "up" in @keys
    @dy += 0.3 if "down" in @keys
    @dx += 0.3 if "right" in @keys
    @dx -= 0.3 if "left" in @keys

    @px += @dx
    @py += @dy

  collideWithWalls: ->
    # Bouncing off the walls
    if @px > 100 - ShipRadius
      @dx = 0 - Math.abs(@dx)
      @px = 100 - ShipRadius

    if @px < 0 + ShipRadius
      @dx = Math.abs(@dx)
      @px = ShipRadius

    if @py > 100 - ShipRadius
      @dy = 0 - Math.abs(@dy)
      @py = 100 - ShipRadius

    if @py < 0 + ShipRadius
      @dy = Math.abs(@dy)
      @py = ShipRadius


  _distanceBetween: (px1, py1, px2, py2) ->
    dx = Math.abs(px1 - px2)
    dy = Math.abs(py1 - py2)
    Math.floor(Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2)))

  _distanceTo: (other) ->
    @_distanceBetween(@px, @py, other.px, other.py)

  collideWithPlayers: (players) ->
    # Bouncing off the other ships

    for other in players
      if @_distanceTo(other) < (ShipRadius + ShipRadius)
        [@dx, @dy, other.dx, other.dy] = [other.dx, other.dy, @dx, @dy]

  state: ->
    {
      color: @color
      health: @health
      px: @px
      py: @py
      radius: ShipRadius
    }
