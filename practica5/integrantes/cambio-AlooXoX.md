# Ejercicio 2.6: Cambio de Acción Referencial — Alondra Quintanar Sanchez - AlooXoX

- **Relación elegida:** `cita` (1) — `resultado` (N), restricción `fk_resultado_cita`
- **Cambio probado (sobre copia en transacción):** `ON DELETE RESTRICT` → `ON DELETE CASCADE`

## Prueba comparativa con datos reales (`nombre_de_tu_base`)

Antes de borrar la cita `'105'`:
- Resultados médicos asociados (`resultado`): `3`

### 1. Con `ON DELETE RESTRICT` (esquema original)
PostgreSQL protege la trazabilidad clínica y rechaza la eliminación de una cita que ya generó resultados médicos (`ERROR: update or delete on table "cita" violates foreign key constraint ...`).

### 2. Con `ON DELETE CASCADE` (cambio temporal de prueba)
```sql
ALTER TABLE resultado DROP CONSTRAINT fk_resultado_cita;
ALTER TABLE resultado ADD CONSTRAINT fk_resultado_cita
    FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
    ON DELETE CASCADE ON UPDATE CASCADE;

DELETE FROM cita WHERE id_cita = '105';

- **Resultado:** `DELETE 1` en `cita`.
- **Qué se pierde:** Se eliminan en cascada `3` resultados médicos en `resultado` (sus valores obtenidos, observaciones y fechas de emisión).
- **Qué se conserva:** El registro del paciente y su orden médica original, pero quedando una inconsistencia (una orden cuyas pruebas se reportaron como hechas, pero sus resultados desaparecieron).

## Conclusión
La opción correcta para un laboratorio clínico es **`ON DELETE RESTRICT`**: una cita que ya fue atendida y arrojó valores médicos nunca debe borrarse físicamente en cascada porque destruiría los diagnósticos emitidos y la historia clínica del paciente; en su lugar, si la cita no ocurrió, se maneja mediante su atributo de estado (`estatus_asistencia`).
