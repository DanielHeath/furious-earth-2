class Socket extends Backbone.Model
  constructor: ->
    @socket = io.connect()
    @socket.on "connect", => @trigger("connect")
    @socket.on "announcement", (msg) => @trigger("announcement", msg)
    @socket.on "nicknames", (nicknames) => @trigger("nicknames:changed", nicknames)
    @socket.on "user message", (user, message) => @trigger('chat', user, message)
    @socket.on "reconnect", => @trigger('reconnect')
    @socket.on "reconnecting", => @trigger('reconnecting')
    @socket.on "error", (e) => @trigger('error', e)

  sendChat: (message) ->
    @socket.emit "user message", message

  join: (nickname, gameName) ->
    @socket.emit "join", nickname, gameName, (err) =>
      if err then @trigger('joinGame:error', err) else @trigger('joinGame:success')


class Chat extends Backbone.View

  events:
    'submit .set-nickname': 'setNickname'
    'submit .send-message': 'sendMessage'
    'keydown .set-nickname input': '_submitOnEnterKey'

  initialize: () ->
    @model.bind 'connect', @onConnect
    @model.bind 'reconnecting', => @addAnnouncement('Attempting to re-connect to the server')
    @model.bind 'reconnect', => @$('.lines').remove(); @addAnnouncement('Reconnected to the server')
    @model.bind 'error', (e) => @addAnnouncement(if e then e else "A unknown error occurred")
    @model.bind 'chat', @addMessage
    @model.bind 'nicknames:changed', @renderNicknames
    @model.bind 'announcement', @addAnnouncement
    @model.bind 'joinGame:success', @onJoinGame
    @model.bind 'joinGame:error', @onJoinError

  renderNicknames: (nicknames) =>
    @$(".nicknames").empty().append $("<span>Online: </span>")
    for i of nicknames
      @$(".nicknames").append $("<b>").text(nicknames[i])

  addAnnouncement: (msg) =>
    @$(".lines").append $("<p>").append($("<em>").text(msg))

  onConnect: =>
    $(@el).addClass('connected')

  onJoinError: (errElement) =>
    @$(err_element).css "visibility", "visible"

  onJoinGame: =>
    @clear()
    $(@el).addClass("nickname-set")

  setNickname: =>
    @model.join @$(".nick").val(), @$(".game").val()

  sendMessage: ->
    @addMessage "me", @$(".message").val()
    @model.sendChat @$(".message").val()
    @clear()
    @scrollToEnd()
    false

  scrollToEnd: ->
    @$(".lines").get(0).scrollTop = 10000000

  addMessage: (from, msg) =>
    @$(".lines").append $("<p>").append($("<b>").text(from), msg)

  clear: -> @$(".message").val("").focus()

  _submitOnEnterKey: (event) ->
    if "#{event.keyCode}" is "13"
      @$(".set-nickname").submit()
      event.preventDefault()
      false

$ ->
  socket = new Socket()
  window.chat = new Chat el: $("#chat")[0], model: socket
