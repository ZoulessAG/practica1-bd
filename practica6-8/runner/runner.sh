#!/bin/bash
set -e

echo "================================================================="
echo "   CITASMED - SISTEMA CLÍNICO Y LABORATORIO (ESCOM IPN)"
echo "   Prácticas 6, 7 y 8: Álgebra Relacional y Normalización"
echo "================================================================="
echo ""
echo ">> Esperando a que el gestor PostgreSQL esté listo..."
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" > /dev/null 2>&1; do
  sleep 1
done
echo ">> PostgreSQL está listo y respondiendo consultas."
echo ""

python /app/runner/runner.py

echo ""
echo ">> Regenerando archivo de grupo RelaX desde el script oficial..."
python /app/relax/exportar-grupo.py

echo ""
echo "================================================================="
echo "   [ÉXITO] TODAS LAS CONSULTAS Y PRUEBAS CONCLUIDAS CON ÉXITO"
echo "================================================================="
