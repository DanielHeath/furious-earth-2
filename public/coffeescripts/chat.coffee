message = (from, msg) ->
  $("#lines").append $("<p>").append($("<b>").text(from), msg)

socket = io.connect()
socket.on "connect", ->
  $("#chat").addClass "connected"

socket.on "announcement", (msg) ->
  $("#lines").append $("<p>").append($("<em>").text(msg))

socket.on "nicknames", (nicknames) ->
  $("#nicknames").empty().append $("<span>Online: </span>")
  for i of nicknames
    $("#nicknames").append $("<b>").text(nicknames[i])

socket.on "user message", message
socket.on "reconnect", ->
  $("#lines").remove()
  message "System", "Reconnected to the server"

socket.on "reconnecting", ->
  message "System", "Attempting to re-connect to the server"

socket.on "error", (e) ->
  message "System", (if e then e else "A unknown error occurred")

$ ->
  clear = -> $("#message").val("").focus()

  $("#set-nickname input").keydown (event) ->
    if "#{event.keyCode}" is "13"
      $("#set-nickname").submit()
      event.preventDefault()
      false

  $("#set-nickname").submit (ev) ->
    socket.emit "join", $("#nick").val(), $("#game").val(), (err_element) ->
      unless err_element
        clear()
        return $("#chat").addClass("nickname-set")
      $(err_element).css "visibility", "visible"
    false

  $("#send-message").submit ->
    message "me", $("#message").val()
    socket.emit "user message", $("#message").val()
    clear()
    $("#lines").get(0).scrollTop = 10000000
    false
