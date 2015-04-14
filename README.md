Sessions
--------

User sessions is a generic storage system for user data, like game settings, unlocked levels, etc.

Relations
---------

The sessions module will:

 * Associate users with sessions object.
 * Store sessions in Redis.
 * Use the `redis_auth` database to check requester identity.
 * Include some simple mechanisms to prevent sunday's hackers from changing their session.

Configuration
-------------

 * `REDIS_AUTH_PORT_6379_TCP_ADDR` - IP of the AuthDB redis
 * `REDIS_AUTH_PORT_6379_TCP_PORT` - Port of the AuthDB redis
 * `REDIS_SESSIONS_PORT_6379_TCP_ADDR` - IP of the Sessions redis
 * `REDIS_SESSIONS_PORT_6379_TCP_PORT` - Port of the Sessions redis
 * `TYPES` - Comma separated list of valid types recognized by the instance
 * `SALT` - A chain of characters know by the client and server to encode data

API
---

# User sessions [/avatars/v1/auth/:token/sessions/:type]

    + Parameters
        + token (string) ... User authentication token
        + type (string) ... Type of session

## Load a session [GET]

    {
        ... data ...
    }

### response [200] OK

## Save a session [POST]

To prevent sending any data, payload is hashed using HMAC-SHA1, server should verify that `hash` matches the payload. See sample code at the end of README.

### body [application/json]

    {
        "hash": "base-64-data",
        "payload": "base-64-data"
    }

### response [200] OK

### Notes

A session object shouldn't exceed 16KB (to prevent people from using this service as free storage).

Session object `key` in redis should be something like `#{username}@#{type}`, as `@` is a forbidden character in usernames.

In case a session object was already in DB, it will be overriden in any cases.

The `type` parameter should be one of those defined by TYPES environment variables.

# Decoding the payload

```js
if (body.hash !== computeHash(body.payload)) {
    // Send 400, Bad Request.
}

var data = {};
try {
    var data = JSON.parse(new Buffer(body.payload, 'base64').toString('utf-8'));
}
catch (err) {
    // Send 400 Bad Request. Invalid payload.
}

function computeHash(payload) {
    return '' + crypto.HmacSHA1(payload, config.SALT);
};
```

Of course, someone with bad intentions may discover the `SALT` by decompiling the client app, but this will make things a bit harder.

# Contributing

 * Run unit-tests using `make test` (or `npm test`).
 * Generate code coverage report using `make coverage`.
 * Run a test server locally (using docker) attached with redis databases using `make docker-run`
 * For any question, contact Jean-Christophe (j3k0), or post an issue.
 * The newly created [ganomede-helpers npm module](https://github.com/j3k0/ganomede-helpers) includes utility methods, like authentication middleware and such. Make sure you take a look before redeveloping things that are already out there.

