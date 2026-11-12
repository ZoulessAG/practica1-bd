# Ejercicio 2.3: Pruebas de Integridad Referencial

Script ejecutable: [sql/pruebas-referenciales.sql](./sql/pruebas-referenciales.sql) sobre `citas_medicas_p4`.

## 1. Pruebas por acción referencial

- **`ON DELETE RESTRICT` (`fk_paciente_titular` / `fk_orden_paciente`):**
  Al intentar `DELETE FROM paciente WHERE nss = '11000000001'` (paciente con beneficiario y orden médica):
  ```text
  ERROR:  update or delete on table "paciente" violates foreign key constraint "fk_paciente_titular" on table "paciente"
  DETAIL:  Key (nss)=(11000000001) is still referenced from table "paciente".
  ```
- **`ON DELETE CASCADE` (`fk_telefono_paciente`):**
  - Teléfonos del paciente temporal `'99000000001'` antes del `DELETE`: `1`
  - Tras `DELETE FROM paciente WHERE nss = '99000000001'`: `DELETE 1`
  - Teléfonos después del `DELETE`: `0`
- **`ON UPDATE CASCADE` (`fk_telefono_paciente`):**
  Al actualizar `nss` de `'99000000002'` a `'99000000003'`:
  ```text
  UPDATE 1
       nss     |  telefono  
  -------------+------------
   99000000003 | 5599887766
  ```

## 2. `INSERT` con clave foránea inexistente
```sql
INSERT INTO orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
VALUES ('ORD-2026-8888', '2026-12-20', 'Dr. Prueba FK', '00000000000');
```
Respuesta del gestor:
```text
ERROR:  insert or update on table "orden_medica" violates foreign key constraint "fk_orden_paciente"
DETAIL:  Key (nss_paciente)=(00000000000) is not present in table "paciente".
```

## 3. Orden de carga
Si el script intenta cargar `orden_medica` o `cita` antes que `paciente`, PostgreSQL rechaza el `INSERT` por violar `fk_orden_paciente` / `fk_cita_orden`. Por ello, [cargar.sql](../practica4/poblar/cargar.sql) carga en orden topológico: `paciente` (titulares → beneficiarios) → `paciente_telefono` → `orden_medica` → `cita` → `estudio` y subtipos → `orden_estudio` → `resultado`.

## 4. Comprobaciones de integridad (todas con 0 discrepancias)
- Huérfanos `orden_medica` → `paciente`: `0 rows`
- Huérfanos `resultado` → `cita` / `estudio`: `0 rows`
- Duplicados en `estudio.nombre_estudio` y `cita.folio_orden`: `0 rows`
- Nulos en columnas `NOT NULL` de `paciente`: `0`
