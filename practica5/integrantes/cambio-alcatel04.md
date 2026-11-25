# Ejercicio 2.6: Cambio de Acción Referencial — Sánchez Palma Joel — Boleta: 2026630122 (`alcatel04`)

- **Relación elegida:** `orden_medica` (1) — `cita` (N), restricción `fk_cita_orden`
- **Cambio probado (sobre copia en transacción):** `ON DELETE CASCADE` → `ON DELETE RESTRICT`

## Prueba comparativa con datos reales (`citas_medicas_p4`)

Antes de borrar la orden médica `'ORD-2026-000105'`:
- Citas de laboratorio asociadas (`cita`): `1`
- Estudios solicitados en la orden (`orden_estudio`): `2`
- Resultados médicos asociados (`resultado`): `2`

### 1. Con `ON DELETE CASCADE` (esquema de la migración actual)
```sql
BEGIN;

DELETE FROM orden_medica WHERE folio_orden = 'ORD-2026-000105';

-- Resultado: DELETE 1 en orden_medica.
ROLLBACK;
```
- **Qué se pierde:** Se elimina la orden médica `'ORD-2026-000105'` y, en cascada por `fk_cita_orden`, su cita asociada en `cita` (además de sus registros en `orden_estudio` por `fk_oe_orden` y, si `fk_resultado_cita` también es en cascada, los resultados ligados a esa cita).
- **Qué se conserva:** El registro del paciente (`paciente`, ya que `fk_orden_paciente` tiene `ON DELETE RESTRICT`) y los catálogos maestros (`estudio`, `prueba_sangre`, `prueba_orina`), pero se borra el historial operativo y de toma de muestra vinculado a esa orden.

### 2. Con `ON DELETE RESTRICT` (cambio temporal de prueba)
```sql
BEGIN;

ALTER TABLE cita DROP CONSTRAINT fk_cita_orden;
ALTER TABLE cita ADD CONSTRAINT fk_cita_orden
    FOREIGN KEY (folio_orden) REFERENCES orden_medica (folio_orden)
    ON DELETE RESTRICT ON UPDATE CASCADE;

DELETE FROM orden_medica WHERE folio_orden = 'ORD-2026-000105';
-- ERROR: update or delete on table "orden_medica" violates foreign key constraint "fk_cita_orden" on table "cita"

ROLLBACK;
```
- **Qué se pierde:** Nada; PostgreSQL aborta la eliminación de la orden médica mientras exista al menos una cita referenciándola.
- **Qué se conserva:** Íntegramente la orden médica (`orden_medica`), la cita de laboratorio (`cita`), los estudios solicitados (`orden_estudio`) y los resultados clínicos (`resultado`).

## Conclusión para el dominio
La opción correcta para un laboratorio clínico es **`ON DELETE RESTRICT`**: una orden médica con citas asociadas nunca debe borrarse físicamente en cascada porque destruiría la trazabilidad de atención y el historial clínico del paciente; las cancelaciones deben gestionarse mediante estados (`estatus_asistencia`) o borrado lógico.
