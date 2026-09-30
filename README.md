# What is this?

osmtilecache is a Micronaut service providing proxy and caching services for OpenStreetMap tiles.

Anyone using a map will benefit from the cache, especially in non-Internet accessible scenarios.

Simply use your app configured to retrieve tiles from this tile server. 

Traverse the map areas of interest before disconnecting, then those maps will be cached and available when you are disconnected.


## Usage

Change references to Open Street Map URL template (https://tile.openstreetmap.org/{z}/{x}/{y}.jpg) to this - http://SERVER:OSMTC_HTTP_PORT/api/v1/tiles/{z}/{x}/{y}



## Environment Variables

The following envirnonment variables control the behavior of osmtilecache.

OSMTC_INSTALL_DIR   ~/osmtc

OSMTC_DB_DIR         ~/osmtc/db

OSMTC_TEMP_DIR       ~/osmtc/tmp

OSMTC_TILES_DIR      ~/osmtc/tiles

OSMTC_HTTP_PORT      8888

OSMTC_CONFIG         proxycache (default) | cache | proxy

OSMTC_TILE_SERVER    tile.openstreetmap.org

