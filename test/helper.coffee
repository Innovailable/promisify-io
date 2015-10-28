{Promisify} = require('../src/promisify')

class exports.PromiseTest extends Promisify

  constructor: () ->
    super()

    @buffer = []
    @connect_count = 0
    @close_count = 0


  push: (data) ->
    @_receiving(data)


  pull: () ->
    if @buffer.length
      return @buffer.shift()
    else
      throw new Error("No data in buffer")


  _send: (data) ->
    @buffer.push(data)
    return Promise.resolve()


  _connect: () ->
    @connect_count++
    return Promise.resolve()


  _close: () ->
    @close_count++
    return Promise.resolve()
