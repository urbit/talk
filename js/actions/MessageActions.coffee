util = require '../util.coffee'

Dispatcher   =  require '../dispatcher/Dispatcher.coffee'

_persistence = require '../persistence/MessagePersistence.coffee'

Persistence = _persistence MessageActions: module.exports =
  setFilter: (station) ->
    Dispatcher.handleViewAction {station,type:"messages-filter"}

  clearFilter: () ->
    Dispatcher.handleViewAction {type:"messages-filter-clear"}

  loadMessages: (messages,last,get) ->
    Dispatcher.handleServerAction {messages,last,get,type:"messages-load"}

  listenStation: (station,date) ->
    if not date then date = window.urb.util.toDate (
      now = new Date()
      # now.setMinutes 0
      now.setSeconds 0
      now.setMilliseconds 0
      new Date (now - 6*3600*1000)
    )
    Dispatcher.handleViewAction type:"messages-fetch"
    Persistence.listenStation station,date

  listeningStation: (station) ->
    Dispatcher.handleViewAction {station,type:"messages-listen"}

  setTyping: (state) ->
    Dispatcher.handleViewAction {state,type:"messages-typing"}

  getMore: (station,start,end) ->
    Dispatcher.handleViewAction type:"messages-fetch"
    Persistence.get station,start,end

  sendMessage: (txt,audience,global=(urb.user is urb.ship)) ->
    # audience.push util.mainStationPath window.urb.user
    audience = _.uniq audience
    # audience = ["~#{window.urb.ship}/home"]

    speech = lin: {msg:txt, pat:false}

    if txt[0] is "@"
      speech.lin.msg = speech.lin.msg.slice(1).trim()
      speech.lin.pat = true

    else if txt[0] is "#"
      speech = exp: {exp:speech.lin.msg.slice(1).trim()}

    else if window.urb.util.isURL(txt)
      speech = url: txt

    message =
      aut:window.urb.user # only used internally
      uid:util.uuid32()
      aud:audience
      wen:Date.now()
      sep:speech

    Dispatcher.handleViewAction {message,type:"message-send"}
    Persistence.sendMessage message
