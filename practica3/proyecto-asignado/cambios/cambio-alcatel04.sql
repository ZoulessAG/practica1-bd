-- ==============================================================================
-- Instituto Politécnico Nacional - ESCOM
-- Bases de Datos (Plan 2020) - Práctica 3
-- Ejercicio 8: Cambio de Esquema por Integrante (Individual)
-- Integrante: Sanchez Palma Joel
-- Usuario GitHub: alcatel04
-- Issue seleccionado: #6 "[Propuesta] Registro histórico de daños estructurales"
-- Área de Especialidad: Requisito de Ingeniería en Inteligencia Artificial
-- ==============================================================================


-- 1. Crear la tabla de unidades económicas (relacionada con los municipios del proyecto)
CREATE TABLE unidad_economica (
    id_unidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    giro_comercial VARCHAR(100) NOT NULL,
    anio_construccion INT CHECK (anio_construccion > 1800),
    id_municipio INT NOT NULL,
    CONSTRAINT fk_unidad_municipio FOREIGN KEY (id_municipio) 
        REFERENCES municipio(id_municipio) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2. Crear la tabla asociativa para registrar los daños por sismo (Relación M:N)
CREATE TABLE reporte_daño (
    id_sismo INT NOT NULL,
    id_unidad INT NOT NULL,
    nivel_colapso VARCHAR(50) CHECK (nivel_colapso IN ('Leve', 'Moderado', 'Total')),
    victimas_registradas INT DEFAULT 0,
    costo_estimado DECIMAL(12,2) DEFAULT 0.00,
    PRIMARY KEY (id_sismo, id_unidad),
    CONSTRAINT fk_daño_sismo FOREIGN KEY (id_sismo) 
        REFERENCES sismo(id_sismo) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_daño_unidad FOREIGN KEY (id_unidad) 
        REFERENCES unidad_economica(id_unidad) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

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
