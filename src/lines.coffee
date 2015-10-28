{Promisify} = require('./promisify')

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
