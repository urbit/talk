StationActions = require './actions/StationActions.coffee'
TreeActions = window.tree.actions

window.talk = {online:yes}

setInterval (->
  window.talk.online = window.urb.poll.dely < 500
  if window.talk.online
    $('body').removeClass 'offline'
  else $('body').addClass 'offline'
), 300

# checkScroll = ->
#   if $(window).scrollTop() > 20
#     $('#nav').addClass 'scrolling'
#   else
#     $('#nav').removeClass 'scrolling'
# setInterval checkScroll, 500


StationComponent    = require './components/StationComponent.coffee'
MessagesComponent   = React.createFactory require './components/MessagesComponent.coffee'
WritingComponent    = React.createFactory require './components/WritingComponent.coffee'

{div,link} = React.DOM

TreeActions.registerComponent "talk", React.createClass
  displayName:"talk"
  getStation: -> @props.station or window.util.defaultStation()
  
  componentWillMount: -> 
    require './utils/util.coffee'
    require './utils/move.coffee'

    if not @props.readonly
      $(window).on 'scroll', window.util.checkScroll

    station = @getStation()
    StationActions.listen()
    StationActions.listenStation station
    StationActions.switchStation station

  render: ->
    station =  @getStation()
    (div {key:"talk-container"}, [
      (div {key:"grams-container"},
        (MessagesComponent _.merge({},@props,{station,key:'grams'}), '')
      )
      unless @props.readOnly?
        (div {key:'writing-container'},
          (WritingComponent _.merge({},@props,{station,key:'writing'}), '')
        )
    ])
    
TreeActions.registerComponent "talk-station", StationComponent
