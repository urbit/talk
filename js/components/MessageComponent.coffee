moment = require 'moment-timezone'
clas = require 'classnames'

recl = React.createClass
{div,pre,a,label,h2,h3} = React.DOM

Member          = require './MemberComponent.coffee'

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
    audi = _.map $(e.target).closest('.path').find('div'), (div) -> return "~"+$(div).text()
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

    className = clas 'gram',
      (if @props.sameAs then "same" else "first"),
      (if delivery.indexOf("received") isnt -1 then "received" else "pending"),
      {say: speech.lin?.say is false, url: speech.url, 'new': @props.unseen},
      switch
        when speech.app? then "say"
        when speech.exp? then "exp"
        
    (div {className, 'data-index':@props.index, key:"message"},
        (div {className:"meta",key:"meta"},
          label {className:"type #{type}",key:"glyph","data-glyph":(@props.glyph || "*")}
          (h2 {className:'author planet',onClick:@_handlePm,key:"member"},
           (React.createElement Member,{ship:@props.ship,glyph:@props.glyph,key:"member"})
          )
          h3 {className:"path",onClick:@_handleAudi,key:"audi"}, audi
          h3 {className:"time",key:"time"}, @convTime thought.statement.date
        )
        (div {className:"speech",key:"speech"}, 
          @renderSpeech speech
          if attachments.length
            div {className:"fat",key:"fat"}, attachments
    ))
