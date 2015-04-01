api = require "../../src/turngame"
config = require '../../config'

describe "turngame-api", ->
  describe 'Single Game', () ->
    describe 'GET /auth/:token/games/:id', () ->
      it 'retrieves game state by its ID'

    describe 'GET /auth/:token/games/:id/moves', () ->
      it 'retrieves moves made in a game'

    describe 'POST /auth/:token/games/:id/moves', () ->
      it 'adds move to a game'

# vim: ts=2:sw=2:et:
