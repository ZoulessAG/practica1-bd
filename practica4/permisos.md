# Ejercicio 1.6: Usuarios, Roles y Permisos

Script ejecutado: [002-permisos.sql](./migraciones/002-permisos.sql) (contraseñas pasadas por variables de `psql` desde variables de entorno, nunca en el repositorio).

## 1. Roles definidos
- `rol_app` (usuario `usr_app`): usado por el backend y el script de carga; lee los catálogos (`estudio`, subtipos) y lee/inserta/actualiza en tablas operativas (`paciente`, `paciente_telefono`, `orden_medica`, `cita`, `orden_estudio`, `resultado`), sin `DELETE` ni DDL.
- `rol_consulta` (usuario `usr_consulta`): usado para reportes y auditoría; únicamente `SELECT` en todas las tablas.
- `rol_admin_bd` (usuario `usr_admin`): administración completa (`ALL PRIVILEGES` sobre esquema, tablas y secuencias).

## 2. Pruebas reales de operaciones permitidas, negadas y `REVOKE`

```text
=== usr_consulta: SELECT permitido ===
 total_pacientes 
-----------------
             220

=== usr_consulta: INSERT denegado ===
ERROR:  permission denied for table paciente

=== usr_app: SELECT en catalogo permitido, DELETE denegado ===
 total_estudios 
----------------
             15
ERROR:  permission denied for table paciente

=== usr_admin: CREATE TABLE permitido ===
CREATE TABLE
DROP TABLE

=== REVOKE UPDATE ON resultado FROM rol_app ===
REVOKE
SET
ERROR:  permission denied for table resultado
```

## 3. Matriz de permisos

| Tabla | `rol_consulta` (`usr_consulta`) | `rol_app` (`usr_app`) | `rol_admin_bd` (`usr_admin`) |
| :--- | :--- | :--- | :--- |
| `paciente` | `SELECT` | `SELECT, INSERT, UPDATE` | `ALL PRIVILEGES` |
| `paciente_telefono` | `SELECT` | `SELECT, INSERT, UPDATE` | `ALL PRIVILEGES` |
| `orden_medica` | `SELECT` | `SELECT, INSERT, UPDATE` | `ALL PRIVILEGES` |
| `cita` | `SELECT` | `SELECT, INSERT, UPDATE` | `ALL PRIVILEGES` |
| `orden_estudio` | `SELECT` | `SELECT, INSERT, UPDATE` | `ALL PRIVILEGES` |
| `resultado` | `SELECT` | `SELECT, INSERT, UPDATE` | `ALL PRIVILEGES` |
| `estudio` | `SELECT` | `SELECT` | `ALL PRIVILEGES` |
| `prueba_sangre` | `SELECT` | `SELECT` | `ALL PRIVILEGES` |
| `prueba_orina` | `SELECT` | `SELECT` | `ALL PRIVILEGES` |
| `prueba_fecal` | `SELECT` | `SELECT` | `ALL PRIVILEGES` |
