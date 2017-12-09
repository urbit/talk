util = require '../util.coffee'

window.urb.appl = "hall"
send = (data,cb)-> window.urb.send data, {mark:"hall-action"}, cb

module.exports = ({MessageActions}) ->
  listenStation: (station,since) ->
    $this = this
    begin = window.urb.util.toDate(since)
    path = (util.talkPath 'circle', station, 'grams', begin)
    window.urb.bind path, (err,res) ->
        if err or not res.data
          console.log path, 'err!'
          console.log err
          console.log res
          $this.listenStation station,since
          return
        if res.data.ok is true
          MessageActions.listeningStation station
        if res.data?.circle?.nes # prize
          if (res.data.circle.nes.length == 0)
            window.urb.drop path, (err,res) ->
              console.log err if err
            console.log 'trying for older than ' + begin
            $this.listenStation(station, new Date(since - 6*3600*1000))
          else
            res.data.circle.nes.map (env) ->
              env.gam.heard = true
              env
            MessageActions.loadMessages res.data.circle.nes
        if res.data?.circle?.gram # rumor (new msg)
          res.data.circle.gram.gam.heard = true
          MessageActions.loadMessages [res.data.circle.gram]

  get: (station,start,end) ->
    end   = window.urb.util.numDot end
    start = window.urb.util.numDot start
    path = (util.talkPath 'circle', station, 'grams', end, start)
    window.urb.bind path, (err,res) ->
      if err or not res.data
        console.log path, '/circle err'
        console.log err
        return
      if res.data?.circle?.nes
        res.data.circle.nes.map (env) ->
          env.gam.heard = true
          env
        MessageActions.loadMessages res.data.circle.nes
        window.urb.drop path, (err,res) ->
          console.log 'done'
          console.log res

  sendMessage: (message,cb) ->
    send {convey: [message]}, (err,res) ->
      console.log 'sent'
      console.log arguments
      cb(err,res) if cb
