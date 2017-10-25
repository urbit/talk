module.exports = util =
  defaultStation: ->
    if document.location.search
      station = document.location.search.replace /^\?/,''
      if station.indexOf('dbg.nopack') isnt -1 then station = util.mainStation()
    else util.mainStation()

  mainStations: ["court","floor","porch"]

  mainStationPath: (user) -> if user then "~#{user}/#{util.mainStation user}"

  mainStation: (user) ->
    if not user then user = window.urb.user
    if not user then return
    switch user.length
      when 3
        return "court"
      when 6
        return "floor"
      else
        return "porch"

  clipAudi: (audi) ->
    audi = audi.join " "
    ms = util.mainStationPath window.urb.user
    regx = new RegExp "/#{ms}","g"
    audi = audi.replace regx,""
    audi.split " "

  expandAudi: (audi) ->
    audi = audi.join " "
    ms = util.mainStationPath window.urb.user
    if audi.indexOf(ms) is -1
      if audi.length > 0
        audi += " "
      audi += "#{ms}"
    audi.split " "

  create: (name) ->
    window.talk.StationPersistence.createStation name, (err,res) ->

  subscribe: (name) ->
    window.talk.StationPersistence.addSource "main",window.urb.ship,["~zod/#{name}"]

  uuid32: ->
    str = "0v"
    str += Math.ceil(Math.random()*8)+"."
    for i in [0..5]
      _str = Math.ceil(Math.random()*10000000).toString(32)
      _str = ("00000"+_str).substr(-5,5)
      str += _str+"."
    str.slice(0,-1)

  populate: (station,number) ->
    c = 0
    send = ->
      if c < number
        c++
      else
        console.log 'done'
        return true
      _audi = {}
      _audi[station] = "pending"
      _message =
        serial:util.uuid32()
        audience:_audi
        statement:
          speech:
            say:"Message "+c
          time: Date.now()
          now: Date.now()
      window.talk.MessagePersistence.sendMessage _message,send
    send()

  scrollToBottom: -> $(window).scrollTop($(".container").outerHeight(true))

  getScroll: ->
    @writingPosition = $('.container').outerHeight(true) +
                       $('.container').offset().top -
                       $(window).height()

  setScroll: ->
    util.getScroll()
    $(window).scrollTop($(".container").height())

  isScrolling: ->
    if not util.writingPosition
      util.getScroll()
    return ($(window).scrollTop()+$('.writing').outerHeight() <
            util.writingPosition)

  talkPath: (components...)->
    ['',components...].join '/'
