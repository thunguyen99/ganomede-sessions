restify = require 'restify'
authdb = require 'authdb'
config = require '../../config'

module.exports = (options) ->
  #
  # Initialization
  #

  authdbClient = options.authdbClient || authdb.createClient(
    host: config.authdb.host
    port: config.authdb.port)

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

  #
  # Routes
  #

  retrieveGame = (req, res, next) ->
    next(new restify.NotImplementedError)

  retrieveMoves = (req, res, next) ->
    next(new restify.NotImplementedError)

  addMove = (req, res, next) ->
    next(new restify.NotImplementedError)

  return (prefix, server) ->
    # Single Game
    server.get "/#{prefix}/auth/:token/games/:id",
      authMiddleware, retrieveGame
    server.get "/#{prefix}/auth/:token/games/:id/moves",
      authMiddleware, retrieveMoves
    server.post "/#{prefix}/auth/:token/games/:id/moves",
      authMiddleware, addMove

    # TODO:
    # Game Collection

# vim: ts=2:sw=2:et:
