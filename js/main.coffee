util = require './util.coffee'

_.merge window, {util, talk:{online:yes}}

StationActions = require './actions/StationActions.coffee'
Store = window.tree.util.store
TreeActions = window.tree.util.actions


setInterval (->
  window.talk.online = window.urb.poll.delay < 500
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
MessageListComponent   = React.createFactory require './components/MessageListComponent.coffee'
WritingComponent    = React.createFactory require './components/WritingComponent.coffee'

{div,link} = React.DOM

Talk = React.createClass
  displayName:"talk"
  getStation: -> @props.station or util.defaultStation()

  componentWillMount: ->

    if not @props.readonly
      $(window).on 'scroll', util.checkScroll

    station = @getStation()
    StationActions.listen()
    # StationActions.listenStation station
    StationActions.switchStation station

  render: ->
    station =  @getStation()
    children = [
      (div {key:"grams-container"},
        (MessageListComponent _.merge({},@props,{station,key:'grams'}), '')
      )
      unless @props.readOnly?
        (div {key:'writing-container'},
          (WritingComponent _.merge({},@props,{station,key:'writing'}), '')
        )
    ]
    if @props.chrono is "reverse"
      children = children.reverse()
    (div {key:"talk-container"}, children)

Store.dispatch (TreeActions.registerComponent "talk",Talk)
Store.dispatch (TreeActions.registerComponent "talk-station",StationComponent)
