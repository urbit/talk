util = require '../util.coffee'
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
    audi = _.map $(e.target).closest('.path').find('div'), (div) ->
      return "~"+$(div).text()
    @props._handleAudi audi

  _handlePm: (e) ->
    return if not @props._handlePm
    user = $(e.target).closest('.iden').text()
    if user[0] is "~" then user = user.slice 1
    return if user.toLowerCase() is 'system'
    @props._handlePm user

  renderSpeech: ({lin,app,exp,tax,url,mor,fat,com}) ->  # one of
    switch
      when (lin or app or exp or tax)
        (lin or app or exp or tax).txt
      when url
        (a {href:url.txt,target:"_blank",key:"speech"}, url.txt)
      when com
        (div {},
          com.txt
          (div {}, (a {className:"btn", href: com.url}, "Go to thread"))
        )
      when mor then mor.map @renderSpeech
      when fat
        (div {},
          (@renderSpeech fat.taf)
          (div {className:"fat"}, @renderTorso fat.tor)
        )
      else "Unknown speech type:" + (" %"+x for x of arguments[0]).join ''

  renderTorso: ({text,tank,name}) -> # one of
    switch
      when text? then text
      when tank? then pre {}, tank.join("\n")
      when name? then (div {}, name.nom, ": ", @renderTorso name.mon)
      else "Unknown torso:"+(" %"+x for x of arguments[0]).join ''

  classesInSpeech: ({url,exp,app,lin,mor,fat}) -> # at most one of
    switch
      when url then "url"
      when exp then "exp"
      when app then "say"
      when lin then {say: lin.say is false}
      when mor then mor?.map @classesInSpeech
      when fat then @classesInSpeech fat.taf

  render: ->
    {thought} = @props
    delivery = _.uniq _.pluck thought.audience, "delivery"
    speech = thought.statement.speech
    bouquet = thought.statement.bouquet
    if !speech? then return;

    name = if @props.name then @props.name else ""
    aude = _.keys thought.audience
    audi = util.clipAudi(aude).map (_audi) -> (div {key:_audi}, _audi)

    mainStation = util.mainStationPath(window.urb.user)
    type = if mainStation in aude then 'private' else 'public'

    if(_.filter(bouquet, ["comment"]).length > 0)
      comment = true
      for k,v of speech.mor
        if v.fat
          url = v.fat.taf.url.txt
          txt = v.fat.tor.text
        if v.app then path = v.app.txt.replace "comment on ", ""
      audi = (a {href:url}, path)
      speech = {com:{txt,url}}

    className = clas 'gram',
      (if @props.sameAs then "same" else "first"),
      (if delivery.indexOf("received") isnt -1 then "received" else "pending"),
      {'new': @props.unseen}
      {comment}
      @classesInSpeech speech

    style =
      height: @props.height
      marginTop: @props.marginTop
    (div {className, 'data-index':@props.index, key:"message", style},
        (div {className:"meta",key:"meta"},
          label {className:"type #{type}","data-glyph":(@props.glyph || "*")}
          (h2 {className:'author planet',onClick:@_handlePm,key:"member"},
           (React.createElement Member,{ship:@props.ship,glyph:@props.glyph,key:"member"})
          )
          h3 {className:"path",onClick:@_handleAudi,key:"audi"}, audi
          h3 {className:"time",key:"time"}, @convTime thought.statement.date
        )
        (div {className:"speech",key:"speech"},
          @renderSpeech speech,bouquet
    ))
