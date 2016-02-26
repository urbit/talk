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

  renderSpeech: ({lin,app,exp,tax, url, mor,fat})-> switch # one of
    when (con = lin or app or exp or tax)
      con.txt
    when url
      (a {href:url.txt,target:"_blank",key:"speech"}, url.txt)
    when mor then mor.map @renderSpeech
    when fat
      [ (@renderSpeech fat.taf)
        (div {className:"fat"}, @renderTorso fat.tor)
      ]
    else "Unknown speech type:" + (" %"+x for x of arguments[0]).join ''

  renderTorso: ({text,tank,name}) -> switch  # one of
    when text? then text
    when tank? then pre {}, tank.join("\n")
    when name? then [name.nom, ": ", @renderTorso name.mon]
    else "Unknown torso:"+(" %"+x for x of arguments[0]).join ''

  classesInSpeech: ({url,exp, app,lin, mor,fat})-> switch # at most one of
    when url then "url"
    when exp then "exp"
    when app then "say"
    when lin then {say: lin.say is false}
    when mor then mor?.map @classesInSpeech
    when fat then @classesInSpeech fat.taf

  render: ->
    # pendingClass = clas pending: @props.pending isnt "received"
    {thought} = @props
    delivery = _.uniq _.pluck thought.audience, "delivery"
    speech = thought.statement.speech
    if !speech? then return;
    
    name = if @props.name then @props.name else ""
    aude = _.keys thought.audience
    audi = window.util.clipAudi(aude).map (_audi) -> (div {}, _audi.slice(1))

    mainStation = window.util.mainStationPath(window.urb.user)
    type = if mainStation in aude then 'private' else 'public'

    className = clas 'gram',
      (if @props.sameAs then "same" else "first"),
      (if delivery.indexOf("received") isnt -1 then "received" else "pending"),
      {'new': @props.unseen}
      @classesInSpeech speech
        
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
    ))
