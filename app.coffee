coffeeScriptCompiler = require("express-coffee")
express = require("express")
stylus = require("stylus")
nib = require("nib")

app = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"


  app.use coffeeScriptCompiler(
    path: __dirname + '/public'
  )

  app.use stylus.middleware(
    src: __dirname + "/public"
    compile: (str, path) -> stylus(str).set("filename", path).use nib()
  )
  app.use express.static(__dirname + "/public")

app.get "/", (req, res) ->
  res.render "index",
    layout: false

app.listen (process.env.PORT or 3000), ->
  addr = app.address()
  console.log "   app listening on http://" + addr.address + ":" + addr.port

chatServer = require './chat_server'
chatServer.listen(app)
