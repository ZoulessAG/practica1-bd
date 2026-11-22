-- ==============================================================================
-- Práctica 5 - Ejercicio 2.4: Edición de Valores (DML) y Transacciones
-- Base de datos: citas_medicas_p4
-- ==============================================================================

-- 1a. INSERT tomando valores de una consulta (crear orden_estudio para estudios de sangre en órdenes sin ese estudio)
INSERT INTO orden_estudio (folio_orden, id_estudio)
SELECT o.folio_orden, 2
  FROM orden_medica o
 WHERE o.folio_orden = 'ORD-2026-0001'
ON CONFLICT (folio_orden, id_estudio) DO NOTHING;

-- 1b. UPSERT (INSERT ... ON CONFLICT DO UPDATE) al actualizar datos de un paciente existente
INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion)
VALUES ('11000000001', 'Carlos Sánchez Ruiz (Actualizado)', TRUE, 'HGZ No. 24 Insurgentes')
ON CONFLICT (nss) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    estatus_vigencia = EXCLUDED.estatus_vigencia,
    unidad_medica_adscripcion = EXCLUDED.unidad_medica_adscripcion;

-- 2a. UPDATE que depende de otra tabla (confirmar citas cuya orden es de un paciente vigente)
UPDATE cita c
   SET estatus_asistencia = 'CONFIRMADA'
  FROM orden_medica o
  JOIN paciente p ON o.nss_paciente = p.nss
 WHERE c.folio_orden = o.folio_orden
   AND p.estatus_vigencia = TRUE
   AND c.estatus_asistencia = 'PROGRAMADA'
   AND c.id_cita <= 5;

-- 2b. UPDATE que clasifica con CASE (etiquetar observaciones de resultado según valor numérico)
UPDATE resultado
   SET observaciones = CASE
       WHEN valor_obtenido ~ '^[0-9]+(\.[0-9]+)?$' AND valor_obtenido::NUMERIC > 150
           THEN 'Valor elevado: requiere seguimiento médico.'
       ELSE 'Validado dentro de parámetros operativos.'
   END
 WHERE id_resultado <= 10;

-- 3. DELETE con subconsulta vs borrado lógico
-- 3a. DELETE físico con subconsulta (sobre registro temporal de prueba)
INSERT INTO paciente (nss, nombre, unidad_medica_adscripcion)
VALUES ('99000000099', 'Paciente Prueba Delete Subquery', 'UMF No. 10');

DELETE FROM paciente
 WHERE nss IN (
     SELECT p.nss
       FROM paciente p
       LEFT JOIN orden_medica o ON p.nss = o.nss_paciente
      WHERE o.folio_orden IS NULL
        AND p.nss = '99000000099'
 );

-- 3b. Borrado lógico (preferido en historial clínico para no perder trazabilidad):
UPDATE paciente
   SET estatus_vigencia = FALSE
 WHERE nss IN (
     SELECT p.nss
       FROM paciente p
       LEFT JOIN orden_medica o ON p.nss = o.nss_paciente
      WHERE o.folio_orden IS NULL
      LIMIT 1
 );

-- 4. Transacción multi-tabla con SAVEPOINT, reversión parcial y COMMIT
BEGIN;
    INSERT INTO orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
    VALUES ('ORD-2026-7777', '2026-12-25', 'Dra. Elena Martínez (Ced. 23456789)', '11000000001');

    SAVEPOINT sp_orden_creada;

    INSERT INTO cita (fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia, folio_orden)
    VALUES ('2026-11-15 09:00:00-06', '2026-12-01 08:00:00-06', 'PROGRAMADA', 'ORD-2026-7777');

    -- Reversión parcial al savepoint (deshace la cita pero conserva la orden dentro de la transacción)
    ROLLBACK TO SAVEPOINT sp_orden_creada;

    -- Re-agenda con nuevo horario y confirma
    INSERT INTO cita (fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia, folio_orden)
    VALUES ('2026-11-15 09:00:00-06', '2026-12-02 09:30:00-06', 'CONFIRMADA', 'ORD-2026-7777');
COMMIT;

-- Limpieza del registro de prueba
DELETE FROM orden_medica WHERE folio_orden = 'ORD-2026-7777';

-- 5. Transacción que falla a la mitad por restricción y comprueba ROLLBACK total
SELECT COUNT(*) AS ordenes_antes_fallo FROM orden_medica WHERE folio_orden = 'ORD-2026-7778';
BEGIN;
    INSERT INTO orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
    VALUES ('ORD-2026-7778', '2026-12-25', 'Dr. Prueba Transaccion', '11000000001');
    -- Falla por anticipación de 5 días (< 15 días):
    INSERT INTO cita (fecha_hora_agendamiento, fecha_hora_laboratorio, folio_orden)
    VALUES ('2026-12-01 09:00:00-06', '2026-12-20 08:00:00-06', 'ORD-2026-7778');
COMMIT;
ROLLBACK;
SELECT COUNT(*) AS ordenes_despues_fallo FROM orden_medica WHERE folio_orden = 'ORD-2026-7778';
