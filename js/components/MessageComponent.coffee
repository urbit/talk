moment = require 'moment-timezone'
clas = require 'classnames'

recl = React.createClass
{div,pre,a} = React.DOM

Member          = require './MemberComponent.coffee'

MESSAGE_HEIGHT = 48 # XX measure

module.exports = recl
  displayName: "Message"
  
  lz: (n) -> if n<10 then "0#{n}" else "#{n}"

  convTime: (time) ->
    d = new Date time
    h = @lz d.getHours()
    m = @lz d.getMinutes()
    s = @lz d.getSeconds()
    "~#{h}.#{m}.#{s}"

  _handleAudi: (e) ->
    audi = _.map $(e.target).closest('.audi').find('div'), (div) -> return "~"+$(div).text()
    @props._handleAudi audi

  _handlePm: (e) ->
    return if not @props._handlePm
    user = $(e.target).closest('.iden').text()
    return if user.toLowerCase() is 'system'
    @props._handlePm user

  renderSpeech: (speech)-> switch
    when (con = speech.lin) or (con = speech.app) or
         (con = speech.exp) or (con = speech.tax)
      con.txt
    when (con = speech.url)
      (a {href:con.txt,target:"_blank",key:"speech"}, con.txt)
    when (con = speech.mor) then con.map @renderSpeech
    else "Unknown speech type:" + (" %"+x for x of speech).join ''

  render: ->
    # pendingClass = clas pending: @props.pending isnt "received"
    {thought} = @props
    delivery = _.uniq _.pluck thought.audience, "delivery"
    speech = thought.statement.speech
    attachments = []
    while speech.fat?
      attachments.push pre {}, speech.fat.tor.tank.join("\n")
      speech = speech.fat.taf  # XX
    if !speech? then return;
    
    name = if @props.name then @props.name else ""
    aude = _.keys thought.audience
    audi = window.util.clipAudi(aude).map (_audi) -> (div {}, _audi.slice(1))

    mainStation = window.util.mainStationPath(window.urb.user)
    type = if mainStation in aude then 'private' else 'public'

    className = clas 'message',
      (if @props.sameAs then "same" else "first"),
      (if delivery.indexOf("received") isnt -1 then "received" else "pending"),
      {say: speech.lin?.say is false, url: speech.url, 'new': @props.unseen},
      switch
        when speech.app? then "say"
        when speech.exp? then "exp"
        
    (div {className, 'data-index':@props.index, key:"message"},
        (div {className:"attr",key:"attr"},
          div {className:"type #{type}",key:"glyph","data-glyph":(@props.glyph || "*")}
          (div {onClick:@_handlePm,key:"member"},
           (React.createElement Member,{ship:@props.ship,glyph:@props.glyph,key:"member"})
          )
          div {onClick:@_handleAudi,className:"audi",key:"audi"}, audi
          div {className:"time",key:"time"}, @convTime thought.statement.date
        )
        (div {className:"mess",key:"mess"}, 
          @renderSpeech speech
          if attachments.length
            div {className:"fat",key:"fat"}, attachments
    ))
