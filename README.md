# promisify-io

## What is this?

This library makes input/output operations use promises as much as possible.
It can be used to make tests including many input/ouptut operations easier to
write and maintain. It is not optimized for performance and should not be used
in production code.

## How to install?

To install just run

    npm install promisify-io

and then use with

    var pio = require("promisify-io");

## How to use?

When doing tests on sockets or other stream based input/output devices you might
run into the problem that your control flow gets complex and convoluted because
the APIs are event based and you have to react different for each message.

With `promisify-io` you can use promises to `send()` and `recv()` data. This
lets you use the data wherever you need it without having to create complex
structures.  Here is an example

    socket.send("hello").then(function() {
      return socket.recv();
    }).then(function(data) {
      console.log(data);
    });

The method `sendRecv()` even lets you send and receive data in one step.

Here is a test for an echo server using `mocha`, `chai` and `chai-as-promised`.

    describe("Echo", function() {
      var socket = new PromiseSocketClient("localhost", 4321);
      it("should receive the same data which was sent", function() {
       return socket.connect().then(function() {
          return socket.sendRecv("hello");
        }).then(function(data) {
          data.should.deep.equal("hello");
          return socket.sendRecv("world")
        }).then(function(data) {
          data.should.deep.equal("world");
        });
      });
    });

