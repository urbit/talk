recl = React.createClass
recf = React.createFactory
{div} = React.DOM

StationComponent      = recf require './StationComponent.coffee'
MessageListComponent  = recf require './MessageListComponent.coffee'
WritingComponent      = recf require './WritingComponent.coffee'

module.exports = recl
  render: ->
    (div {}, [
      (div {id:"station-container"}, (StationComponent {}))
      (div {id:"messages-container"}, (MessagesComponent {}))
      (div {id:"writing-container"}, (WritingComponent {}))
    ])
