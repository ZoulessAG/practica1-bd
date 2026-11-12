# Práctica 4: Implementación DDL, Restricciones de Dominio y Permisos

- **Rama:** `practica4-5`
- **Base de datos propia:** `citas_medicas_p4` (PostgreSQL 15 en contenedor `postgres_laboratorio`, puerto `5433`)
- **Proyecto asignado:** `Seismic-Data-Visualization-System` (Sismos — catálogo SSN / INEGI)

## Comando único de carga (Ejercicio 1.4)

```powershell
$env:PGHOST="localhost"; $env:PGPORT="5433"; $env:PGDATABASE="citas_medicas_p4"; $env:PGUSER="admin_lab"; $env:PGPASSWORD="<tu_password>"
.\poblar\poblar.ps1
```
En Linux/macOS/Git Bash:
```bash
PGHOST=localhost PGPORT=5433 PGDATABASE=citas_medicas_p4 PGUSER=admin_lab PGPASSWORD="<tu_password>" ./poblar/poblar.sh
```

## Entregables
- [dominios.md](./dominios.md) — Ejercicios 1.1 y 1.2 (tipos, dominios, enum y 14 restricciones)
- [fuente.md](./fuente.md) — Ejercicios 1.3 y 1.4 (justificación de datos sintéticos ≥220 filas/tabla y salida real de carga)
- [pruebas-dominio.md](./pruebas-dominio.md) — Ejercicio 1.5 (10 pruebas de dominio ejecutadas en PostgreSQL)
- [permisos.md](./permisos.md) — Ejercicio 1.6 (3 roles, mínimo privilegio, `GRANT`/`REVOKE` y matriz)
- [migraciones/001-dominios.sql](./migraciones/001-dominios.sql) — Migración DDL de dominios y restricciones
- [migraciones/002-permisos.sql](./migraciones/002-permisos.sql) — Migración de roles y privilegios
- [proyecto-asignado/README.md](./proyecto-asignado/README.md) — Ejercicio 1.7 (Sismos: fuente SSN, comparación y 3 restricciones propuestas)
