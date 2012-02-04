ShipRadius = 5

module.exports = class Player
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


  state: ->
    {
      color: @color
      health: @health
      px: @px
      py: @py
      radius: ShipRadius
    }
