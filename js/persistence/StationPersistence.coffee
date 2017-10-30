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

  removeStation: (name,cb) -> remove name, 'deleted through webtalk', cb

  modSources: (station,sub,sources) ->
    source station, sub, sources, (err,res) ->
      console.log 'talk-action'
      console.log arguments
  addSources: (station,sources) -> modSources station, true, sources
  remSources: (station,sources) -> modSources station, false, sources

  listen: ->
    # we use a far future date in the path so we don't receive grams here
    date = window.urb.util.toDate (new Date())
    window.urb.bind '/reader', (err,res) ->
      if err or not res.data
        console.log 'sp err'
        console.log err
        return
      {gys,nis} = res.data.reader
      StationActions.loadGlyphs gys
      #TODO loadNicks?

  listenStation: (station) ->
    subscribed[station] ?= {}
    path = (util.talkPath 'circle', station, '0')
    window.urb.bind path, (err,res) ->
      if err or not res
        console.log path, 'err'
        console.log err
        return
      console.log(path)
      console.log(res.data)
      #TODO 'new'?
      {cos,pes,config,status} = res.data.circle # one of
      if res.data.ok
        StationActions.listeningStation station
      switch
        when cos # prize, configs
          StationActions.loadConfig station,cos.loc
        when pes # prize, presence
          StationActions.loadMembers station,pes.loc
        when config # rumor, config
          if config.dif.source?
            if config.dif.source.add
              StationActions.addStation config.dif.source.src
            else
              StationActions.remStation config.dif.source.src
        when status # rumor, presence
          #TODO
          break

        # when group
        #   group.global[util.mainStationPath(window.urb.user)] =
        #     group.local
        #   StationActions.loadMembers group.global
        # when cabal?.loc
        #   StationActions.loadConfig station,cabal.loc
        # when glyph
        #   StationActions.loadGlyphs glyph
