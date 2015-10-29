net = require('net')

{Promisify, Promise} = require('./promisify')


###*
# A promise wrapper around network sockets. It receives `Buffer` and can send
# `Buffer` and `String`.
#
# If you want to connect to a server use `PromiseSocketClient` and if you want
# to create a server use `PromiseSocketServer`.
#
# @class PromiseSocket
# @extend Promisify
#
# @constructor
# @param socket {net.Socket} The underlying socket
###
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


###*
# A promise wrapper around an outgoing TCP connection.
#
# @class PromiseSocketClient
# @extend PromiseSocket
#
# @constructor
# @param address {String} The host to connect to
# @param port {Integer} The port to connect to
###
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


###*
# A promise base TCP server
#
# @class PromiseSocketServer
#
# @constructor
# @param port {Integer} The port to bind to
# @param host {String} The host to bind to
###
class exports.PromiseSocketServer


  constructor: (@port, @host) ->
    @_incoming = []
    @_waiting = []


  ###*
  # Start listening for incoming sockets
  # @method listen
  # @return {Promise} Promise which will be resolved once the server listens
  ###
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


  ###*
  # Get the next which connects to the server
  # @method nextSocket
  # @return {Promise} Promise of the next socket
  ###
  nextSocket: () ->
    if @_incoming.length > 0
      return Promise.resolve(@_incoming.shift())
    else
      return new Promise (resolve, reject) =>
        @_waiting.push({resolve: resolve, reject: reject})


  ###*
  # Close the server
  # @method close
  ###
  close: () ->
    if @server?
      @server.close()
      delete server

    return Promise.resolve()


  ###*
  # Check whether there are pending incoming connections
  # @return {Boolean} `true` if there are no incoming sockets in the queue
  ###
  empty: () ->
    return @_incoming.length == 0

