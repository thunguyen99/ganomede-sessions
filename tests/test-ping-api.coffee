assert = require "assert"
pingApi = require "../src/ping-api"
fakeRestify = require "./fake-restify"
server = fakeRestify.createServer()

describe "ping-api", ->
  it "should have get and head routes", () ->
    pingApi.addRoutes "users", server
    assert.ok server.routes.get["/users/ping/:token"]
    assert.ok server.routes.head["/users/ping/:token"]
    server.request "get", "/users/ping/:token", params: token: "pop"
    assert.equal server.res.body, "pong/pop"
    server.request "head", "/users/ping/:token", params: token: "beep"
    assert.equal server.res.body, "pong/beep"

# vim: ts=2:sw=2:et:
