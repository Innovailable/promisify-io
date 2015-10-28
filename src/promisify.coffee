{EventEmitter} = require('events')
exports.Promise = Promise = global.Promise || require('es6-promise').Promise

class exports.Promisify

  constructor: () ->
    @_incoming = []
    @_waiting = []


  recv: () ->
    return @connect().then () =>
      if @_incoming.length > 0
        return Promise.resolve(@_incoming.shift())
      else
        return new Promise (resolve, reject) =>
          @_waiting.push({resolve: resolve, reject: reject})


  sendRecv: (data) ->
    @send(data).then () =>
      return @recv()


  send: (data) ->
    @connect().then () =>
      @_send(data)


  close: () ->
    @_close()


  connect: () ->
    if not @connect_p?
      @connect_p = @_connect()

    return @connect_p


  _receiving: (data) ->
    if @_waiting.length > 0
      @_waiting.shift().resolve(data)
    else
      @_incoming.push(data)


  _closed: () ->
    while @_waiting.length > 0
      @_waiting.shift().reject(new Error("Connection was closed"))


  _connect: () ->
    throw new Error("Not implemented")


  _send: (data) ->
    throw new Error("Not implemented")


  _close: () ->
    throw new Error("Not implemented")
