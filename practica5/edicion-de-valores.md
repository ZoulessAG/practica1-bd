# Ejercicio 2.4: Edición de Valores (DML) y Transacciones

Script ejecutable: [sql/edicion-de-valores.sql](./sql/edicion-de-valores.sql) sobre `citas_medicas_p4`.

## 1. `INSERT ... SELECT` y `UPSERT` (`ON CONFLICT DO UPDATE`)
- `INSERT INTO orden_estudio ... SELECT ... ON CONFLICT DO NOTHING` agrega un estudio faltante a una orden existente sin duplicar.
- `INSERT INTO paciente ... ON CONFLICT (nss) DO UPDATE` actualiza nombre, vigencia y unidad médica si el NSS ya existe (`INSERT 0 1`).

## 2. `UPDATE` con `JOIN` y clasificación con `CASE`
- `UPDATE cita c ... FROM orden_medica o JOIN paciente p ...` confirma citas (`estatus_asistencia = 'CONFIRMADA'`) únicamente de pacientes vigentes (`UPDATE 1`).
- `UPDATE resultado SET observaciones = CASE ...` clasifica resultados cuantitativos elevados vs parámetros operativos (`UPDATE 10`).

## 3. `DELETE` con subconsulta vs borrado lógico
- **Borrado físico (`DELETE`):** elimina el registro y dispara `ON DELETE CASCADE` (perdiendo teléfonos, citas y resultados asociados) o falla con `ON DELETE RESTRICT` si hay historial médico.
- **Borrado lógico (`UPDATE paciente SET estatus_vigencia = FALSE`):** recomendado en un laboratorio clínico porque conserva la trazabilidad histórica de órdenes, citas y resultados sin romper claves foráneas.

## 4. Transacción multi-tabla con `SAVEPOINT` y `COMMIT`
Se insertó una `orden_medica` (`ORD-2026-7777`), se marcó `SAVEPOINT sp_orden_creada`, se insertó una `cita`, se ejecutó `ROLLBACK TO SAVEPOINT sp_orden_creada` (revirtiendo solo la cita), se re-agendó con horario confirmado y se confirmó con `COMMIT`.

## 5. Transacción que falla a la mitad y `ROLLBACK` total
Al insertar `ORD-2026-7778` seguido de una `cita` con 5 días de anticipación (< 15 días):
```text
ERROR:  La cita de laboratorio debe programarse entre 15 y 30 días antes de la consulta médica (anticipación actual: 5 días)
```
Al comprobar después del fallo: `ordenes_despues_fallo = 0`, confirmando que la orden tampoco quedó persistida.
