net = require('net')

{Promisify, Promise} = require('./promisify')


class exports.PromiseSocket extends Promisify

  constructor: (@socket) ->
    super()

    if @socket?
      @_had_socket = true
      @_setup_socket()


  _connect: () ->
    if @_had_socket
      return Promise.resolve()
    else
      return Promise.reject(new Error("Pass a socket to the constructor or use PromiseSocketClient"))


  _setup_socket: () ->
    @socket.on 'close', () =>
      delete @socket
      @_closed()

    @socket.on 'data', (data) =>
      @_receiving(data)


  _send: (data) ->
    if @socket?
      new Promise (resolve, reject) =>
        @socket.write(data, resolve)
    else
      return Promise.reject(new Error("Socket not open"))


  _close: () ->
    if @socket?
      @socket.end()
      return Promise.resolve()
    else
      return Promise.reject(new Error("Socket not open"))


class exports.PromiseSocketClient extends exports.PromiseSocket

  constructor: (@address, @port) ->
    super()


  _connect: () ->
    new Promise (resolve, reject) =>
      @socket = new net.Socket()

      @socket.on 'connect', () =>
        resolve()

      @socket.on 'error', (err) =>
        reject(err)

      @_setup_socket()

      @socket.connect(@port, @address)


class exports.PromiseSocketServer


  constructor: (@port, @host) ->
    @_incoming = []
    @_waiting = []


  listen: () ->
    if not @_listen_p
      @_listen_p = new Promise (resolve, reject) =>
        @server = net.createServer()

        @server.on 'listening', () =>
          resolve()

        @server.on 'error', (err) =>
          reject(err)

        @server.on 'connection', (socket) =>
          promise_socket = new exports.PromiseSocket(socket)

          if @_waiting.length > 0
            @_waiting.shift().resolve(promise_socket)
          else
            @_incoming.push(promise_socket)

        @server.listen(@port, @host)

    return @_listen_p


  nextSocket: () ->
    if @_incoming.length > 0
      return Promise.resolve(@_incoming.shift())
    else
      return new Promise (resolve, reject) =>
        @_waiting.push({resolve: resolve, reject: reject})


  close: () ->
    if @server?
      @server.close()
      delete server


  empty: () ->
    return @_incoming.length == 0

