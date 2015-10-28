{PromiseSocketServer, PromiseSocketClient} = require("../src/socket.coffee")

PORT = 9834
HOST = "127.0.0.1"
ENCODING = 'utf-8'

describe "Socket", () ->
  server = null

  client_a = null
  client_b = null
  client_c = null

  payload_a = new Buffer('a', 'utf8')
  payload_b = new Buffer('b', 'utf8')
  payload_c = new Buffer('c', 'utf8')

  beforeEach () ->
    server = new PromiseSocketServer(PORT, HOST, ENCODING)
    client_a = new PromiseSocketClient(HOST, PORT, ENCODING)
    client_b = new PromiseSocketClient(HOST, PORT, ENCODING)
    client_c = new PromiseSocketClient(HOST, PORT, ENCODING)

  afterEach () ->
    client_a.close()
    client_b.close()
    client_c.close()
    server.close()


  describe "Server", () ->
    it "should get client which connected after getNext", () ->
      next = null

      server.listen().then () ->
        next = server.nextSocket()
        return client_a.connect()
      .then () ->
        return next
      .then () ->
        server.empty().should.be.true

    it "should get client which connected before getNext", () ->
      next = null

      server.listen().then () ->
        return client_a.connect()
      .then () ->
        return server.nextSocket()
      .then () ->
        server.empty().should.be.true

    it "should get multiple client which connected before getNext", () ->
      next = null

      server.listen().then () ->
        return Promise.all([
          client_a.connect()
          client_b.connect()
          client_c.connect()
        ])
      .then () ->
        return Promise.all([
         server.nextSocket()
         server.nextSocket()
         server.nextSocket()
        ])
      .then () ->
        server.empty().should.be.true

    it "should get clients in right order", () ->
      server.listen().then () ->
        return client_a.connect()
      .then () ->
        return client_b.connect()
      .then () ->
        return Promise.all([
          client_a.send(payload_a)
          client_b.send(payload_b)
        ])
      .then () ->
        return Promise.all([
          server.nextSocket().then (socket) ->
            return socket.recv().should.eventually.become(payload_a)
          server.nextSocket().then (socket) ->
            return socket.recv().should.eventually.become(payload_b)
        ])
      .then () ->
        server.empty().should.be.true


  describe 'Client', () ->

    it "should connect to server", () ->
      server.listen().then () ->
        return client_a.connect()

    it "should be able to send and receive data", () ->
      server_socket = null

      server.listen().then () ->
        client_a.connect()
        return server.nextSocket()
      .then (socket) ->
        server_socket = socket

        return Promise.all([
          client_a.send(payload_a)
          server_socket.send(payload_b)
        ])
      .then () ->
        return Promise.all([
          client_a.recv().should.eventually.become(payload_b)
          server_socket.recv().should.eventually.become(payload_a)
        ])


  describe 'Client', () ->

    it "should connect to server", () ->
      server.listen().then () ->
        return client_a.connect()
