-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Práctica 3: Pruebas de Restricciones del Esquema Relacional
-- Base de Datos: citas_medicas_p3
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. INSERCIÓN DE DATOS VÁLIDOS (Línea Base)
-- ------------------------------------------------------------------------------
INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion, nss_titular)
VALUES 
('1122334455', 'Carlos Sanchez Ruiz', TRUE, 'HGZ No. 24', NULL),
('9988776655', 'Mariana Sanchez Ruiz', TRUE, 'HGZ No. 24', '1122334455');

INSERT INTO paciente_telefono (nss, telefono)
VALUES 
('1122334455', '5512345678'),
('1122334455', '5598765432');

INSERT INTO orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
VALUES ('ORD-2026-001', '2026-10-10', 'Dr. Roberto Gomez (Ced. 12345678)', '1122334455');

INSERT INTO cita (fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia, folio_orden)
VALUES ('2026-10-10 10:00:00-06', '2026-10-15 07:30:00-06', 'PROGRAMADA', 'ORD-2026-001');

INSERT INTO estudio (nombre_estudio, indicaciones_previas)
VALUES 
('Química Sanguínea 6 Elementos', 'Ayuno estricto de 8 a 12 horas.'),
('Examen General de Orina (EGO)', 'Primer chorro de la primera orina de la mañana.');

INSERT INTO prueba_sangre (id_estudio, tipo_tubo, color_tapon, ayuno_horas)
VALUES (1, 'Tubo con gel separador', 'Rojo / Oro', 8);

INSERT INTO orden_estudio (folio_orden, id_estudio)
VALUES ('ORD-2026-001', 1);

INSERT INTO resultado (valor_obtenido, unidad_medida, rango_referencia, observaciones, id_cita, id_estudio)
VALUES ('95.4', 'mg/dL', '70.0 - 100.0', 'Glucosa en ayuno dentro de límites normales.', 1, 1);


-- ==============================================================================
-- 2. CASOS DE PRUEBA DE RECHAZO (VIOLACIÓN DE RESTRICCIONES)
-- Evidencia obligatoria de que el modelo protege la integridad de los datos
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- CASO 1: Violación de Integridad de Entidad (Clave Primaria Duplicada)
-- Intento de insertar un paciente con un NSS que ya existe en el sistema
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: duplicate key value violates unique constraint "pk_paciente"
INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion)
VALUES ('1122334455', 'Paciente Impostor', TRUE, 'UMF No. 10');


-- ------------------------------------------------------------------------------
-- CASO 2: Violación de Integridad Referencial (Clave Foránea Inexistente)
-- Intento de registrar un teléfono para un NSS que no existe en paciente
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: insert or update on table "paciente_telefono" violates foreign key constraint "fk_telefono_paciente"
INSERT INTO paciente_telefono (nss, telefono)
VALUES ('0000000000', '5500000000');


-- ------------------------------------------------------------------------------
-- CASO 3: Violación de Restricción CHECK de Dominio (Horas de Ayuno Inválidas)
-- Intento de registrar una prueba de sangre con 35 horas de ayuno (máximo permitido: 24)
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: new row for relation "prueba_sangre" violates check constraint "chk_ayuno_horas"
INSERT INTO prueba_sangre (id_estudio, tipo_tubo, color_tapon, ayuno_horas)
VALUES (1, 'Tubo EDTA', 'Lila', 35);


-- ------------------------------------------------------------------------------
-- CASO 4: Violación de Restricción UNIQUE (Relación 1 a 1 en Cita - Orden Médica)
-- Intento de generar una segunda cita para la misma orden médica ya agendada
-- ------------------------------------------------------------------------------
-- ERROR ESPERADO: duplicate key value violates unique constraint "uq_cita_orden"
INSERT INTO cita (fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia, folio_orden)
VALUES ('2026-10-11 11:00:00-06', '2026-10-18 08:00:00-06', 'PROGRAMADA', 'ORD-2026-001');
