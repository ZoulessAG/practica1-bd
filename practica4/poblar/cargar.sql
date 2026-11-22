-- ==============================================================================
-- Práctica 4 - Ejercicio 1.4: Carga masiva repetible, ordenada y transaccional
-- Requiere ejecutarse con psql desde la carpeta practica4/ (rutas datos/*.csv)
-- ==============================================================================

\set ON_ERROR_STOP on
\timing on

BEGIN;

-- Tablas temporales de staging (se eliminan al terminar la transacción)
CREATE TEMP TABLE stg_paciente (
    nss VARCHAR(15), nombre VARCHAR(100), estatus_vigencia BOOLEAN,
    unidad_medica_adscripcion VARCHAR(100), nss_titular VARCHAR(15)
) ON COMMIT DROP;

CREATE TEMP TABLE stg_paciente_telefono (
    nss VARCHAR(15), telefono VARCHAR(15)
) ON COMMIT DROP;

CREATE TEMP TABLE stg_orden_medica (
    folio_orden VARCHAR(20), fecha_cita_medico DATE,
    medico_emisor VARCHAR(100), nss_paciente VARCHAR(15)
) ON COMMIT DROP;

CREATE TEMP TABLE stg_cita (
    id_cita INT, fecha_hora_agendamiento TIMESTAMPTZ,
    fecha_hora_laboratorio TIMESTAMPTZ, estatus_asistencia enum_estatus_asistencia,
    folio_orden VARCHAR(20)
) ON COMMIT DROP;

CREATE TEMP TABLE stg_estudio (
    id_estudio INT, nombre_estudio VARCHAR(100), indicaciones_previas TEXT
) ON COMMIT DROP;

CREATE TEMP TABLE stg_prueba_sangre (
    id_estudio INT, tipo_tubo VARCHAR(50), color_tapon VARCHAR(30), ayuno_horas INT
) ON COMMIT DROP;

CREATE TEMP TABLE stg_prueba_orina (
    id_estudio INT, tipo_frasco VARCHAR(50), volumen_minimo VARCHAR(30)
) ON COMMIT DROP;

CREATE TEMP TABLE stg_prueba_fecal (
    id_estudio INT, tipo_frasco VARCHAR(50), requiere_medio_transporte BOOLEAN
) ON COMMIT DROP;

CREATE TEMP TABLE stg_orden_estudio (
    folio_orden VARCHAR(20), id_estudio INT
) ON COMMIT DROP;

CREATE TEMP TABLE stg_resultado (
    id_resultado INT, valor_obtenido VARCHAR(100), unidad_medida VARCHAR(30),
    rango_referencia VARCHAR(100), fecha_hora_emision TIMESTAMPTZ,
    observaciones TEXT, id_cita INT, id_estudio INT
) ON COMMIT DROP;

-- Carga masiva con \copy
\copy stg_paciente          FROM 'datos/paciente.csv'          CSV HEADER
\copy stg_paciente_telefono FROM 'datos/paciente_telefono.csv' CSV HEADER
\copy stg_orden_medica      FROM 'datos/orden_medica.csv'      CSV HEADER
\copy stg_cita              FROM 'datos/cita.csv'              CSV HEADER
\copy stg_estudio           FROM 'datos/estudio.csv'           CSV HEADER
\copy stg_prueba_sangre     FROM 'datos/prueba_sangre.csv'     CSV HEADER
\copy stg_prueba_orina      FROM 'datos/prueba_orina.csv'      CSV HEADER
\copy stg_prueba_fecal      FROM 'datos/prueba_fecal.csv'      CSV HEADER
\copy stg_orden_estudio     FROM 'datos/orden_estudio.csv'     CSV HEADER
\copy stg_resultado         FROM 'datos/resultado.csv'         CSV HEADER

-- Inserción ordenada con conteo de insertados vs omitidos/duplicados
DO $$
DECLARE
    v_ins INT;
    v_tot INT;
BEGIN
    -- 1. paciente (primero titulares, luego beneficiarios)
    SELECT COUNT(*) INTO v_tot FROM stg_paciente;
    INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion, nss_titular)
    SELECT nss, nombre, estatus_vigencia, unidad_medica_adscripcion, NULLIF(nss_titular, '')
      FROM stg_paciente
     WHERE NULLIF(nss_titular, '') IS NULL
    ON CONFLICT (nss) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;

    INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion, nss_titular)
    SELECT nss, nombre, estatus_vigencia, unidad_medica_adscripcion, nss_titular
      FROM stg_paciente
     WHERE NULLIF(nss_titular, '') IS NOT NULL
    ON CONFLICT (nss) DO NOTHING;
    GET DIAGNOSTICS v_tot = ROW_COUNT;
    v_ins := v_ins + v_tot;
    SELECT COUNT(*) INTO v_tot FROM stg_paciente;
    RAISE NOTICE 'Tabla paciente: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    -- 2. paciente_telefono
    SELECT COUNT(*) INTO v_tot FROM stg_paciente_telefono;
    INSERT INTO paciente_telefono (nss, telefono)
    SELECT nss, telefono FROM stg_paciente_telefono
    ON CONFLICT (nss, telefono) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla paciente_telefono: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    -- 3. orden_medica
    SELECT COUNT(*) INTO v_tot FROM stg_orden_medica;
    INSERT INTO orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
    SELECT folio_orden, fecha_cita_medico, medico_emisor, nss_paciente FROM stg_orden_medica
    ON CONFLICT (folio_orden) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla orden_medica: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    -- 4. cita
    SELECT COUNT(*) INTO v_tot FROM stg_cita;
    INSERT INTO cita (id_cita, fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia, folio_orden)
    SELECT id_cita, fecha_hora_agendamiento, fecha_hora_laboratorio, estatus_asistencia, folio_orden FROM stg_cita
    ON CONFLICT (id_cita) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla cita: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    -- 5. estudio y subtipos
    SELECT COUNT(*) INTO v_tot FROM stg_estudio;
    INSERT INTO estudio (id_estudio, nombre_estudio, indicaciones_previas)
    SELECT id_estudio, nombre_estudio, indicaciones_previas FROM stg_estudio
    ON CONFLICT (id_estudio) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla estudio: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    SELECT COUNT(*) INTO v_tot FROM stg_prueba_sangre;
    INSERT INTO prueba_sangre (id_estudio, tipo_tubo, color_tapon, ayuno_horas)
    SELECT id_estudio, tipo_tubo, color_tapon, ayuno_horas FROM stg_prueba_sangre
    ON CONFLICT (id_estudio) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla prueba_sangre: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    SELECT COUNT(*) INTO v_tot FROM stg_prueba_orina;
    INSERT INTO prueba_orina (id_estudio, tipo_frasco, volumen_minimo)
    SELECT id_estudio, tipo_frasco, volumen_minimo FROM stg_prueba_orina
    ON CONFLICT (id_estudio) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla prueba_orina: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    SELECT COUNT(*) INTO v_tot FROM stg_prueba_fecal;
    INSERT INTO prueba_fecal (id_estudio, tipo_frasco, requiere_medio_transporte)
    SELECT id_estudio, tipo_frasco, requiere_medio_transporte FROM stg_prueba_fecal
    ON CONFLICT (id_estudio) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla prueba_fecal: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    -- 6. orden_estudio
    SELECT COUNT(*) INTO v_tot FROM stg_orden_estudio;
    INSERT INTO orden_estudio (folio_orden, id_estudio)
    SELECT folio_orden, id_estudio FROM stg_orden_estudio
    ON CONFLICT (folio_orden, id_estudio) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla orden_estudio: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);

    -- 7. resultado
    SELECT COUNT(*) INTO v_tot FROM stg_resultado;
    INSERT INTO resultado (id_resultado, valor_obtenido, unidad_medida, rango_referencia, fecha_hora_emision, observaciones, id_cita, id_estudio)
    SELECT id_resultado, valor_obtenido, unidad_medida, rango_referencia, fecha_hora_emision, observaciones, id_cita, id_estudio FROM stg_resultado
    ON CONFLICT (id_resultado) DO NOTHING;
    GET DIAGNOSTICS v_ins = ROW_COUNT;
    RAISE NOTICE 'Tabla resultado: leidos=%, insertados=%, omitidos=%', v_tot, v_ins, (v_tot - v_ins);
END $$;

-- Sincronizar secuencias SERIAL
SELECT setval(pg_get_serial_sequence('cita', 'id_cita'), COALESCE((SELECT MAX(id_cita) FROM cita), 1));
SELECT setval(pg_get_serial_sequence('estudio', 'id_estudio'), COALESCE((SELECT MAX(id_estudio) FROM estudio), 1));
SELECT setval(pg_get_serial_sequence('resultado', 'id_resultado'), COALESCE((SELECT MAX(id_resultado) FROM resultado), 1));

COMMIT;
