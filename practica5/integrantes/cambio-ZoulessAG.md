# Ejercicio 2.6: Cambio de Acción Referencial — Ian Andrew Aguilar García (`ZoulessAG`)

- **Relación elegida:** `paciente` (1) — `orden_medica` (N), restricción `fk_orden_paciente`
- **Cambio probado (sobre copia en transacción):** `ON DELETE RESTRICT` → `ON DELETE CASCADE`

## Prueba comparativa con datos reales (`citas_medicas_p4`)

Antes de borrar al paciente `'11000000002'`:
- Órdenes médicas asociadas (`orden_medica`): `1`
- Citas de laboratorio asociadas (`cita`): `1`

### 1. Con `ON DELETE RESTRICT` (esquema original)
PostgreSQL protege la integridad del historial clínico y rechaza la eliminación del paciente mientras existan registros dependientes (`ERROR: update or delete on table "paciente" violates foreign key constraint ...`).

### 2. Con `ON DELETE CASCADE` (cambio temporal de prueba)
```sql
ALTER TABLE orden_medica DROP CONSTRAINT fk_orden_paciente;
ALTER TABLE orden_medica ADD CONSTRAINT fk_orden_paciente
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss)
    ON DELETE CASCADE ON UPDATE CASCADE;

DELETE FROM paciente WHERE nss = '11000000002';
```
- **Resultado:** `DELETE 1` en `paciente`.
- **Qué se pierde:** Se eliminan en cascada `1` orden médica en `orden_medica`, su `1` cita en `cita`, sus registros en `orden_estudio` y sus resultados en `resultado` (`ordenes_paciente_despues = 0`, `citas_paciente_despues = 0`).
- **Qué se conserva:** Nada del historial clínico de ese paciente.

## Conclusión para el dominio
La opción correcta para un laboratorio clínico es **`ON DELETE RESTRICT`**: un paciente con órdenes médicas o resultados emitidos nunca debe borrarse físicamente en cascada porque destruiría evidencia médico-legal y trazabilidad del expediente; en su lugar se usa borrado lógico (`estatus_vigencia = FALSE`).
