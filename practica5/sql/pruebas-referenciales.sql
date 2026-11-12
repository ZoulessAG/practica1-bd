-- ==============================================================================
-- Práctica 5 - Ejercicio 2.3: Pruebas de Integridad Referencial
-- Base de datos: citas_medicas_p4
-- ==============================================================================

-- 1. Prueba ON DELETE CASCADE (paciente -> paciente_telefono)
SELECT COUNT(*) AS tel_antes FROM paciente_telefono WHERE nss = '11000000001';
-- Para borrar paciente 11000000001 primero verificamos que orden_medica tiene ON DELETE RESTRICT:
DELETE FROM paciente WHERE nss = '11000000001';
-- En un paciente sin órdenes ni beneficiarios (insertamos uno temporal):
INSERT INTO paciente (nss, nombre, unidad_medica_adscripcion) VALUES ('99000000001', 'Temp Cascade', 'UMF No. 10');
INSERT INTO paciente_telefono (nss, telefono) VALUES ('99000000001', '5511223344');
SELECT COUNT(*) AS tel_temp_antes FROM paciente_telefono WHERE nss = '99000000001';
DELETE FROM paciente WHERE nss = '99000000001';
SELECT COUNT(*) AS tel_temp_despues FROM paciente_telefono WHERE nss = '99000000001';

-- 2. Prueba ON UPDATE CASCADE (paciente.nss -> paciente_telefono.nss y orden_medica.nss_paciente)
INSERT INTO paciente (nss, nombre, unidad_medica_adscripcion) VALUES ('99000000002', 'Temp Update', 'UMF No. 10');
INSERT INTO paciente_telefono (nss, telefono) VALUES ('99000000002', '5599887766');
UPDATE paciente SET nss = '99000000003' WHERE nss = '99000000002';
SELECT nss, telefono FROM paciente_telefono WHERE nss = '99000000003';
DELETE FROM paciente WHERE nss = '99000000003';

-- 3. INSERT con clave foránea inexistente (rechazo)
INSERT INTO orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
VALUES ('ORD-2026-8888', '2026-12-20', 'Dr. Prueba FK', '00000000000');

-- 4. Comprobaciones de integridad (todas deben devolver 0 filas)
-- 4a. Claves foráneas huérfanas en orden_medica -> paciente
SELECT o.folio_orden, o.nss_paciente
  FROM orden_medica o
  LEFT JOIN paciente p ON o.nss_paciente = p.nss
 WHERE p.nss IS NULL;

-- 4b. Claves foráneas huérfanas en resultado -> cita / estudio
SELECT r.id_resultado
  FROM resultado r
  LEFT JOIN cita c ON r.id_cita = c.id_cita
  LEFT JOIN estudio e ON r.id_estudio = e.id_estudio
 WHERE c.id_cita IS NULL OR e.id_estudio IS NULL;

-- 4c. Duplicados en columnas únicas (estudio.nombre_estudio, cita.folio_orden)
SELECT nombre_estudio, COUNT(*) FROM estudio GROUP BY nombre_estudio HAVING COUNT(*) > 1;
SELECT folio_orden, COUNT(*) FROM cita GROUP BY folio_orden HAVING COUNT(*) > 1;

-- 4d. Nulos en columnas NOT NULL (verificación explícita)
SELECT COUNT(*) AS nulos_paciente FROM paciente WHERE nombre IS NULL OR unidad_medica_adscripcion IS NULL;
