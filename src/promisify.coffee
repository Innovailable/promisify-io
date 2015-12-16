{EventEmitter} = require('events')
exports.Promise = Promise = global.Promise || require('es6-promise').Promise

###*
# Base class for promise based IO devices.
#
# The type of the data which is sent and received is implementation specific.
# You will most probably use `Buffer` or `String`.
#
# Implementation of actual devices have to use and overwrite the protected
# methods which start with an underscore.
#
# @class Promisify
###
class exports.Promisify

  constructor: () ->
    @_incoming = []
    @_waiting = []

    @_close_p = new Promise (resolve, reject) =>
      @_close_d = { resolve: resolve, reject: reject }


  ###*
  # Receive data from the device
  # @method recv
  # @return {Promise} The data which was read
  ###
  recv: () ->
    return @connect().then () =>
      if @_incoming.length > 0
        return Promise.resolve(@_incoming.shift())
      else
        return new Promise (resolve, reject) =>
          @_waiting.push({resolve: resolve, reject: reject})


  ###*
  # Sends and receives data
  # @method sendRecv
  # @param data The data to be sent
  # @return {Promise} The data which is read
  ###
  sendRecv: (data) ->
    @send(data).then () =>
      return @recv()


  ###*
  # Sends data on the device
  # @method send
  # @param data The data to be sent
  # @return {Promise} Promise which will be resolved once the data was sent
  ###
  send: (data) ->
    @connect().then () =>
      @_send(data)


  ###*
  # Close the device
  # @method close
  # @return {Promise} Promise which will be resolved once the device is closed
  ###
  close: () ->
    @_close()


  ###*
  # Open the connection with the undelying device
  # @method connect
  # @return {Promise} Promise which will be resolved once the device is open
  ###
  connect: () ->
    if not @connect_p?
      @connect_p = @_connect()

    return @connect_p


  awaitClose: () ->
    return @_close_p


  ###*
  # Method to be called by implementation when data is received
  # @method _receiving
  # @protected
  # @param data The date which was received
  ###
  _receiving: (data) ->
    if @_waiting.length > 0
      @_waiting.shift().resolve(data)
    else
      @_incoming.push(data)


  ###*
  # Method to be called by implementation when the device is closing
  # @method _closed
  # @protected
  ###
  _closed: () ->
    while @_waiting.length > 0
      @_waiting.shift().reject(new Error("Connection was closed"))

    @_close_d.resolve()


  ###*
  # Method containing the custom implementation to connect to the device. Actual devices have to overwrite this!
  # @method _connect
  # @return {Promise} Promise which will be resolved when the device is connected. When there is no way to check just return `Promise.resolve()`
  # @protected
  ###
  _connect: () ->
    throw new Error("Not implemented")


  ###*
  # Method containing the custom implementation to send data. Actual devices have to overwrite this!
  # @method _send
  # @return {Promise} Promise which will be resolved when the data is sent. When there is no way to check just return `Promise.resolve()`
  # @protected
  ###
  _send: (data) ->
    throw new Error("Not implemented")


  ###*
  # Method containing the custom implementation to close the device. Actual devices have to overwrite this!
  # @method _close
  # @return {Promise} Promise which will be resolved when the device is closed. When there is no way to check just return `Promise.resolve()`
  # @protected
  ###
  _close: () ->
    throw new Error("Not implemented")
