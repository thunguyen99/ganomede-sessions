Turn-Game
---------

Manage a turn based game session.

Relations
---------

The turn-game module will:

 * Manage the `redis_games` redis database.
 * Perform moves requested by clients using rules-api services, update `redis_games`.
 * Find running rules-api services using the `registry`.
 * Use the `redis_auth` database to check requester identity.

Configuration
-------------

 * `REDIS_AUTH_PORT_6379_TCP_ADDR` - IP of the AuthDB redis
 * `REDIS_AUTH_PORT_6379_TCP_PORT` - Port of the AuthDB redis
 * `REGISTRY_PORT_8000_TCP_ADDR` - IP of the registry service
 * `REGISTRY_PORT_8000_TCP_PORT` - Port of the registry service

API
---

All requests made to the turngame API require an auth token, passed in the request URL.

# Single Game [/turngame/auth/:token/games/:id]

    + Parameters
        + token (string) ... User authentication token
        + id (string) ... ID of the game

## Retrieve a game state [GET]

## response [200] OK

    {
        "id": "ab12345789",
        "type": "triominos/v1",
        "players": [ "some_username_1", "some_username_2" ],
        "turn": "some_username_1",
        "status": "active",
        "gameData": { ... }
    }

Possible status:

 * inactive
 * active
 * over

## Edit a game [PUT]

### body (application/json)

    {
        "status": "active"
    }

## response [200] OK

    {
        "id": "ab12345789",
        "type": "triominos/v1",
        "players": [ "some_username_1", "some_username_2" ],
        "turn": "some_username_1",
        "status": "active",
        "gameData": { ... }
    }

### note

The only change allowed using this method is to change "status" from "inactive" to "active".

# Games Collection [/turngame/auth/:token/games]

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

## Create a game [POST]

### body (application/json)

    {
        "type": "triominos/v1",
        "players": [ "some_username_1", "some_username_2" ]
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

### note

Once status set to "active", the game will appear in the games collection of both player.

# Moves Collection [/turngame/auth/:token/games/:id/moves]

    + Parameters
        + token (string) ... Authentication token
        + id (string) ... ID of the game

## Add a move to a game [POST]

### body (application/json)

    {
        "move": { ... }
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

List of codes will be application dependent.

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

