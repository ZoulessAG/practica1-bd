-- ==============================================================================
-- Práctica 4 - Ejercicios 1.1 y 1.2
-- Migración 001: Dominios, tipos enumerados y restricciones de columna
-- Base de datos destino: citas_medicas_p4 (creada a partir de esquema.sql de P3)
-- ==============================================================================

BEGIN;

-- ------------------------------------------------------------------------------
-- 1. DOMINIOS REUTILIZABLES Y TIPOS ENUMERADOS (Ejercicio 1.1)
-- ------------------------------------------------------------------------------

-- Regla: El NSS en México tiene 10 u 11 dígitos numéricos sin letras ni símbolos.
CREATE DOMAIN dom_nss AS VARCHAR(15)
    CHECK (VALUE ~ '^[0-9]{10,11}$');

-- Regla: El teléfono debe contener únicamente entre 8 y 15 dígitos numéricos.
CREATE DOMAIN dom_telefono AS VARCHAR(15)
    CHECK (VALUE ~ '^[0-9]{8,15}$');

-- Regla: Todo folio de orden médica sigue el formato ORD-AAAA-NNN(NNN).
CREATE DOMAIN dom_folio_orden AS VARCHAR(20)
    CHECK (VALUE ~ '^ORD-[0-9]{4}-[0-9]{3,6}$');

-- Regla: Los estados válidos de asistencia en laboratorio son exactamente cinco.
CREATE TYPE enum_estatus_asistencia AS ENUM (
    'PROGRAMADA',
    'CONFIRMADA',
    'ASISTIO',
    'CANCELADA',
    'NO_ASISTIO'
);

-- ------------------------------------------------------------------------------
-- 2. APLICACIÓN DE DOMINIOS MEDIANTE ALTER TABLE
-- ------------------------------------------------------------------------------

-- Quitar FKs temporalmente para cambiar el tipo base a los dominios definidos
ALTER TABLE paciente DROP CONSTRAINT fk_paciente_titular;
ALTER TABLE paciente_telefono DROP CONSTRAINT fk_telefono_paciente;
ALTER TABLE orden_medica DROP CONSTRAINT fk_orden_paciente;
ALTER TABLE cita DROP CONSTRAINT fk_cita_orden;
ALTER TABLE orden_estudio DROP CONSTRAINT fk_oe_orden;

-- Aplicar dom_nss
ALTER TABLE paciente ALTER COLUMN nss TYPE dom_nss;
ALTER TABLE paciente ALTER COLUMN nss_titular TYPE dom_nss;
ALTER TABLE paciente_telefono ALTER COLUMN nss TYPE dom_nss;
ALTER TABLE orden_medica ALTER COLUMN nss_paciente TYPE dom_nss;

-- Aplicar dom_telefono (reemplaza chk_telefono_formato básico de P3)
ALTER TABLE paciente_telefono DROP CONSTRAINT chk_telefono_formato;
ALTER TABLE paciente_telefono ALTER COLUMN telefono TYPE dom_telefono;

-- Aplicar dom_folio_orden
ALTER TABLE orden_medica ALTER COLUMN folio_orden TYPE dom_folio_orden;
ALTER TABLE cita ALTER COLUMN folio_orden TYPE dom_folio_orden;
ALTER TABLE orden_estudio ALTER COLUMN folio_orden TYPE dom_folio_orden;

-- Aplicar enum_estatus_asistencia en cita (reemplaza CHECK de texto libre)
ALTER TABLE cita DROP CONSTRAINT chk_estatus_asistencia;
ALTER TABLE cita ALTER COLUMN estatus_asistencia DROP DEFAULT;
ALTER TABLE cita ALTER COLUMN estatus_asistencia TYPE enum_estatus_asistencia
    USING estatus_asistencia::enum_estatus_asistencia;
ALTER TABLE cita ALTER COLUMN estatus_asistencia SET DEFAULT 'PROGRAMADA';

-- Reestablecer FKs
ALTER TABLE paciente
    ADD CONSTRAINT fk_paciente_titular FOREIGN KEY (nss_titular)
    REFERENCES paciente (nss) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE paciente_telefono
    ADD CONSTRAINT fk_telefono_paciente FOREIGN KEY (nss)
    REFERENCES paciente (nss) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE orden_medica
    ADD CONSTRAINT fk_orden_paciente FOREIGN KEY (nss_paciente)
    REFERENCES paciente (nss) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE cita
    ADD CONSTRAINT fk_cita_orden FOREIGN KEY (folio_orden)
    REFERENCES orden_medica (folio_orden) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE orden_estudio
    ADD CONSTRAINT fk_oe_orden FOREIGN KEY (folio_orden)
    REFERENCES orden_medica (folio_orden) ON DELETE CASCADE ON UPDATE CASCADE;

-- ------------------------------------------------------------------------------
-- 3. RESTRICCIONES DE COLUMNA CHECK Y UNIQUE (Ejercicio 1.2 - >= 10 reglas)
-- ------------------------------------------------------------------------------

-- R1: El nombre del paciente debe tener al menos 3 caracteres útiles.
ALTER TABLE paciente
    ADD CONSTRAINT chk_paciente_nombre_valido
    CHECK (LENGTH(TRIM(nombre)) >= 3);

-- R2: La unidad médica de adscripción debe tener al menos 4 caracteres.
ALTER TABLE paciente
    ADD CONSTRAINT chk_paciente_unidad_valida
    CHECK (LENGTH(TRIM(unidad_medica_adscripcion)) >= 4);

-- R3: La fecha de consulta con el médico tratante debe ser >= 2020-01-01.
ALTER TABLE orden_medica
    ADD CONSTRAINT chk_orden_fecha_valida
    CHECK (fecha_cita_medico >= DATE '2020-01-01');

-- R4: El médico emisor debe incluir al menos 5 caracteres identificables.
ALTER TABLE orden_medica
    ADD CONSTRAINT chk_medico_emisor_valido
    CHECK (LENGTH(TRIM(medico_emisor)) >= 5);

-- R5: El horario de toma de muestra en laboratorio es de 06:00 a 20:59 (hora local).
ALTER TABLE cita
    ADD CONSTRAINT chk_cita_horario_laboral
    CHECK (EXTRACT(HOUR FROM fecha_hora_laboratorio AT TIME ZONE 'America/Mexico_City') BETWEEN 6 AND 20);

-- R6: El nombre del estudio clínico debe tener al menos 3 caracteres útiles.
ALTER TABLE estudio
    ADD CONSTRAINT chk_estudio_nombre_valido
    CHECK (LENGTH(TRIM(nombre_estudio)) >= 3);

-- R7: El tipo de tubo en pruebas de sangre no puede estar vacío ni ser menor a 3 caracteres.
ALTER TABLE prueba_sangre
    ADD CONSTRAINT chk_sangre_tubo_valido
    CHECK (LENGTH(TRIM(tipo_tubo)) >= 3);

-- R8: El color de tapón en pruebas de sangre debe tener al menos 3 caracteres.
ALTER TABLE prueba_sangre
    ADD CONSTRAINT chk_sangre_tapon_valido
    CHECK (LENGTH(TRIM(color_tapon)) >= 3);

-- R9: El volumen mínimo en pruebas de orina debe especificar al menos 2 caracteres (ej. '10 ml').
ALTER TABLE prueba_orina
    ADD CONSTRAINT chk_orina_volumen_valido
    CHECK (LENGTH(TRIM(volumen_minimo)) >= 2);

-- R10: El valor obtenido en un resultado no puede ser una cadena en blanco.
ALTER TABLE resultado
    ADD CONSTRAINT chk_resultado_valor_no_vacio
    CHECK (LENGTH(TRIM(valor_obtenido)) >= 1);

-- R11: La fecha de emisión del resultado debe ser >= 2020-01-01.
ALTER TABLE resultado
    ADD CONSTRAINT chk_resultado_fecha_valida
    CHECK (fecha_hora_emision >= TIMESTAMP WITH TIME ZONE '2020-01-01 00:00:00-06');

-- R12: Un estudio específico solo puede tener un resultado registrado por cita (UNIQUE compuesta).
ALTER TABLE resultado
    ADD CONSTRAINT uq_resultado_cita_estudio
    UNIQUE (id_cita, id_estudio);

COMMIT;
