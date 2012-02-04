
class FuriousEarth

  class Socket extends Backbone.Model
    constructor: ->
      @socket = io.connect()
      @socket.on "connect", => @trigger("connect")
      @socket.on "reconnect", => @trigger('reconnect')
      @socket.on "reconnecting", => @trigger('reconnecting')
      @socket.on "error", (e) => @trigger('error', e)
      @socket.on "gstate", (state) =>
        @trigger('change:state', state)

    sendKeys: (keys) ->
      @socket.emit("keys", keys)

  @socket: new Socket()

$ ->
  height = document.body.clientHeight
  width = document.body.clientWidth
  validKeys = ["up", "down", "left", "right", "ctrl"]

  onKeysChanged = (e) ->
    e.preventDefault()
    FuriousEarth.socket.sendKeys _.intersection(validKeys, KeyboardJS.activeKeys())

  for key in validKeys
    KeyboardJS.bind.key key, onKeysChanged, onKeysChanged

  window.paper = r = Raphael "canvas", width, height

  FuriousEarth.socket.bind 'change:state', (state) ->
    r.clear()
    for player in state.players

      console.log "Drawing #{player.color} player at #{player.px * width / 100}, #{player.py * height / 100}"
      r.ellipse(
        Math.floor(player.px * width / 100),
        Math.floor(player.py * height / 100),
        Math.floor(player.radius * width / 100),
        Math.floor(player.radius * height / 100)
      ).attr(fill: player.color)
    console.log arguments


