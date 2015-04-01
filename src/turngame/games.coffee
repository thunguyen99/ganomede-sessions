log = require '../log'

PREFIX_SEPARATOR = ':'

class Games
  constructor: (redis, prefix) ->
    @redis = redis
    @prefix = prefix

  key: (gameId, parts...) ->
    [@prefix, 'games', gameId].concat(parts).join(PREFIX_SEPARATOR)

  setState: (id, state, callback) ->
    @redis.set @key(id), JSON.stringify(state), (err) ->
      if (err)
        log.error 'Games.setState() failed',
          err: err
          id: id
          state: state

      callback(err)

  state: (id, callback) ->
    @redis.get @key(id), (err, json) ->
      if (err)
        log.error 'Games.state() failed',
          err: err
          id: id
        return callback(err)

      callback(null, if json then JSON.parse(json) else null)

  addMove: (id, move) ->
  moves: (id) ->

module.exports = Games
