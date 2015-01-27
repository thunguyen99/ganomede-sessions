Turn-Game
---------

Manage a turn based game session.

Relations
---------

The turn-game module will:

 * Manage the `couch_games` CouchDB database.
 * Perform moves requested by clients using rules-api services, update `couch_games`.
 * Find running rules-api services using the `redis_registry`.
 * Use the `redis_auth` database to check requester identity.

Configuration
-------------

 * `GANOMEDE_REDIS_AUTH_PORT_6379_TCP_ADDR` - IP of the AuthDB redis
 * `GANOMEDE_REDIS_AUTH_PORT_6379_TCP_PORT` - Port of the AuthDB redis
 * `GANOMEDE_REDIS_REGISTRY_PORT_6379_TCP_ADDR` - IP of the Registry redis
 * `GANOMEDE_REDIS_REGISTRY_PORT_6379_TCP_PORT` - Port of the Registry redis

API
---

All requests made to the turngame API require an auth token, passed in the request URL.

# /turngame/auth/:token/games/:id [GET]

## response [200] OK

    {
        "type": "triominos-1.0",
        "players": [ "some_username_1", "some_username_2" ],
        "turn": "some_username_1",
        "state": "active",
        "data": { ... }
    }

Possible states:
 * active
 * over

# /turngame/auth/:token/games [POST]

## parameters

    + token (string) ... Authentication token

## body (application/json)

    {
        "type": "triominos-1.0",
        "players": [ "some_username_1", "some_username_2" ]
    }

## response [200] OK

    {
        "id": "1234"
        "players": [ "some_username", "other_username" ],
        "turn": "some_username",
        "status": "active",
        "gameData": {
            ... game specific data ...
        }
    }

# /turngame/auth/:token/games/:id/moves [POST]

## parameters

    + token (string) ... Authentication token
    + id (string) ... ID of the game

## body (application/json)

    {
        "move": { ... }
    }

## response [200] OK

    {
        "id": "string",
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

## response [400] Bad Request

    {
        "code": "InvalidPosition"
    }

List of codes will be application dependent.


# /turngame/auth/:token/games/:id/moves [GET]

List moves made on the given game.

## parameters

    + token (string) ... Authentication token
    + id (string) ... ID of the game

## response [200] OK

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

