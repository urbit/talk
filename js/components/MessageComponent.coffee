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
      return $(div).text()
    @props._handleAudi audi

  _handlePm: (e) ->
    return if not @props._handlePm
    user = $(e.target).closest('.iden').text()
    if user[0] is "~" then user = user.slice 1
    return if user.toLowerCase() is 'system'
    @props._handlePm user

  renderSpeech: ({lin,url,exp,ire,fat,inv,app}) ->  # one of
    switch
      when lin
        lin.msg
      when url
        (a {href:url,target:"_blank",rel:"noopener",key:"speech"}, url)
      when exp
        (div {},
          (exp.exp)
          (div {className:"fat"}, pre {}, exp.res.join("\n"))
        )
      when ire
        #TODO show parent on-hover or something
        @renderSpeech ire.sep
      when fat
        (div {},
          (@renderSpeech fat.sep)
          (div {className:"fat"}, @renderAttache fat.tac)
        )
      when inv
        prex = inv.inv ? "invited you to " : "banished you from "
        prex + inv.cir
      when app
        app.msg
      else "Unknown speech type:" + (" %"+x for x of arguments[0]).join ''

  renderAttache: ({text,tank,name}) -> # one of
    switch
      when text? then text
      when tank? then pre {}, tank.join("\n")
      when name? then (div {}, name.nom, ": ", @renderTorso name.tac)
      else "Unknown torso:"+(" %"+x for x of arguments[0]).join ''

  classesInSpeech: ({lin,url,exp,ire,fat,inv,app}) -> # at most one of
    switch
      when lin then {say: lin.pat}
      when url then "url"
      when exp then "exp"
      when ire then @classesInSpeech ire.sep
      when fat then @classesInSpeech fat.sep
      when inv then {say: true}
      when app then "exp"

  render: ->
    gam = @props
    heard = gam.heard
    speech = gam.sep
    #bouquet = gam.statement.bouquet
    if !speech? then return;

    name = if @props.name then @props.name else ""
    audi = util.clipAudi(gam.aud).map (_audi) -> (div {key:_audi}, _audi)

    mainStation = util.mainStationPath(window.urb.user)
    type = if mainStation in gam.aud then 'private' else 'public'

    ###
    if(_.filter(bouquet, ["comment"]).length > 0)
      comment = true
      for k,v of speech.mor
        if v.fat
          url = v.fat.taf.url.txt
          txt = v.fat.tor.text
        if v.app then path = v.app.txt.replace "comment on ", ""
      audi = (a {href:url}, path)
      speech = {com:{txt,url}}
    ###

    className = clas 'gram',
      (if @props.sameAs then "same" else "first"),
      (if heard then "received" else "pending"),
      {'new': @props.unseen}
      {comment:false} #{comment}
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
          h3 {className:"time",key:"time"}, @convTime gam.wen
        )
        (div {className:"speech",key:"speech"},
          @renderSpeech speech #,bouquet
    ))
