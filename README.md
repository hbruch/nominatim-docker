# Nominatim Docker

Docker container based on a current [Nominatim](https://github.com/openstreetmap/Nominatim) version.
Version 2.5.1 is already pretty old, but there is not yet a newer release. The version provided here is **411 commits** ahead of 2.5.1.

Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container.

To prevent instability, the version of nominatim is frozen to a recent commit. You can change the version / commit hash in the Dockerfile.
Feel free to create a pull request

Running with **Ubuntu 16.04 LTS**, **PostgreSQL 9.5**, **PHP 7**

# Setup
You can build your own image as simple as
```
docker build . --tag thomasnordquist/simple-nominatim:latest
```
This will only install the environment to run and import the data.

# Run / Import
In contrast to other nominatim docker implementations, I decided to move the import out of the build phase.

### Example for monaco
Monaco is the smallest dataset and therefore the best example to begin with
```
docker run \
 -e PBF_URL=http://download.geofabrik.de/europe/monaco-latest.osm.pbf \
 -e REPLICATION_URL=http://download.geofabrik.de/europe/monaco-updates \
 -p 8080:8080 \
 -it thomasnordquist/simple-nominatim
```


### Example for germany
Germany is a much bigger dataset and requires far more time, about 12 hours on an AMD 6-core machine with SSD.
After import the image is **>70GB** in size.
```
docker run \
 -e PBF_URL=http://download.geofabrik.de/europe/germany-latest.osm.pbf \
 -e REPLICATION_URL=http://download.geofabrik.de/europe/germany-updates \
 -e THREADS=8 \
 --restart=always \
 -p 8082:8080 \
 --name nominatim-germany \
 -it thomasnordquist/simple-nominatim
```

The service will run on [http://localhost:8080/](http:/localhost:8080)

# Country data
If you want to import data from other countrys or even the whole planet, check out these links:

- http://download.geofabrik.de/
- http://wiki.openstreetmap.org/wiki/Planet.osm

# Tweaking performance
Take a look at the `postgresql.conf` and
https://github.com/openstreetmap/Nominatim/blob/master/docs/Installation.md#postgresql-tuning


During import the following PostgreSQL parameters wll be changed in `firstrun.sh`
```
fsync = off
full_page_writes = off
```
