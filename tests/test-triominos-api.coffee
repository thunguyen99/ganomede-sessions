assert = require "assert"
api = require "../src/triominos-api"

fakeRestify = require "./fake-restify"
server = fakeRestify.createServer()

describe "triominos-api", ->

  before ->
    api.addRoutes "triominos", server

  it "should have post games and moves routes", ->
    assert.ok server.routes.post["/triominos/games"]
    assert.ok server.routes.post["/triominos/moves"]

# vim: ts=2:sw=2:et:
