-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Práctica 3: Pruebas de Restricciones del Esquema Relacional
-- Base de Datos: citas_medicas_p3
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. INSERCIÓN DE DATOS VÁLIDOS (Línea Base)
-- ------------------------------------------------------------------------------
INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion, telefono, nss_titular)
VALUES 
('1122334455', 'Carlos Sanchez Ruiz', TRUE, 'HGZ No. 24', '5512345678', NULL),
('9988776655', 'Mariana Sanchez Ruiz', TRUE, 'HGZ No. 24', '5587654321', '1122334455');

INSERT INTO orden_medica (folio_orden, nss_paciente, cedula_profesional, fecha_cita_medico)
VALUES ('ORD-2026-001', '1122334455', '12345678', '2026-10-10');

INSERT INTO cita (folio_orden, fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia)
VALUES ('ORD-2026-001', '2026-10-10 10:00:00-06', '2026-10-15 07:30:00-06', 'PROGRAMADA');

INSERT INTO estudio (nombre_estudio, indicaciones_previas, tipo_estudio)
VALUES 
('Química Sanguínea 6 Elementos', 'Ayuno estricto de 8 a 12 horas.', 'SANGRE'),
('Examen General de Orina (EGO)', 'Primer chorro de la primera orina de la mañana.', 'ORINA');

INSERT INTO prueba_sangre (id_estudio, tipo_tubo, aditivo, ayuno_horas)
VALUES (1, 'Tubo tapón rojo/oro', 'Gel separador y activador de coagulación', 8);

INSERT INTO orden_estudio (folio_orden, id_estudio)
VALUES ('ORD-2026-001', 1);

INSERT INTO resultado (id_cita, tipo_prueba, valor_obtenido, unidad_medida, observaciones)
VALUES (1, 'Glucosa en suero', '95.4', 'mg/dL', 'Parámetro dentro de límites normales.');


-- ==============================================================================
-- 2. CASOS DE PRUEBA DE RECHAZO (VIOLACIÓN DE RESTRICCIONES)
-- Evidencia obligatoria de que el modelo protege la integridad de los datos
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- CASO 1: Violación de Integridad de Entidad (Clave Primaria Duplicada)
-- Intento de insertar un paciente con un NSS que ya existe en el sistema
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: duplicate key value violates unique constraint "pk_paciente"
INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion, telefono)
VALUES ('1122334455', 'Paciente Impostor', TRUE, 'UMF No. 10', '5500000000');


-- ------------------------------------------------------------------------------
-- CASO 2: Violación de Integridad Referencial (Clave Foránea Inexistente)
-- Intento de crear una orden médica para un NSS de paciente que no existe
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: insert or update on table "orden_medica" violates foreign key constraint "fk_orden_paciente"
INSERT INTO orden_medica (folio_orden, nss_paciente, cedula_profesional, fecha_cita_medico)
VALUES ('ORD-2026-999', '0000000000', '98765432', '2026-10-12');


-- ------------------------------------------------------------------------------
-- CASO 3: Violación de Restricción CHECK de Dominio (Horas de Ayuno Inválidas)
-- Intento de registrar una prueba de sangre con 35 horas de ayuno (máximo permitido: 24)
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: new row for relation "prueba_sangre" violates check constraint "chk_ayuno_horas"
INSERT INTO prueba_sangre (id_estudio, tipo_tubo, aditivo, ayuno_horas)
VALUES (1, 'Tubo tapón lila', 'EDTA', 35);


-- ------------------------------------------------------------------------------
-- CASO 4: Violación de Restricción UNIQUE (Relación 1 a 1 en Cita - Orden Médica)
-- Intento de generar una segunda cita para la misma orden médica ya agendada
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: duplicate key value violates unique constraint "uq_cita_orden"
INSERT INTO cita (folio_orden, fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia)
VALUES ('ORD-2026-001', '2026-10-11 11:00:00-06', '2026-10-18 08:00:00-06', 'PROGRAMADA');
