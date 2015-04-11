Avatars
-----------

User avatars.

Relations
---------

The avatar module will:

 * Associate users with a avatar picture.
 * Create thumbnails of different sizes.
 * Store pictures and thumbnails as CouchDB attachment.
 * Use the `redis_auth` database to check requester identity.

Configuration
-------------

 * `REDIS_AUTH_PORT_6379_TCP_ADDR` - IP of the AuthDB redis
 * `REDIS_AUTH_PORT_6379_TCP_PORT` - Port of the AuthDB redis
 * `COUCH_AVATARS_PORT_5984_TCP_ADDR` - IP of the Avatars couchdb
 * `COUCH_AVATARS_PORT_5984_TCP_PORT` - Port of the Avatars couchdb

API
---

# User's avatar pictures [/avatars/v1/auth/:token/pictures]

    + Parameters
        + token (string) ... User authentication token

## Set avatar picture [POST]

Will:

 * crop the image to be a square
 * create resized versions 512x512, 256x256, 128x128 and 64x64
 * set a `disk` shaped opacity mask over them
 * store PNG images in CouchDB as attachment (overriding any previously stored images).

### body [image/jpeg]

### response [200] OK

# Round thumbnail [/avatars/v1/:username/round/:radius]

    + Parameters
        + username (string) ... User to retrieve the avatar image of
        + radius (integer) ... Disk image radius (64, 128, 256 or 256)

## Get [GET]

### response [200] OK

Content-type: image/png

