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
  validKeys = ["up", "down", "left", "right", "ctrl"]

  onKeysChanged = ->
    FuriousEarth.socket.sendKeys _.intersection(validKeys, KeyboardJS.activeKeys())

  for key in validKeys
    KeyboardJS.bind.key key, onKeysChanged, onKeysChanged

  FuriousEarth.socket.bind 'change:state', ->
    $('body').append("<p>#{JSON.stringify(arguments)}</p>")

  Raphael "canvas", document.width, document.height, ->
    @rect( 10, 10, 25, 25).attr stroke: "#f00", fill: "#000"
