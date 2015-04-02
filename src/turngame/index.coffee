restify = require 'restify'
authdb = require 'authdb'
redis = require 'redis'
urllib = require 'url'
config = require '../../config'
log = require '../log'
Games = require './games'
RulesClient = require './rules-client'

clone = (obj) -> JSON.parse(JSON.stringify(obj))

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

  # Checks that user is participant in req.params.game. Sends 403 otherwise.
  participantsOnly = (req, res, next) ->
    participant = 0 <= req.params.game.players.indexOf(req.params.user.username)
    if participant then next() else next(new restify.ForbiddenError)

  #
  # Routes
  #

  retrieveGame = (req, res, next) ->
    res.json(req.params.game)

  retrieveMoves = (req, res, next) ->
    games.moves req.params.game.id, (err, moves) ->
      if (err)
        return next(new restify.InternalServerError)

      res.json(moves)
      next()

  # Checks move req.body.moveData via RulesService and in case it is valid,
  # populates req.params.newGameState and calls next().
  verifyMove = (req, res, next) ->
    game = clone(req.params.game)
    game.moveData = req.body.moveData
    rules = new RulesClient restify.createJsonClient(
      url: urllib.format
        protocol: 'http'
        hostname: config.rules.host
        port: config.rules.port
        pathname: game.type
    )

    rules.moves game, (err, rulesErr, newState) ->
      if (err)
        # Something's wrong with HTTP request, not necessarily move itself.
        return next(new restify.InternalServerError)

      if (rulesErr)
        # Request finished, but move was rejected by Rules Service;
        # rulesErr is a restify.RestError returned by rules services,
        # just forward that to client.
        unless rulesErr instanceof restify.RestError
          log.warn 'addMove(): RulesClient.moves() returned Rules Error of
                    unexpected type', {rulesErr: rulesErr}
        return next(rulesErr)

      # Save this info for later
      req.params.newGameState = newState
      req.params.newMove =
        player: game.turn
        move: game.moveData

      next()

  addMove = (req, res, next) ->
    newState = req.params.newGameState
    move = req.params.newMove

    games.addMove newState.id, newState, move, (err) ->
      if (err)
        return next(new restify.InternalServerError)

      res.json(newState)
      next()

  return (prefix, server) ->
    # Single Game
    server.get "/#{prefix}/auth/:authToken/games/:gameId",
      authMiddleware, retrieveGameMiddleware, participantsOnly, retrieveGame
    server.get "/#{prefix}/auth/:authToken/games/:gameId/moves",
      authMiddleware, retrieveGameMiddleware, participantsOnly, retrieveMoves
    server.post "/#{prefix}/auth/:authToken/games/:gameId/moves",
      authMiddleware, retrieveGameMiddleware, verifyMove, addMove

    # TODO:
    # Game Collection

# vim: ts=2:sw=2:et:
