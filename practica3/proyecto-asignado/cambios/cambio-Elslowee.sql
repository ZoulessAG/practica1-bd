-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Bases de Datos (Plan 2020) - Práctica 3
-- Ejercicio 8: Cambio de Esquema por Integrante (Individual)
-- Integrante: Vega Treviño Kevin Edu
-- Usuario GitHub: Elslowee
-- Issue seleccionado: #14 "[Propuesta] Intersección Espacial con Infraestructura Crítica"
-- Área de Especialidad: Requisito de Ingeniería en Inteligencia Artificial
-- ==============================================================================

-- 1. CREACIÓN DE TABLA: infraestructura_ai_vulnerability
-- Almacena las inferencias de modelos de Machine Learning (Random Forest / Gradient Boosting)
-- sobre la vulnerabilidad y probabilidad de daño en infraestructura crítica tras un sismo.
CREATE TABLE IF NOT EXISTS infraestructura_ai_vulnerability (
    id_evaluacion SERIAL PRIMARY KEY,
    id_sismo_origen INT NOT NULL,
    id_activo_infraestructura INT NOT NULL,
    probabilidad_danio NUMERIC(5, 4) NOT NULL,
    indice_vulnerabilidad NUMERIC(4, 2) NOT NULL,
    prioridad_inspeccion VARCHAR(20) NOT NULL,
    anomalia_estructural BOOLEAN DEFAULT FALSE,
    version_modelo VARCHAR(50) NOT NULL,
    fecha_analisis TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_prob_danio CHECK (probabilidad_danio >= 0.0000 AND probabilidad_danio <= 1.0000),
    CONSTRAINT chk_prioridad CHECK (prioridad_inspeccion IN ('BAJA', 'MEDIA', 'ALTA', 'URGENTE'))
);

COMMENT ON TABLE infraestructura_ai_vulnerability IS 'Predicciones de riesgo y vulnerabilidad en infraestructura calculadas por IA.';

-- 2. DATOS DE DEMOSTRACIÓN
INSERT INTO infraestructura_ai_vulnerability 
(id_sismo_origen, id_activo_infraestructura, probabilidad_danio, indice_vulnerabilidad, prioridad_inspeccion, anomalia_estructural, version_modelo)
VALUES 
(101, 5001, 0.9120, 8.75, 'URGENTE', TRUE, 'infra-risk-gbdt-v2.1'),
(101, 5002, 0.6450, 5.20, 'ALTA', FALSE, 'infra-risk-gbdt-v2.1'),
(102, 5003, 0.1200, 1.80, 'BAJA', FALSE, 'infra-risk-gbdt-v2.1');

-- 3. CONSULTA DEMOSTRATIVA
SELECT 
    id_evaluacion,
    id_sismo_origen,
    id_activo_infraestructura,
    ROUND(probabilidad_danio * 100, 2) AS pct_probabilidad_danio,
    indice_vulnerabilidad,
    prioridad_inspeccion,
    anomalia_estructural,
    version_modelo,
    fecha_analisis
FROM infraestructura_ai_vulnerability
WHERE prioridad_inspeccion IN ('ALTA', 'URGENTE')
ORDER BY probabilidad_danio DESC;
