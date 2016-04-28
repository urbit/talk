util = require '../util.coffee'
recl = React.createClass
{div,br,input,textarea} = React.DOM

husl = require 'husl'

MessageActions  = require '../actions/MessageActions.coffee'
MessageStore    = require '../stores/MessageStore.coffee'
StationActions  = require '../actions/StationActions.coffee'
StationStore    = require '../stores/StationStore.coffee'
Member          = require './MemberComponent.coffee'

SHIPSHAPE = ///
^~?(                              #preamble
   [a-z]{3}                       # galaxy
 | [a-z]{6}(-[a-z]{6}){0,3}       # star - moon
 |   [a-z]{6}(-[a-z]{6}){3}       # comet
   (--[a-z]{6}(-[a-z]{6}){3})+    #
)$                                #postamble
///
PO = '''
dozmarbinwansamlitsighidfidlissogdirwacsabwissib
rigsoldopmodfoglidhopdardorlorhodfolrintogsilmir
holpaslacrovlivdalsatlibtabhanticpidtorbolfosdot
losdilforpilramtirwintadbicdifrocwidbisdasmidlop
rilnardapmolsanlocnovsitnidtipsicropwitnatpanmin
ritpodmottamtolsavposnapnopsomfinfonbanporworsip
ronnorbotwicsocwatdolmagpicdavbidbaltimtasmallig
sivtagpadsaldivdactansidfabtarmonranniswolmispal
lasdismaprabtobrollatlonnodnavfignomnibpagsopral
bilhaddocridmocpacravripfaltodtiltinhapmicfanpat
taclabmogsimsonpinlomrictapfirhasbosbatpochactid
havsaplindibhosdabbitbarracparloddosbortochilmac
tomdigfilfasmithobharmighinradmashalraglagfadtop
mophabnilnosmilfopfamdatnoldinhatnacrisfotribhoc
nimlarfitwalrapsarnalmoslandondanladdovrivbacpol
laptalpitnambonrostonfodponsovnocsorlavmatmipfap

zodnecbudwessevpersutletfulpensytdurwepserwylsun
rypsyxdyrnuphebpeglupdepdysputlughecryttyvsydnex
lunmeplutseppesdelsulpedtemledtulmetwenbynhexfeb
pyldulhetmevruttylwydtepbesdexsefwycburderneppur
rysrebdennutsubpetrulsynregtydsupsemwynrecmegnet
secmulnymtevwebsummutnyxrextebfushepbenmuswyxsym
selrucdecwexsyrwetdylmynmesdetbetbeltuxtugmyrpel
syptermebsetdutdegtexsurfeltudnuxruxrenwytnubmed
lytdusnebrumtynseglyxpunresredfunrevrefmectedrus
bexlebduxrynnumpyxrygryxfeptyrtustyclegnemfermer
tenlusnussyltecmexpubrymtucfyllepdebbermughuttun
bylsudpemdevlurdefbusbeprunmelpexdytbyttyplevmyl
wedducfurfexnulluclennerlexrupnedlecrydlydfenwel
nydhusrelrudneshesfetdesretdunlernyrsebhulryllud
remlysfynwerrycsugnysnyllyndyndemluxfedsedbecmun
lyrtesmudnytbyrsenwegfyrmurtelreptegpecnelnevfes
'''
textToHTML = (txt)-> __html: $('<div>').text(txt).html()

Audience = recl
  displayName: "Audience"
  onKeyDown: (e) ->
    if e.keyCode is 13 
      e.preventDefault()
      if @props.validate()
        setTimeout (-> $('.writing').focus()),0
        return false
  render: ->
    div {className:'audience',id:'audience',key:'audience'}, (div {
          className:"input valid-#{@props.valid}"
          key:'input'
          contentEditable:true
          @onKeyDown
          onBlur:@props.onBlur
          dangerouslySetInnerHTML: textToHTML @props.audi.join(" ")
        })

module.exports = recl
  displayName: "Writing"
  set: ->
    if window.localStorage and @$message then window.localStorage.setItem 'writing', @$message.text()

  get: ->
    if window.localStorage then window.localStorage.getItem 'writing'

  stateFromStore: -> 
    s =
      audi:StationStore.getAudience()
      ludi:MessageStore.getLastAudience()
      config:StationStore.getConfigs()
      members:StationStore.getMembers()
      typing:StationStore.getTyping()
      station:StationStore.getStation()
      valid:StationStore.getValidAudience()
    s.audi = _.without s.audi, util.mainStationPath window.urb.user
    s.ludi = _.without s.ludi, util.mainStationPath window.urb.user
    s

  getInitialState: -> _.extend @stateFromStore(), length:0, lengthy: false

  typing: (state) ->
    if @state.typing[@state.station] isnt state
      StationActions.setTyping @state.station,state

  onBlur: -> 
    @$message.text @$message.text()
    MessageActions.setTyping false
    @typing false

  onFocus: -> 
    MessageActions.setTyping true
    @typing true
    @cursorAtEnd

  addCC: (audi) ->
    listening = @state.config[@props.station]?.sources ? []
    if _.isEmpty _.intersection audi, listening
      audi.push "~#{window.urb.user}/#{@props.station}"
    audi

  sendMessage: ->
    if @_validateAudi() is false
      setTimeout (-> $('#audience .input').focus()), 0
      return
    if @state.audi.length is 0 and $('#audience').text().trim().length > 0
      audi = if @_setAudi() then @_setAudi() else @state.ludi
    else
      audi = @state.audi    
    audi = @addCC audi
    txt = @$message.text().trim().replace(/\xa0/g,' ')
    MessageActions.sendMessage txt,audi
    @$message.text('')
    @setState length:0
    @set()
    @typing false

  onKeyUp: (e) ->
    if not window.urb.util.isURL @$message.text()
      @setState lengthy: (@$message.text().length > 62)
  
  onKeyDown: (e) ->
    if e.keyCode is 13
      txt = @$message.text()
      e.preventDefault()
      if txt.length > 0
        if window.talk.online
          @sendMessage()
        else
          #@errHue = ((@errHue || 0) + (Math.random() * 300) + 30) % 360
          #$('#offline').css color: husl.toHex @errHue, 90, 50 
          $('#offline').addClass('error').one 'transitionend',
            -> $('#offline').removeClass 'error'
      return false
    @onInput()
    @set()

  onInput: (e) ->
    text   = @$message.text()
    length = text.length
    # geturl = new RegExp [
    #  '(^|[ \t\r\n])((ftp|http|https|gopher|mailto|'
    #     'news|nntp|telnet|wais|file|prospero|aim|webcal'
    #  '):(([A-Za-z0-9$_.+!*(),;/?:@&~=-])|%[A-Fa-f0-9]{2}){2,}'
    #  '(#([a-zA-Z0-9][a-zA-Z0-9$_.+!*(),;/?:@&~=%-]*))?'
    #  '([A-Za-z0-9$_+!*();/?:~-]))'
    #                      ].join() , "g"
    # urls = text.match(geturl)
    # if urls isnt null and urls.length > 0
    #   for url in urls
    #     length -= url.length
    #     length += 10
    @setState {length}

  _validateAudiPart: (a) ->
    a = a.trim()
    # if a[0] isnt "~"
    #   return false
    if a.indexOf("/") isnt -1
      _a = a.split("/")
      if _a[1].length is 0
        return false
      ship = _a[0]
    else
      ship = a
     
    return (SHIPSHAPE.test ship) and 
      _.all (ship.match /[a-z]{3}/g), (a)-> -1 isnt PO.indexOf a

  _validateAudi: ->
    v = $('#audience .input').text()
    v = v.trim()
    if v.length is 0 
      return true
    if v.length < 5 # zod/a is shortest
      return false
    _.all (v.split /\ +/), @_validateAudiPart

  _setAudi: ->
    valid = @_validateAudi()
    StationActions.setValidAudience valid
    if valid is true
      stan = $('#audience .input').text() || util.mainStationPath window.urb.user
      stan = (stan.split /\ +/).map (v)->
        if v[0] is "~" then v else "~"+v
      StationActions.setAudience stan
      stan
    else
      false

  getTime: ->
    d = new Date()
    seconds = d.getSeconds()
    if seconds < 10
      seconds = "0" + seconds
    "~"+d.getHours() + "." + d.getMinutes() + "." + seconds

  cursorAtEnd: ->
    range = document.createRange()
    range.selectNodeContents @$message[0]
    range.collapse(false)
    selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(range)

  componentDidMount: ->
    util.sendMessage = @sendMessage
    StationStore.addChangeListener @_onChangeStore
    MessageStore.addChangeListener @_onChangeStore
    @$el = $ ReactDOM.findDOMNode @
    @$message = $('#message .input')
    @$message.focus()
    if @get() 
      @$message.text @get()
      @onInput()
    @interval = setInterval =>
        @$el.find('.time').text @getTime()
      , 1000

  componentWillUnmount: ->
    StationStore.removeChangeListener @_onChangeStore
    clearInterval @interval

  _onChangeStore: -> @setState @stateFromStore()

  render: ->
    user = "~"+window.urb.user
    iden = StationStore.getMember(user)
    ship = if iden then iden.ship else user
    name = if iden then iden.name else ""

    audi = if @state.audi.length is 0 then @state.ludi else @state.audi
    audi = util.clipAudi audi
    for k,v of audi
      audi[k] = v.slice(1)

    div {className:'writing',key:'writing'},
      (React.createElement Audience, {
        audi
        valid:@state.valid
        validate:@_validateAudi
        onBlur:@_setAudi })
      (div {className:'message',id:'message',key:'message'}, 
        (div {
          className:'input'
          contentEditable:true
          onPaste: @onInput
          @onInput, @onFocus, @onBlur, @onKeyDown, @onKeyUp
          dangerouslySetInnerHTML: __html: ""
        })
      )
      (div {className:'length',key:'length'}, "#{@state.length}/64 (#{Math.ceil @state.length / 64})")
