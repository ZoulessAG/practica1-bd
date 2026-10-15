-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Bases de Datos (Plan 2020) - Práctica 3
-- Ejercicio 8: Cambio de Esquema por Integrante (Individual)
-- Integrante: Sanchez Palma Joel
-- Usuario GitHub: alcatel04
-- Issue seleccionado: #7 "[Propuesta] Zonificación de Impacto Real mediante Isosistas (Polígonos Espaciales)"
-- Área de Especialidad: Requisito de Ingeniería en Inteligencia Artificial
-- ==============================================================================

-- 1. CREACIÓN DE TABLA: isosistas_ai_predictions
-- Almacena las inferencias geoespaciales y contornos de aceleración máxima (PGA)
-- generados por Redes Neuronales Artificiales (ANN / Kriging neuronal) tras un evento sísmico.
CREATE TABLE IF NOT EXISTS isosistas_ai_predictions (
    id_prediccion_isosista SERIAL PRIMARY KEY,
    id_sismo_origen INT NOT NULL,
    aceleracion_pga_estimada_gal NUMERIC(6, 2) NOT NULL,
    area_afectada_km2 NUMERIC(8, 2) NOT NULL,
    nivel_sacudida VARCHAR(20) NOT NULL,
    probabilidad_amplificacion_suelo NUMERIC(5, 4) NOT NULL,
    anomalia_atenuacion BOOLEAN DEFAULT FALSE,
    version_modelo VARCHAR(50) NOT NULL,
    fecha_calculo TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_prob_suelo CHECK (probabilidad_amplificacion_suelo >= 0.0000 AND probabilidad_amplificacion_suelo <= 1.0000),
    CONSTRAINT chk_nivel_sacudida CHECK (nivel_sacudida IN ('LEVE', 'MODERADO', 'FUERTE', 'SEVERO', 'DESTRUCTIVO'))
);

COMMENT ON TABLE isosistas_ai_predictions IS 'Predicciones de isosistas y atenuación de ondas calculadas mediante redes neuronales.';

-- 2. DATOS DE DEMOSTRACIÓN
INSERT INTO isosistas_ai_predictions 
(id_sismo_origen, aceleracion_pga_estimada_gal, area_afectada_km2, nivel_sacudida, probabilidad_amplificacion_suelo, anomalia_atenuacion, version_modelo)
VALUES 
(301, 245.80, 1420.50, 'SEVERO', 0.8920, TRUE, 'pga-spatial-ann-v1.3'),
(301, 110.20, 3850.00, 'MODERADO', 0.5400, FALSE, 'pga-spatial-ann-v1.3'),
(302, 35.10, 850.20, 'LEVE', 0.1500, FALSE, 'pga-spatial-ann-v1.3');

-- 3. CONSULTA DEMOSTRATIVA
SELECT 
    id_prediccion_isosista,
    id_sismo_origen,
    aceleracion_pga_estimada_gal,
    area_afectada_km2,
    nivel_sacudida,
    ROUND(probabilidad_amplificacion_suelo * 100, 2) AS pct_amplificacion,
    anomalia_atenuacion,
    version_modelo,
    fecha_calculo
FROM isosistas_ai_predictions
WHERE nivel_sacudida IN ('FUERTE', 'SEVERO', 'DESTRUCTIVO')
ORDER BY aceleracion_pga_estimada_gal DESC;
