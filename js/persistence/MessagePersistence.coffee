util = require '../util.coffee'

window.urb.appl = "talk-guardian"
send = (data,cb)-> window.urb.send data, {mark:"talk-action"}, cb

module.exports = ({MessageActions}) ->
  listenStation: (station,since) ->
    console.log 'listen station'
    console.log arguments
    $this = this
    path = (util.talkPath 'circle', station, since)
    window.urb.bind path, (err,res) ->
        if err or not res.data
          console.log path, 'err!'
          console.log err
          console.log res
          $this.listenStation station,since
          return
        console.log(path)
        console.log(res.data)
        if res.data.ok is true
          MessageActions.listeningStation station
        if res.data?.circle?.nes # prize
          res.data.circle.nes.map (env) ->
            env.gam.heard = true
            env
          MessageActions.loadMessages res.data.circle.nes
        if res.data?.circle?.gram # rumor (new msg)
          res.data.circle.gram.gam.heard = true
          MessageActions.loadMessages [res.data.circle.gram]
        # ignore all other rumors, they get handled by StationPersistence

  get: (station,start,end) ->
    end   = window.urb.util.numDot end
    start = window.urb.util.numDot start
    path = (util.talkPath 'circle', station, end, start)
    window.urb.bind path, (err,res) ->
      if err or not res.data
        console.log path, '/circle err'
        console.log err
        return
      if res.data?.circle?.nes
        MessageActions.loadMessages res.data.circle.nes
        window.urb.drop path, (err,res) ->
          console.log 'done'
          console.log res

  sendMessage: (message,cb) ->
    send {convey: [message]}, (err,res) ->
      console.log 'sent'
      console.log arguments
      cb(err,res) if cb
