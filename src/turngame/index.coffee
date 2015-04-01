restify = require 'restify'
authdb = require 'authdb'
redis = require 'redis'
config = require '../../config'
Games = require './games'

module.exports = (options={}) ->
  #
  # Initialization
  #

  authdbClient = options.authdbClient || authdb.createClient(
    host: config.authdb.host
    port: config.authdb.port)

  games = options.games || new Games(
    redis.createClient(config.redis.port, config.redis.host)
    config.redis.prefix
  )

  #
  # Middlewares
  #

  # Populates req.params.user with value returned from authDb.getAccount()
  authMiddleware = (req, res, next) ->
    authToken = req.params.authToken
    if !authToken
      return next(new restify.InvalidContentError('invalid content'))

    authdbClient.getAccount authToken, (err, account) ->
      if err || !account
        if err
          log.error 'authdbClient.getAccount() failed',
            err: err
            token: authToken
        return next(new restify.UnauthorizedError('not authorized'))

      req.params.user = account
      next()

  # Populates req.params.game with game's state based in req.params.gameId
  retrieveGameMiddleware = (req, res, next) ->
    gameId = req.params.gameId
    if !gameId
      return next(new restify.InvalidContentError('invalid content'))

    games.state gameId, (err, state) ->
      if (err)
        return next(new restify.InternalServerError)

      if (!state)
        return next(new restify.NotFoundError)

      req.params.game = state
      next()

  #
  # Routes
  #

  retrieveGame = (req, res, next) ->
    res.json(req.params.game)

  retrieveMoves = (req, res, next) ->
    next(new restify.NotImplementedError)

  addMove = (req, res, next) ->
    next(new restify.NotImplementedError)

  return (prefix, server) ->
    # Single Game
    server.get "/#{prefix}/auth/:authToken/games/:gameId",
      authMiddleware, retrieveGameMiddleware, retrieveGame
    server.get "/#{prefix}/auth/:authToken/games/:gameId/moves",
      authMiddleware, retrieveMoves
    server.post "/#{prefix}/auth/:authToken/games/:gameId/moves",
      authMiddleware, addMove

    # TODO:
    # Game Collection

# vim: ts=2:sw=2:et:
