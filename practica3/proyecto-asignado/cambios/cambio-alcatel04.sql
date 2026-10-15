-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Bases de Datos (Plan 2020) - Práctica 3
-- Ejercicio 8: Cambio de Esquema por Integrante (Individual)
-- Integrante: Sanchez Palma Joel
-- Usuario GitHub: alcatel04
-- Issue seleccionado: #6 "[Propuesta] Registro Histórico de Daños Estructurales"
-- Área de Especialidad: Requisito de Ingeniería en Inteligencia Artificial
-- ==============================================================================

-- 1. Tabla de unidades económicas / infraestructura pública
CREATE TABLE IF NOT EXISTS unidad_economica (
    id_unidad SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    giro_comercial VARCHAR(100) NOT NULL,
    anio_construccion INT CHECK (anio_construccion > 1800),
    id_municipio INT NOT NULL,
    CONSTRAINT fk_unidad_municipio FOREIGN KEY (id_municipio) 
        REFERENCES municipio(id_municipio) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2. Tabla asociativa para registrar daños por sismo con inferencias de IA
CREATE TABLE IF NOT EXISTS reporte_dano (
    id_sismo INT NOT NULL,
    id_unidad INT NOT NULL,
    nivel_colapso VARCHAR(50) CHECK (nivel_colapso IN ('Leve', 'Moderado', 'Total', 'Severo')),
    victimas_registradas INT DEFAULT 0,
    costo_estimado DECIMAL(12,2) DEFAULT 0.00,
    -- Campos requeridos por especialidad de Inteligencia Artificial
    probabilidad_colapso NUMERIC(5, 4) NOT NULL DEFAULT 0.0000,
    es_anomalia_estructural BOOLEAN DEFAULT FALSE,
    version_modelo VARCHAR(50) NOT NULL DEFAULT 'damage-eval-ann-v1.0',
    fecha_prediccion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reporte_dano PRIMARY KEY (id_sismo, id_unidad),
    CONSTRAINT chk_prob_colapso CHECK (probabilidad_colapso >= 0.0000 AND probabilidad_colapso <= 1.0000),
    CONSTRAINT fk_dano_sismo FOREIGN KEY (id_sismo) 
        REFERENCES sismo(id_sismo) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_dano_unidad FOREIGN KEY (id_unidad) 
        REFERENCES unidad_economica(id_unidad) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Datos de demostración
INSERT INTO unidad_economica (id_unidad, nombre, giro_comercial, anio_construccion, id_municipio)
VALUES 
(1, 'Hospital General Regional', 'Salud Publica', 1985, 101),
(2, 'Escuela Secundaria Tecnica 14', 'Educacion', 1978, 101)
ON CONFLICT (id_unidad) DO NOTHING;

INSERT INTO reporte_dano (id_sismo, id_unidad, nivel_colapso, victimas_registradas, costo_estimado, probabilidad_colapso, es_anomalia_estructural, version_modelo)
VALUES 
(301, 1, 'Moderado', 0, 1500000.00, 0.7850, TRUE, 'damage-eval-ann-v1.0'),
(301, 2, 'Total', 2, 8500000.00, 0.9420, TRUE, 'damage-eval-ann-v1.0')
ON CONFLICT (id_sismo, id_unidad) DO NOTHING;

-- 4. Consulta demostrativa
SELECT 
    r.id_sismo,
    u.nombre AS unidad_economica,
    u.giro_comercial,
    r.nivel_colapso,
    ROUND(r.probabilidad_colapso * 100, 2) AS probabilidad_colapso_pct,
    r.costo_estimado,
    r.es_anomalia_estructural,
    r.version_modelo,
    r.fecha_prediccion
FROM reporte_dano r
JOIN unidad_economica u ON r.id_unidad = u.id_unidad
WHERE r.probabilidad_colapso >= 0.70
ORDER BY r.probabilidad_colapso DESC;
