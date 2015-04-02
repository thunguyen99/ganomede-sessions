supertest = require 'supertest'
fakeRedis = require 'fakeredis'
expect = require 'expect.js'
vasync = require 'vasync'
api = require '../../src/turngame'
Games = require '../../src/turngame/games'
config = require '../../config'
server = require '../../src/server'
fakeAuthDb = require '../fake-authdb'
samples = require './sample-data'

users = samples.users
game = samples.game
moves = samples.moves

describe "turngame-api", ->
  redis = fakeRedis.createClient(__filename)
  authdb = fakeAuthDb.createClient()
  games = new Games(redis, config.redis.prefix)
  go = supertest.bind(supertest, server)

  endpoint = (path) ->
    return "/#{config.routePrefix}#{path || ''}"

  before (done) ->
    for own username, accountInfo of users
      authdb.addAccount accountInfo.token, accountInfo

    turngame = api
      authdbClient: authdb
      games: games

    turngame(config.routePrefix, server)

    # add game and moves to redis, listen on port
    vasync.parallel
      funcs: [
        server.listen.bind(server)
        games.setState.bind(games, game.id, game)
        (cb) -> vasync.forEachParallel
          func: games.addMove.bind(games, game.id)
          inputs: moves
        , cb
      ], done

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

      it 'requires valid authToken', (done) ->
        go()
          .get endpoint("/auth/invalid-token/games/#{game.id}")
          .expect 401, done

      it 'only game participants are allowed', (done) ->
        go()
          .get endpoint("/auth/#{users.jdoe.token}/games/#{game.id}")
          .expect 403, done

      it 'replies with http 404 if game was not found', (done) ->
        go()
          .get endpoint("/auth/#{users.jdoe.token}/games/bad-#{game.id}")
          .expect 404, done

    describe 'GET /auth/:token/games/:id/moves', () ->
      it 'retrieves moves made in a game', (done) ->
        go()
          .get endpoint("/auth/#{users.alice.token}/games/#{game.id}/moves")
          .expect 200
          .end (err, res) ->
            expect(err).to.be(null)
            expect(res.body).to.eql(moves)
            done()

      it 'requires valid authToken', (done) ->
        go()
          .get endpoint("/auth/invalid-token/games/#{game.id}/moves")
          .expect 401, done

      it 'only game participants are allowed', (done) ->
        go()
          .get endpoint("/auth/#{users.jdoe.token}/games/#{game.id}/moves")
          .expect 403, done

      it 'replies with http 404 if game was not found', (done) ->
        go()
          .get endpoint("/auth/#{users.jdoe.token}/games/bad-#{game.id}/moves")
          .expect 404, done

    describe 'POST /auth/:token/games/:id/moves', () ->
      it 'adds move to a game'

# vim: ts=2:sw=2:et:
