module.exports =
  users:
    'alice': {username: 'alice', token: 'alice-token'}
    'bob': {username: 'bob', token: 'bob-token'}

  game:
    id: 'game-id'
    type: 'multiplayer-substract-game/v1'
    players: ['alice', 'bob']
    turn: 'alice'
    status: 'active'
    gameData:
      current: 100
