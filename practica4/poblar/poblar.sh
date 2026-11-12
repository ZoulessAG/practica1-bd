#!/usr/bin/env bash
set -euo pipefail

# Variables de entorno requeridas (sin credenciales fijas en el código):
#   PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD
: "${PGHOST:?Define PGHOST}"
: "${PGPORT:=5433}"
: "${PGDATABASE:?Define PGDATABASE}"
: "${PGUSER:?Define PGUSER}"
: "${PGPASSWORD:?Define PGPASSWORD}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P4_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$P4_DIR"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -v ON_ERROR_STOP=1 -f "poblar/cargar.sql"
