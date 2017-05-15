#!/bin/bash
if [ ! -f /app/installed ]; then
  /app/firstrun.sh
fi

echo 'Starting services'
service postgresql start
service apache2 start

tail -f /dev/null
