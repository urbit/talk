StationActions = require './actions/StationActions.coffee'

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


StationComponent    = React.createFactory require './components/StationComponent.coffee'
MessagesComponent   = React.createFactory require './components/MessagesComponent.coffee'
WritingComponent    = React.createFactory require './components/WritingComponent.coffee'

{div,link} = React.DOM

window.tree.components.talk = React.createClass
  displayName:"talk"

  componentWillMount: -> 
    require './util.coffee'
    require './move.coffee'
    StationActions.listen()
    StationActions.listenStation window.util.mainStation()

  render: ->
    (div {}, [
      (div {key:"grams-container"}, (MessagesComponent {key:'grams'}, ''))
      (div {key:'writing-container'}, (WritingComponent {key:'writing'}, ''))
    ])