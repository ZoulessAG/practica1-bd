-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Bases de Datos (Plan 2020) - Práctica 3
-- Ejercicio 8: Cambio de Esquema por Integrante (Individual)
-- Integrante: Aguilar Garcia Ian Andrew
-- Usuario GitHub: ZoulessAG
-- Issue seleccionado: #2 "[Propuesta] Sistema de alertas tempranas y cálculo de réplicas en tiempo real"
-- Área de Especialidad: Requisito de Ingeniería en Inteligencia Artificial
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. CREACIÓN DE TABLA: replica_ai_predictions
-- Guarda las inferencias generadas por modelos de Machine Learning (ej. LSTM / Random Forest)
-- ------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS replica_ai_predictions (
    id_prediccion SERIAL,
    id_evento_origen INT NOT NULL,                  -- Referencia al hecho que califica (sismo principal)
    probabilidad_replica NUMERIC(5, 4) NOT NULL,    -- Probabilidad [0.0000 a 1.0000]
    magnitud_estimada NUMERIC(3, 1) NOT NULL,       -- Magnitud estimada de la réplica máxima esperada
    ventana_tiempo_horas INT NOT NULL,             -- Ventana de tiempo analizada (ej. 24, 48 horas)
    nivel_alerta VARCHAR(20) NOT NULL,              -- 'VERDE', 'AMARILLO', 'ROJO', 'CRITICO'
    es_anomalia BOOLEAN DEFAULT FALSE,             -- Bandera indicadora de comportamiento anómalo
    version_modelo VARCHAR(50) NOT NULL,           -- Versión del modelo (ej. 'aftershock-net-v1.4.2')
    fecha_generacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Marca de tiempo de la predicción
    
    -- Restricciones de Clave y Dominio
    CONSTRAINT pk_replica_ai PRIMARY KEY (id_prediccion),
    CONSTRAINT chk_probabilidad CHECK (probabilidad_replica >= 0.0000 AND probabilidad_replica <= 1.0000),
    CONSTRAINT chk_magnitud CHECK (magnitud_estimada >= 0.0 AND magnitud_estimada <= 10.0),
    CONSTRAINT chk_alerta CHECK (nivel_alerta IN ('VERDE', 'AMARILLO', 'ROJO', 'CRITICO'))
);

-- Comentarios explicativos en el catálogo de PostgreSQL (Documentación embebida)
COMMENT ON TABLE replica_ai_predictions IS 'Almacén de inferencias y anomalías producidas por modelos de IA para eventos sísmicos.';
COMMENT ON COLUMN replica_ai_predictions.id_evento_origen IS 'Referencia al evento sísmico calificado.';
COMMENT ON COLUMN replica_ai_predictions.probabilidad_replica IS 'Probabilidad inferida por el modelo entre 0 y 1 con 4 decimales de precisión.';
COMMENT ON COLUMN replica_ai_predictions.version_modelo IS 'Identificador de versión del artefacto de ML usado para trazabilidad.';

-- ------------------------------------------------------------------------------
-- 2. DATOS DE DEMOSTRACIÓN / PRUEBA
-- ------------------------------------------------------------------------------
INSERT INTO replica_ai_predictions 
(id_evento_origen, probabilidad_replica, magnitud_estimada, ventana_tiempo_horas, nivel_alerta, es_anomalia, version_modelo)
VALUES 
(101, 0.8850, 6.2, 24, 'CRITICO', TRUE, 'aftershock-net-v1.4.2'),
(102, 0.4210, 4.5, 48, 'AMARILLO', FALSE, 'aftershock-net-v1.4.2'),
(103, 0.1500, 3.8, 24, 'VERDE', FALSE, 'aftershock-net-v1.4.2');

-- ------------------------------------------------------------------------------
-- 3. CONSULTA QUE SOLO ES POSIBLE TRAS EL CAMBIO (Punto 3 del Ejercicio 8)
-- Recupera los eventos sísmicos que tienen alertas críticas de réplica inferidas por el modelo
-- ------------------------------------------------------------------------------
SELECT 
    p.id_prediccion,
    p.id_evento_origen,
    p.nivel_alerta,
    ROUND(p.probabilidad_replica * 100, 2) AS probabilidad_porcentaje,
    p.magnitud_estimada AS replica_magnitud_esperada,
    p.ventana_tiempo_horas,
    p.es_anomalia,
    p.version_modelo,
    p.fecha_generacion
FROM replica_ai_predictions p
WHERE p.nivel_alerta IN ('ROJO', 'CRITICO') 
  AND p.probabilidad_replica >= 0.75
ORDER BY p.probabilidad_replica DESC;
