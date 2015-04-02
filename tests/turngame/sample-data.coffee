users =
  'alice': {username: 'alice', token: 'alice-token'}
  'bob': {username: 'bob', token: 'bob-token'}
  'jdoe': {username: 'jdoe', token: 'jdoe-token'}

game =
  id: 'game-id'
  type: 'multiplayer-substract-game/v1'
  players: ['alice', 'bob']
  turn: 'alice'
  status: 'active'
  gameData:
    current: 100

moves = [
  {player: game.players[0], move: {data: 'move-0-data'}}
]

module.exports =
  users: users
  game: game
  moves: moves
