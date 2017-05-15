# Load initial data
export PBF_FILE=http://download.geofabrik.de/europe/monaco-latest.osm.pbf

if [ "$PBF_FILE" = "" ]; then
  echo "You need to specify the environmental PBF_FILE"
  echo "docker run -e http://download.geofabrik.de/europe/monaco-latest.osm.pbf ..."
fi;

# Update postgres config to improve import performance
sed -i "s/fsync = on/fsync = off/g" /etc/postgresql/9.5/main/postgresql.conf
sed -i "s/full_page_writes = on/full_page_writes = off/g" /etc/postgresql/9.5/main/postgresql.conf

curl -L "$PBF_FILE" --create-dirs -o /app/src/data.osm.pbf
curl -L -o /app/src/data/country_osm_grid.sql.gz http://www.nominatim.org/data/country_grid.sql.gz
service postgresql start && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
    sudo -u  postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
    useradd -m -p password1234 nominatim && \
    chown -R nominatim:nominatim ./src && \
    sed -i "s/number-processes 1/number-processes $THREADS/g" src/build/utils/setup.php && \
    sudo -u nominatim ./src/build/utils/setup.php --osm-file /app/src/data.osm.pbf --all --threads $THREADS && \
    service postgresql stop && \
    touch /app/installed

sed -i "s/fsync = off/fsync = on/g" /etc/postgresql/9.5/main/postgresql.conf
sed -i "s/full_page_writes = off/full_page_writes = on/g" /etc/postgresql/9.5/main/postgresql.conf
