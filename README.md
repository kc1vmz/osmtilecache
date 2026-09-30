# What is this?

osmtilecache is a Micronaut service providing proxy and caching services for OpenStreetMap tiles.

Anyone using a map will benefit from the cache, especially in non-Internet accessible scenarios.
Simply use your app configured to retrieve tiles from this tile server. 
Traverse the map areas of interest before disconnecting, then those maps will be cached and available when you are disconnected.



## Environment Variables

The following envirnonment variables control the behavior of osmtilecache.

OSMTC_TEMP_DIR       /osmtilecache/tmp
OSMTC_HTTP_PORT      8888
OSMTC_HTTPS_PORT     4448
OSMTC_CONFIG         proxycache (default) | cache | proxy
