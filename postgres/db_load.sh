#!/bin/bash
set -e

cd ../mucp

# Execute SQL files using psql
psql -U postgres -d mucp -a -f load.sql

exec "$@"
