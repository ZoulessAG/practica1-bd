# Ejercicio 8: Cambio de Esquema por Integrante

* **Alumno:** Sanchez Palma Joel
* **Usuario de GitHub:** `alcatel04`
* **Issue Vinculado:** [#7 - [Propuesta] Zonificación de Impacto Real mediante Isosistas (Polígonos Espaciales)](https://github.com/ZoulessAG/practica1-bd/issues/7)
* **Área:** Requisito de Ingeniería en Inteligencia Artificial

---

## 1. Justificación Técnica y Reglas de Transformación (Media Cuartilla)

### Regla de Transformación Aplicada
Se aplicó la **Regla 1 (Entidad Fuerte para Inferencia Geoespacial)** y la **Regla 4 (Propagación de Claves $1:N$)**. La tabla `isosistas_ai_predictions` estructura los polígonos y métricas de aceleración pico de terreno (PGA) inferidos por redes neuronales artificiales a partir de registros sismológicos escasos.

### Justificación de la Estrategia y Tipos de Datos Elegidos
1. **Representación de inferencias continuas:** En lugar de saturar la tabla de hechos con múltiples columnas de aceleración atenuada, se aísla cada modelo de interpolación neuronal en una tabla satélite que vincula al sismo causante (`id_sismo_origen`).
2. **Trazabilidad analítica:** El campo `version_modelo VARCHAR(50)` permite registrar la arquitectura de red neuronal empleada (ej. perceptrón multicapa vs convolucional espacial).
3. **Tipos de datos seleccionados:**
   * `aceleracion_pga_estimada_gal NUMERIC(6, 2)`: Expresa aceleración en unidades Gal ($cm/s^2$) con resolución decimal estandarizada.
   * `area_afectada_km2 NUMERIC(8, 2)`: Cuantificación del área de impacto superficial.
   * `probabilidad_amplificacion_suelo NUMERIC(5, 4)`: Intervalo $[0.0000, 1.0000]$ que califica el factor de sitio.

### Impacto en los Datos Existentes
La inclusión de esta tabla no genera impacto destructivo en los registros sismológicos históricos almacenados en el repositorio asignado.

---

## 2. Consulta Demostrativa

```sql
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
```
