util = require '../util.coffee'
Infinite = null

recl = React.createClass
{div} = React.DOM

MessageActions  = require '../actions/MessageActions.coffee'
MessageStore    = require '../stores/MessageStore.coffee'
StationActions  = require '../actions/StationActions.coffee'
StationStore    = require '../stores/StationStore.coffee'
Message         = require './MessageComponent.coffee'

# Infinite scrolling requires overriding CSS heights. Turn this off to measure
# the true heights of messages
# XX rems
# XX don't hardcode these values
INFINITE = yes
MESSAGE_HEIGHT_SAME  = 27
MESSAGE_HEIGHT_FIRST = 56 - MESSAGE_HEIGHT_SAME
MESSAGE_HEIGHT_FIRST_MARGIN_TOP = 36
FONT_SIZE = parseInt($('body').css('font-size').match(/(\d*)px/)[1])

module.exports = recl
  displayName: "Messages"
  pageSize: 200
  paddingTop: 100
  paddingBottom: 100

  stateFromStore: -> {
    messages:MessageStore.getAll()
    last:MessageStore.getLast()
    fetching:MessageStore.getFetching()
    listening:MessageStore.getListening()
    station:StationStore.getStation()
    stations:StationStore.getStations()
    configs:StationStore.getConfigs()
    typing:MessageStore.getTyping()
    glyph:StationStore.getGlyphMap()
  }

  getInitialState: -> @stateFromStore()

  _blur: ->
    @focused = false
    @lastSeen = @last

  _focus: ->
    @focused = true
    @lastSeen = null
    $('.message.new').removeClass 'new'
    document.title = document.title.replace /\ \([0-9]*\)/, ""

  # container: -> $(@props.container ? window)
  atScrollEdge: ->
    switch @props.chrono
      when "reverse"
        $(window).height() <
          $(window).scrollTop() + $(window)[0].innerHeight + @paddingBottom
      else $(window).scrollTop() < @paddingTop

  checkMore: ->
    if @atScrollEdge() &&
        @state.fetching is false &&
        this.state.last &&
        this.state.last > 0
      end = @state.last-@pageSize
      end = 0 if end < 0
      @lastLength = @length
      MessageActions.getMore @state.station,(@state.last+1),end

  setAudience: ->
    return if @state.typing or not @last
    laudi = _.keys @last.thought.audience
    return if (_.isEmpty laudi) or not
              _(laudi).difference(@state.audi).isEmpty()
      StationActions.setAudience _.keys(@last.thought.audience)

  sortedMessages: (messages) ->
    station = @state.station
    _.sortBy messages, (message) =>
          message.pending = message.thought.audience[station]
          if @props.chrono is "reverse"
            -message.key
          else message.key
          #message.thought.statement.date

  componentWillMount: -> Infinite = window.Infinite # require 'react-infinite'

  componentDidMount: ->
    MessageStore.addChangeListener @_onChangeStore
    StationStore.addChangeListener @_onChangeStore
    if @state.station and @state.listening.indexOf(@state.station) is -1
      MessageActions.listenStation @state.station
    unless @props.static?
      $(window).on 'scroll', @checkMore
    unless @props.chrono is "reverse"
      util.scrollToBottom()
    @focused = true
    $(window).on 'blur', @_blur
    $(window).on 'focus', @_focus
    $(window).on 'resize', _.debounce(=>
      @forceUpdate()
    , 250)


  componentWillUpdate: (props, state)->
    @scrollBottom = $(document).height() - ($(window).scrollTop() + window.innerHeight)


  componentDidUpdate: (_props, _state)->
    _messages = @sortedMessages @state.messages
    _oldMessages = @sortedMessages _state.messages
    # a message with no key is pending
    # XX should be message.pending: true
    appendedToBottom = !_.last(_messages)?.key? or _.last(_messages)?.key > _.last(_oldMessages)?.key
    setOffset = $(document).height() - window.innerHeight - @scrollBottom
    if @props.chrono isnt "reverse"
      unless @scrollBottom > 0 and appendedToBottom
        $(window).scrollTop setOffset

    if @focused is false and @last isnt @lastSeen
      d = _messages.length-_messages.indexOf(@lastSeen)-1
      t = document.title
      if document.title.match(/\([0-9]*\)/)
        document.title = document.title.replace /\([0-9]*\)/, "(#{d})"
      else
        document.title = document.title + " (#{d})"

  componentWillUnmount: ->
    MessageStore.removeChangeListener @_onChangeStore
    StationStore.removeChangeListener @_onChangeStore

  _onChangeStore: -> @setState @stateFromStore()

  _handlePm: (user) ->
    return if @props.chrono is 'reverse'
    audi = [util.mainStationPath(user)]
    if user is window.urb.user then audi.pop()
    StationActions.setAudience audi

  _handleAudi: (audi) -> StationActions.setAudience audi

  render: ->
    station = @state.station
    messages = @sortedMessages @state.messages

    @last = messages[messages.length-1]
    if @last?.ship && @last.ship is window.urb.user then @lastSeen = @last
    @length = messages.length

    setTimeout (=> @checkMore() if @length < @pageSize), 1

    lastIndex = if @lastSeen then messages.indexOf(@lastSeen)+1 else null
    lastSaid = null

    messageHeights = []
    canvas = document.createElement 'canvas'
    context = canvas.getContext '2d'
    speechLength = $('.grams').width() - (FONT_SIZE * 1.875)

    _messages = messages.map (message,index) =>
      nowSaid = [message.ship,_.keys(message.thought.audience)]
      sameAs = _.isEqual lastSaid, nowSaid
      lastSaid = nowSaid
      lineNums = 1
      speechArr = []
      context.font = FONT_SIZE + 'px bau'
      if message.thought.statement.speech.lin?
        speechArr = message.thought.statement.speech.lin.txt.split(/(\s|-)/)
      else if message.thought.statement.speech.url?
        speechArr = message.thought.statement.speech.url.txt.split(/(\s|-)/)
      else if message.thought.statement.speech.fat?
        context.font = (FONT_SIZE * 0.9) + 'px scp'
        speechArr = message.thought.statement.speech.fat.taf.exp.txt.split(/(\s|-)/)

      _.reduce(_.tail(speechArr), (base, word) ->
        if context.measureText(base + word).width > speechLength
          lineNums += 1
          if word == ' '
            ''
          else if word == '-'
            _.head(base.split(/\s|-/).reverse()) + word
          else
            word
        else
          return base + word
      , _.head(speechArr))

      if INFINITE
        if sameAs
          height = MESSAGE_HEIGHT_SAME * lineNums
          marginTop = 0
        else
          height = MESSAGE_HEIGHT_FIRST + (MESSAGE_HEIGHT_SAME * lineNums)
          marginTop = MESSAGE_HEIGHT_FIRST_MARGIN_TOP
      else
        height = null
        marginTop = null

      messageHeights.push height+marginTop

      {speech} = message.thought.statement
      React.createElement Message, (_.extend {}, message, {
        station, sameAs, @_handlePm, @_handleAudi, height, marginTop,
        index: message.key
        key: "message-#{message.key}"
        ship: if speech?.app then "system" else message.ship
        glyph: @state.glyph[(_.keys message.thought.audience).join " "]
        unseen: lastIndex and lastIndex is index
      })

    if (not @props.readOnly?) and INFINITE
      body = React.createElement Infinite, {
          useWindowAsScrollContainer: true
          containerHeight: window.innerHeight
          elementHeight: messageHeights
          key:"messages-infinite"
        }, _messages
    else
      body = _messages

    (div {className:"grams", key:"messages"}, body)
