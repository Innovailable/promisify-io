{Promisify} = require('./promisify')

###*
# A virtual device turning providing a line based interface for other devices.
#
# The underlying device is expected to read and write `Buffer` objects. This
# device reads and writes `String`s.
#
# @class PromiseLines
# @extend Promisify
#
# @example
#     var socket = new pio.PromiseSocketClient("localhost", 4321)
#     var lines = new pio.PromiseLines(socket)
#
#     lines.sendRecv("hello").then(function(data) {
#       console.log(data);
#     });
#
# @constructor
# @param io {Promisify} The underlying device
# @param delimiter {String} The string which splits the messages
# @param encoding {String} Encoding to use
###
class exports.PromiseLines extends Promisify

  constructor: (@io, @delimiter='\n', @encoding='utf-8') ->
    super()

    data = ""

    doRead = () =>
      @io.recv().then (raw) =>
        data = data + raw.toString(@encoding)

        while (index = data.indexOf(@delimiter)) != -1
          @_receiving(data.substr(0, index))
          data = data.substr(index + 1)

        doRead()

    doRead()


  _connect: () ->
    return @io.connect()


  _send: (data) ->
    raw = new Buffer(data + @delimiter, @encoding)
    return @io.send(raw)


  _close: () ->
    return @io.close()
