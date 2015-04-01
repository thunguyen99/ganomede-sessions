api = require "../../src/turngame"
config = require '../../config'

describe "turngame-api", ->
  describe 'Single Game', () ->
    describe 'GET /auth/:token/games/:id', () ->
      it 'retrieves game state by its ID'

    describe 'PUT /auth/:token/games/:id', () ->
      it 'changes game status from INACTIVE to ACTIVE'
      it 'discrads any other change with HTTP 423'

# vim: ts=2:sw=2:et:
