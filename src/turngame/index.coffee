restify = require 'restify'

module.exports = (options) ->
  postGame = (req, res, next) ->
    next(new restify.NotImplementedError)
    next()

  postMove = (req, res, next) ->
    next(new restify.NotImplementedError)
    next()

  return (prefix, server) ->
    server.post "/#{prefix}/games", postGame
    server.post "/#{prefix}/moves", postMove

# vim: ts=2:sw=2:et:
