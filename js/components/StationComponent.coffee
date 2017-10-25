util = require '../util.coffee'
clas        = require 'classnames'

recl = React.createClass
rele = React.createElement
{div,style,input,h1,h2,label,span,a} = React.DOM

MessageStore    = require '../stores/MessageStore.coffee'
StationStore    = require '../stores/StationStore.coffee'
MessageActions  = require '../actions/MessageActions.coffee'
StationActions  = require '../actions/StationActions.coffee'
Member          = require './MemberComponent.coffee'
Load            = require './LoadComponent.coffee'

module.exports = recl
  displayName: "Station"
  stateFromStore: -> {
    audi:StationStore.getAudience()
    members:StationStore.getMembers()
    station:util.mainStation()
    filter:MessageStore.getFilter()
    stations:StationStore.getStations()
    configs:StationStore.getConfigs()
    fetching:MessageStore.getFetching()
    typing:StationStore.getTyping()
    listening:StationStore.getListening()
    open:(if @state?.open then @state.open else null)
  }
  getInitialState: -> @stateFromStore()
  componentDidMount: ->
    @$el = $(ReactDOM.findDOMNode())
    MessageStore.addChangeListener @_onChangeStore
    StationStore.addChangeListener @_onChangeStore
    if @state.listening.indexOf(@state.station) is -1
      StationActions.listenStation @state.station
  componentWillUnmount: ->
    StationStore.removeChangeListener @_onChangeStore
  _onChangeStore: -> @setState @stateFromStore()
  componentWillReceiveProps: (nextProps) ->
    if @props.open is true and nextProps.open is false then @setState {open:null}

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
        StationActions.addSources @state.station,[v]
        $input.val('')
        $input.blur()
      else
        $('.menu.depth-1 .add').addClass 'valid-false'

  _openStation: (e) ->
    @setState {open:$(e.target).attr('data-station')}

  _closeStation: -> @setState {open:null}

  _filterStation: (e) ->
    station = $(e.target).attr('data-station')
    if @state.filter isnt station
      MessageActions.setFilter station
    else
      MessageActions.clearFilter()

  _remove: (e) ->
    e.stopPropagation()
    e.preventDefault()
    _station = $(e.target).attr "data-station"
    StationActions.remSources @state.station,[_station]

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
    # members list
    if @state.station and @state.configs[@state.station]
      members = for station,members of @state.members
        _clas = clas
          open:(@state.open is station)
          closed:!(@state.open is station)
          menu:true
          'depth-2':true

        (div {className:_clas,"data-members":station,key:station},
          (div {className:"contents",onClick:@_closeStation},
            (div {className:"close"}, "✕")
            (h2 {},
              (span {}, "Members")
              (label {className:"sum"},
                _.keys(members).length)
            )
            (for member of members
              (div {key:member},
                (div {className:"name"}, "")
                (div {className:"planet"}, member)
            ))
          )
        )

    # sources list
    if @state.station and @state.configs[@state.station]
      sources = for source in @state.configs[@state.station].sources
          (div {key:source,className:"room"},
            (div {
              className:(if @state.open is source then "selected" else "")
              onClick:@_openStation
              "data-station":source}, source)
            (div {
              className:'options'
              },
              (div {
                onClick:@_filterStation,
                "data-station":source}, if @state.filter is source then "Clear" else "Filter")
              (div {
                onClick:@_remove
                "data-station":source }, "Leave")
            )
          )
      sources.push (input {
          key:"placeholder"
          className:"action add"
          placeholder:"+ Listen"
          @onKeyUp
        })
      sourcesSum = @state.configs[@state.station].sources.length
    else
      sources = ""
      sourcesSum = 0

    _clas = clas
      open:(@props.open is true)
      closed:(@props.open isnt true)
      menu:true
      'depth-1':true

    (div {key:"station-container"},
      (div {className:_clas, key:'station'},
        (div {className:"contents"},
          (div {className:"close",onClick:@props.toggle}, "✕")
          # (h2 {},
          #   (span {}, "Direct")
          #   (label {className:"sum"}, 3)
          # )
          # (div {},
          #   (div {className:"name"}, "Galen")
          #   (div {className:"planet"}, "~talsur-todres")
          # )
          # (div {className:"action create"},
          #   (label {}, "")
          #   (span {}, "Message")
          # )
          (h2 {},
            (span {}, "Stations")
            (label {className:"sum"}, sourcesSum)
          )
          (div {}, sources)
        )
      )
      members
    )

    # (div {id:"station",onClick:@_toggleOpen},
    #   (div {id:"head"},
    #     (div {id:"who"},
    #       div {className:"sig"}
    #       div {className:"ship"},"#{window.urb.user}"
    #     )
    #     (rele Load, {})  if @state.fetching
    #     (div {id:"where"},
    #       div {className:"slat"},"talk"
    #       div {className:"path"} #, util.mainStation(window.urb.user))
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
