util = require '../util.coffee'

window.urb.appl = "talk"
send = (data,cb)-> window.urb.send data, {mark:"talk-command"}, cb
design = (party,config,cb)-> send {design:{party,config}}, cb
  
module.exports = ({StationActions})->
  createStation: (name,cb) ->
    design name, {
      sources:[]
      caption:""
      cordon: posture:"white", list:[]
    }, cb

  removeStation: (name,cb) -> design name, null, cb
  setSources: (station,ship,sources) ->
    cordon = posture:"black", list:[]
    design station, {sources,cordon,caption:""}, (err,res) ->
      console.log 'talk-command'
      console.log arguments

  listen: -> window.urb.bind "/", (err,res) ->
    if err or not res.data
      console.log '/ err'
      console.log err
      return
    console.log '/'
    console.log res.data
    {house} = res.data # one of
    if house
      StationActions.loadStations res.data.house

  listenStation: (station) ->
    path = (util.talkPath {'a_group','v_glyph','x_cabal'}, station)
    window.urb.bind path, (err,res) ->
      if err or not res
        console.log path, 'err'
        console.log err
        return
      console.log(path)
      console.log(res.data)
      {ok,group,cabal,glyph} = res.data # one of
      switch
        when ok
          StationActions.listeningStation station
        when group
          group.global[util.mainStationPath(window.urb.user)] =
            group.local
          StationActions.loadMembers group.global
        when cabal?.loc
          StationActions.loadConfig station,cabal.loc
        when glyph
          StationActions.loadGlyphs glyph
