clas        = require 'classnames'

recl = React.createClass
rele = React.createElement
{div,style,input,h1,h2,label,span,a} = React.DOM

MessageStore    = require '../stores/MessageStore.coffee'
StationStore    = require '../stores/StationStore.coffee'
StationActions  = require '../actions/StationActions.coffee'
Member          = require './MemberComponent.coffee'
Load            = require './LoadComponent.coffee'

module.exports = recl
  displayName: "Station"
  stateFromStore: -> {
    audi:StationStore.getAudience()
    members:StationStore.getMembers()
    station:window.util.mainStation()
    stations:StationStore.getStations()
    configs:StationStore.getConfigs()
    fetching:MessageStore.getFetching()
    typing:StationStore.getTyping()
    listening:StationStore.getListening()
  }
  getInitialState: -> @stateFromStore()
  componentDidMount: ->
    @$el = $(ReactDOM.findDOMNode())
    StationStore.addChangeListener @_onChangeStore
    if @state.listening.indexOf(@state.station) is -1
      StationActions.listenStation @state.station      
  componentWillUnmount: ->
    StationStore.removeChangeListener @_onChangeStore
  _onChangeStore: -> @setState @stateFromStore()

  _toggleOpen: (e) ->
    if $(e.target).closest('.sour-ctrl').length is 0
      $("#station-container").toggleClass 'open'

  validateSource: (s) ->
    {sources} = @state.configs[@state.station]
    s not in sources and "/" in s and s[0] is "~" and s.length >= 5

  onKeyUp: (e) ->
    $('.menu.depth-1 .add').removeClass 'valid-false'
    if e.keyCode is 13
      $input = $(e.target)
      v = $input.val().toLowerCase()
      if v[0] isnt "~" then v = "~#{v}"
      if @validateSource v
        _sources = _.clone @state.configs[@state.station].sources
        _sources.push v
        StationActions.setSources @state.station,_sources
        $input.val('')
        $input.blur()
      else
        $('.menu.depth-1 .add').addClass 'valid-false'

  _remove: (e) ->
    e.stopPropagation()
    e.preventDefault()
    _station = $(e.target).attr "data-station"
    _sources = _.clone @state.configs[@state.station].sources
    _sources.splice _sources.indexOf(_station),1
    StationActions.setSources @state.station,_sources

  render: ->
    parts = []
    members = []

    # members = unless @state.station and @state.members
    #     ""
    #   else for member, stations of @state.members
    #     (div {},
    #        (rele Member, {ship:member})
    #        for station, presence of stations
    #          (div {className:"audi"}, station.slice(1))
    #     )

    if @state.station and @state.configs[@state.station]
      sources = for source in @state.configs[@state.station].sources
          (div {className:"room"}, [
            source.slice(1)
            (div {
              className:"close"
              onClick:@_remove
              "data-station":source }, "✕")
          ])
      sources.push (input {
          className:"action add"
          placeholder:"+ Listen"
          @onKeyUp
        }, "")
      sourcesSum = @state.configs[@state.station].sources.length
    else
      sources = ""
      sourcesSum = 0

    _clas = clas
      open:(@props.open is true)
      closed:(@props.open isnt true)
      'col-md-4':true
      'col-md-offset-2':true
      menu:true
      'depth-1':true

    (div {className:_clas, key:'station'}, [
      (div {className:"contents"}, [
        (div {className:"close",onClick:@props.toggle}, "✕")
        # (h2 {}, [
        #   (span {}, "Direct")
        #   (label {className:"sum"}, 3)
        # ])
        # (div {}, [
        #   (div {className:"name"}, "Galen")
        #   (div {className:"planet"}, "~talsur-todres")
        # ])
        # (div {className:"action create"}, [
        #   (label {}, "")
        #   (span {}, "Message")
        # ])
        (h2 {}, [
          (span {}, "Stations")
          (label {className:"sum"}, sourcesSum)
        ])
        (div {}, sources)
      ])
    ])

    # (div {id:"station",onClick:@_toggleOpen},
    #   (div {id:"head"}, 
    #     (div {id:"who"},
    #       div {className:"sig"}
    #       div {className:"ship"},"#{window.urb.user}"
    #     )
    #     (rele Load, {})  if @state.fetching
    #     (div {id:"where"},
    #       div {className:"slat"},"talk"
    #       div {className:"path"} #, window.util.mainStation(window.urb.user))
    #       div {className:"caret"}
    #     )
    #     div {id:"offline"}, "Warning: no connection to server."
    #   )
    #   (div {id:"stations"},
    #     h1 {}, "Listening to"
    #     div {}, sources
    #     div {className:"sour-ctrl"},
    #       input {className:"join",@onKeyUp,placeholder:"+"}
    #   )
    #   div {id:"audience"}, div {}, (h1 {}, "Talking to"),(div {id:"members"},members)
    # )
