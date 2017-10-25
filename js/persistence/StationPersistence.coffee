util = require '../util.coffee'

window.urb.appl = "talk-guardian"
send = (data,cb)-> window.urb.send data, {mark:"talk-action"}, cb
create = (nom,des,sec,cb)-> send {create:{nom,des,sec}}, cb
remove = (nom,why,cb)-> send {delete:{nom,why}}, cb
source = (nom,sub,srs,cb)-> send {source:{nom,sub,srs}}, cb

subscribed = {}
module.exports = ({StationActions})->
  createStation: (name,cb) ->
    create name, "", "black", cb

  removeStation: (name,cb) -> remove name, null, cb

  modSources: (station,sub,sources) ->
    source station, sub, sources, (err,res) ->
      console.log 'talk-action'
      console.log arguments
  addSources: (station,sources) -> modSources station, true, sources
  remSources: (station,sources) -> modSources station, false, sources

  #TODO
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

  #TODO
  listenStation: (station,{group,glyph,cabal}) ->
    subscribed[station] ?= {}
    types = {a_group:group,v_glyph:glyph,x_cabal:cabal}
    for k of types
      if subscribed[station][k]
        delete types[k]
      else subscribed[station][k] = types[k]
    return if _.isEmpty types
    path = (util.talkPath types, station)
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
