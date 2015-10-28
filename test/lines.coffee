{Promise} = require('../src/promisify')
{PromiseLines} = require('../src/lines')
{PromiseTest} = require('./helper')

describe 'Lines', () ->
  
  it 'should write data seperated by newline', () ->
    test = new PromiseTest()
    lines = new PromiseLines(test)

    sending = ["abc", "def", "ghi"]

    Promise.all([lines.send(data) for data in sending]).then () ->
      sent = ""
      
      # TODO: why does Array.join() not work here ...
      for raw in test.buffer
        sent += raw.toString('utf8')

      expected = sending.join('\n') + '\n'

      sent.should.deep.equal(expected)

  it 'should split incoming data by newline', () ->
    test = new PromiseTest()
    lines = new PromiseLines(test)

    test.push(new Buffer('hello\nworld\n', 'utf8'))

    Promise.all([lines.recv(), lines.recv()]).should.become(["hello", "world"])

  it 'should split incoming data between sends by newline', () ->
    test = new PromiseTest()
    lines = new PromiseLines(test)

    for data in ['hel', 'lo\n', 'world', '\n!', '\n']
      test.push(new Buffer(data, 'utf8'))

    Promise.all([lines.recv(), lines.recv(), lines.recv()]).should.become(["hello", "world", "!"])

