-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Bases de Datos (Plan 2020) - Práctica 3
-- Ejercicio 8: Cambio de Esquema por Integrante (Individual)
-- Integrante: Quintanar Sanchez Alondra
-- Usuario GitHub: AlooXoX
-- Issue seleccionado: #8 "[Propuesta] Identificación y Visualización de Enjambres Sísmicos"
-- Área de Especialidad: Requisito de Ingeniería en Inteligencia Artificial
-- ==============================================================================

-- 1. CREACIÓN DE TABLA: enjambre_ai_clusters
-- Almacena agrupamientos no supervisados y predicciones generadas por modelos de IA
-- (algoritmos DBSCAN espaciotemporal / Gaussian Mixture Models) para secuencias de enjambres.
CREATE TABLE IF NOT EXISTS enjambre_ai_clusters (
    id_cluster SERIAL PRIMARY KEY,
    id_sismo_referencia INT NOT NULL,
    probabilidad_enjambre NUMERIC(5, 4) NOT NULL,
    tasa_eventos_hora NUMERIC(5, 2) NOT NULL,
    radio_afectacion_km NUMERIC(5, 2) NOT NULL,
    fase_enjambre VARCHAR(20) NOT NULL,
    es_reactivacion_volcanica BOOLEAN DEFAULT FALSE,
    version_modelo VARCHAR(50) NOT NULL,
    fecha_deteccion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_prob_enjambre CHECK (probabilidad_enjambre >= 0.0000 AND probabilidad_enjambre <= 1.0000),
    CONSTRAINT chk_fase CHECK (fase_enjambre IN ('INICIACION', 'PICO', 'DISPERSION'))
);

COMMENT ON TABLE enjambre_ai_clusters IS 'Clústeres y detecciones de enjambres sísmicos producidos por algoritmos de Machine Learning.';

-- 2. DATOS DE DEMOSTRACIÓN
INSERT INTO enjambre_ai_clusters 
(id_sismo_referencia, probabilidad_enjambre, tasa_eventos_hora, radio_afectacion_km, fase_enjambre, es_reactivacion_volcanica, version_modelo)
VALUES 
(201, 0.9420, 18.50, 12.30, 'PICO', TRUE, 'swarm-spatiotemporal-dbscan-v1.4'),
(202, 0.7850, 8.20, 25.00, 'INICIACION', FALSE, 'swarm-spatiotemporal-dbscan-v1.4'),
(203, 0.3100, 2.10, 50.00, 'DISPERSION', FALSE, 'swarm-spatiotemporal-dbscan-v1.4');

-- 3. CONSULTA DEMOSTRATIVA
SELECT 
    id_cluster,
    id_sismo_referencia,
    ROUND(probabilidad_enjambre * 100, 2) AS pct_probabilidad,
    tasa_eventos_hora,
    radio_afectacion_km,
    fase_enjambre,
    es_reactivacion_volcanica,
    version_modelo,
    fecha_deteccion
FROM enjambre_ai_clusters
WHERE probabilidad_enjambre >= 0.70
ORDER BY tasa_eventos_hora DESC;
