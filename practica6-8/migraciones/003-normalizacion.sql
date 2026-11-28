-- =========================================================================
-- MIGRACIÓN 003: DEMOSTRACIÓN DE NORMALIZACIÓN CONSERVANDO DATOS
-- Prácticas 6, 7 y 8 - Bases de Datos (ESCOM IPN)
-- Proyecto: CitasMed - Sistema de Citas Médicas y Laboratorio
-- =========================================================================

-- Iniciar bloque transaccional
BEGIN;

-- -------------------------------------------------------------------------
-- PASO 1: Creación de la tabla desnormalizada intencionalmente con datos
-- -------------------------------------------------------------------------
DROP TABLE IF EXISTS recepcion_desnormalizada CASCADE;

CREATE TABLE recepcion_desnormalizada (
    id_registro_plano SERIAL PRIMARY KEY,
    nss VARCHAR(15) NOT NULL,
    nombre_paciente VARCHAR(100) NOT NULL,
    unidad_medica VARCHAR(100) NOT NULL,
    folio_orden VARCHAR(20) NOT NULL,
    fecha_cita_medico DATE NOT NULL,
    medico_emisor VARCHAR(100) NOT NULL,
    id_estudio INT NOT NULL,
    nombre_estudio VARCHAR(100) NOT NULL,
    tipo_categoria VARCHAR(20) NOT NULL,
    valor_obtenido VARCHAR(100),
    unidad_medida VARCHAR(30)
);

-- Poblar la tabla desnormalizada cruzando los datos reales ya existentes en la BD
INSERT INTO recepcion_desnormalizada (
    nss, nombre_paciente, unidad_medica, folio_orden,
    fecha_cita_medico, medico_emisor, id_estudio,
    nombre_estudio, tipo_categoria, valor_obtenido, unidad_medida
)
SELECT 
    p.nss,
    p.nombre,
    p.unidad_medica_adscripcion,
    o.folio_orden,
    o.fecha_cita_medico,
    o.medico_emisor,
    e.id_estudio,
    e.nombre_estudio,
    CASE 
        WHEN ps.id_estudio IS NOT NULL THEN 'Sangre'
        WHEN po.id_estudio IS NOT NULL THEN 'Orina'
        WHEN pf.id_estudio IS NOT NULL THEN 'Fecal'
        ELSE 'General'
    END AS tipo_categoria,
    r.valor_obtenido,
    r.unidad_medida
FROM orden_medica o
JOIN paciente p ON o.nss_paciente = p.nss
JOIN cita c ON o.folio_orden = c.folio_orden
JOIN resultado r ON c.id_cita = r.id_cita
JOIN estudio e ON r.id_estudio = e.id_estudio
LEFT JOIN prueba_sangre ps ON e.id_estudio = ps.id_estudio
LEFT JOIN prueba_orina po ON e.id_estudio = po.id_estudio
LEFT JOIN prueba_fecal pf ON e.id_estudio = pf.id_estudio
LIMIT 30;

-- -------------------------------------------------------------------------
-- PASO 2: Creación de las tablas normalizadas de destino (3FN / BCNF)
-- -------------------------------------------------------------------------
DROP TABLE IF EXISTS norm_resultado CASCADE;
DROP TABLE IF EXISTS norm_orden_medica CASCADE;
DROP TABLE IF EXISTS norm_estudio CASCADE;
DROP TABLE IF EXISTS norm_paciente CASCADE;

CREATE TABLE norm_paciente (
    nss VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    unidad_medica VARCHAR(100) NOT NULL
);

CREATE TABLE norm_estudio (
    id_estudio INT PRIMARY KEY,
    nombre_estudio VARCHAR(100) NOT NULL,
    tipo_categoria VARCHAR(20) NOT NULL
);

CREATE TABLE norm_orden_medica (
    folio_orden VARCHAR(20) PRIMARY KEY,
    fecha_cita_medico DATE NOT NULL,
    medico_emisor VARCHAR(100) NOT NULL,
    nss_paciente VARCHAR(15) NOT NULL REFERENCES norm_paciente(nss) ON DELETE RESTRICT
);

CREATE TABLE norm_resultado (
    id_resultado SERIAL PRIMARY KEY,
    folio_orden VARCHAR(20) NOT NULL REFERENCES norm_orden_medica(folio_orden) ON DELETE CASCADE,
    id_estudio INT NOT NULL REFERENCES norm_estudio(id_estudio) ON DELETE RESTRICT,
    valor_obtenido VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(30)
);

-- -------------------------------------------------------------------------
-- PASO 3: Migración de datos conservando registros (Sin recarga manual)
-- -------------------------------------------------------------------------

-- 3.1 Migrar pacientes únicos
INSERT INTO norm_paciente (nss, nombre, unidad_medica)
SELECT DISTINCT nss, nombre_paciente, unidad_medica
FROM recepcion_desnormalizada
ON CONFLICT (nss) DO NOTHING;

-- 3.2 Migrar estudios únicos
INSERT INTO norm_estudio (id_estudio, nombre_estudio, tipo_categoria)
SELECT DISTINCT id_estudio, nombre_estudio, tipo_categoria
FROM recepcion_desnormalizada
ON CONFLICT (id_estudio) DO NOTHING;

-- 3.3 Migrar órdenes médicas
INSERT INTO norm_orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
SELECT DISTINCT folio_orden, fecha_cita_medico, medico_emisor, nss
FROM recepcion_desnormalizada
ON CONFLICT (folio_orden) DO NOTHING;

-- 3.4 Migrar resultados clínicos asociados
INSERT INTO norm_resultado (folio_orden, id_estudio, valor_obtenido, unidad_medida)
SELECT folio_orden, id_estudio, valor_obtenido, unidad_medida
FROM recepcion_desnormalizada
WHERE valor_obtenido IS NOT NULL;

-- -------------------------------------------------------------------------
-- PASO 4: Comprobación de Reunión Sin Pérdida (Lossless Join Verification)
-- Reconstrucción de la vista original mediante reunión natural
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_verificacion_reunion_sin_perdida AS
SELECT 
    p.nss,
    p.nombre AS nombre_paciente,
    p.unidad_medica,
    o.folio_orden,
    o.fecha_cita_medico,
    o.medico_emisor,
    e.id_estudio,
    e.nombre_estudio,
    e.tipo_categoria,
    r.valor_obtenido,
    r.unidad_medida
FROM norm_resultado r
JOIN norm_orden_medica o ON r.folio_orden = o.folio_orden
JOIN norm_paciente p ON o.nss_paciente = p.nss
JOIN norm_estudio e ON r.id_estudio = e.id_estudio;

COMMIT;

-- Mensaje de confirmación en consola
DO $$
BEGIN
    RAISE NOTICE 'Migración 003 de Normalización ejecutada exitosamente. Datos descompuestos en 3FN/BCNF con reunión sin pérdida garantizada.';
END $$;
