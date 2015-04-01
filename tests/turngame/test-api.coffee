supertest = require 'supertest'
fakeRedis = require 'fakeredis'
expect = require 'expect.js'
api = require '../../src/turngame'
Games = require '../../src/turngame/games'
config = require '../../config'
server = require '../../src/server'
fakeAuthDb = require '../fake-authdb'
samples = require './sample-data'

users = samples.users
game = samples.game

describe "turngame-api", ->
  redis = fakeRedis.createClient(__filename)
  authdb = fakeAuthDb.createClient()
  games = new Games(redis, config.redis.prefix)
  go = supertest.bind(supertest, server)

  endpoint = (path) ->
    return "/#{config.routePrefix}#{path || ''}"

  before (done) ->
    for own username, accountInfo of samples.users
      authdb.addAccount accountInfo.token, accountInfo

    turngame = api
      authdbClient: authdb
      games: games

    turngame(config.routePrefix, server)

    # add game to redis, listen on port
    addGame = games.setState.bind(games, samples.game.id, samples.game, done)
    server.listen(addGame)

  after (done) ->
    server.close(redis.flushdb.bind(redis, done))

  describe 'Single Game', () ->
    describe 'GET /auth/:token/games/:id', () ->
      it 'retrieves game state by its ID', (done) ->
        go()
          .get endpoint("/auth/#{users.alice.token}/games/#{game.id}")
          .expect 200
          .end (err, res) ->
            expect(err).to.be(null)
            expect(res.body).to.eql(game)
            done()

    describe 'GET /auth/:token/games/:id/moves', () ->
      it 'retrieves moves made in a game'

    describe 'POST /auth/:token/games/:id/moves', () ->
      it 'adds move to a game'

# vim: ts=2:sw=2:et:
