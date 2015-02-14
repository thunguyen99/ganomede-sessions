Turn-Game
---------

Manage a turn based game session.

Relations
---------

The turn-game module will:

 * Manage in-progress games in the `redis_games` redis database.
 * Perform moves requested by clients using rules-api services, update `redis_games`.
 * Archive finished games in `couch_games`.
 * Use the `redis_auth` database to check requester identity.

Configuration
-------------

 * `REDIS_AUTH_PORT_6379_TCP_ADDR` - IP of the AuthDB redis
 * `REDIS_AUTH_PORT_6379_TCP_PORT` - Port of the AuthDB redis
 * `REDIS_GAMES_PORT_6379_TCP_ADDR` - IP of the games redis
 * `REDIS_GAMES_PORT_6379_TCP_PORT` - Port of the games redis
 * `COUCH_GAMES_PORT_5984_TCP_ADDR` - IP of the games couchdb
 * `COUCH_GAMES_PORT_5984_TCP_PORT` - Port of the games couchdb

API
---

All requests made to the turngame API require an auth token, passed in the request URL.

# Single Game [/turngame/v1/auth/:token/games/:id]

    + Parameters
        + token (string) ... User authentication token
        + id (string) ... ID of the game

## Retrieve a game state [GET]

### response [200] OK

    {
        "id": "ab12345789",
        "type": "triominos/v1",
        "players": [ "some_username_1", "some_username_2" ],
        "turn": "some_username_1",
        "status": "active",
        "gameData": { ... }
    }

Possible status:

 * `inactive`
 * `active`
 * `gameover`

### design note

The game should be retrieved from the redis database, if not present then we will look in the couchdb database.

## Edit a game [PUT]

### body (application/json)

    {
        "status": "active"
    }

### response [200] OK

    {
        "id": "ab12345789",
        "type": "triominos/v1",
        "players": [ "some_username_1", "some_username_2" ],
        "turn": "some_username_1",
        "status": "active",
        "gameData": { ... }
    }

### response [423] Locked

### design note

The only change allowed using this method is to change "status" from "inactive" to "active". Will reply with status 423 otherwise.

# Games Collection [/turngame/v1/auth/:token/games]

    + Parameters
        + token (string) ... User authentication token

## List games [GET]

List all the "active" games of the authenticated player.

### response [200] OK

    [{
        "id": "1234",
        "type": "triominos/v1",
        "players": [ "some_username", "other_username" ],
        "turn": "some_username",
        "status": "active"
    }, {
        "id": "1235",
        "type": "triominos/v1",
        "players": [ "some_username", "amigo" ],
        "turn": "amigo",
        "status": "active"
    }]

### design note

Active games will all be in the redis database. CouchDB only contains games with status=`gameover`.

## Create a game [POST]

Use the appropriate `rules-api` service to initiate a new game.

### body (application/json)

    {
        "type": "triominos/v1",
        "players": [ "some_username_1", "some_username_2" ],
        "gameConfig": {
            ... game specific data to be passed to the rules-api ...
        }
    }

### response [200] OK

    {
        "id": "1234",
        "type": "triominos/v1",
        "players": [ "some_username", "other_username" ],
        "turn": "some_username",
        "status": "inactive",
        "gameData": {
            ... game specific data ...
        }
    }

### design notes

Only when status set to "active", the game will appear in the games collection of both player.

Until then, it's waiting for activation... Hopefully it should be listed in the players' invitations.

Inactive games will have an expiry date of 1 month.

# Moves Collection [/turngame/v1/auth/:token/games/:id/moves]

    + Parameters
        + token (string) ... Authentication token
        + id (string) ... ID of the game

## Add a move to a game [POST]

### body (application/json)

    {
        "moveData": { ... }
    }

### response [200] OK

    {
        "id": "string",
        "type": "triominos/v1",
        "players": [ "some_username", "other_username" ],
        "turn": "other_username",
        "status": "active",
        "gameData": {
            ... game specific data ...
        },
        "moveResult" {
            ... game specific data ...
        }
    }

### response [400] Bad Request

    {
        "code": "InvalidPosition"
    }

List of codes will be application dependent, as returned by the `rules-api`

### design note

This call will use the rules-api to perform a move, update the redis database if it was accepted, send the result to the user.

Additionally, if the game state was changed from "active" to "gameover", the game should be archived in the CouchDB database.

## List moves made on the given game [GET]

### response [200] OK

    [
        {
            "player": "some_username",
            "move": { ... }
        },
        {
            "player": "other_username",
            "move": { ... }
        },
        {
            "player": "some_username",
            "move": { ... }
        }
    ]

### design note

It's a similar logic than that of the GET single game call. Check redis first, then couchdb.

Having the list of moves at a different endpoint is an optimisation, because this list of moves may be quite long and is in only usefull to view a replay of a previous game.
