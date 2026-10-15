# Ejercicio 8: Cambio de Esquema por Integrante

* **Alumna:** Quintanar Sanchez Alondra
* **Usuario de GitHub:** `AlooXoX`
* **Issue Vinculado:** [#8 - [Propuesta] Identificación y Visualización de Enjambres Sísmicos](https://github.com/ZoulessAG/practica1-bd/issues/8)
* **Área:** Requisito de Ingeniería en Inteligencia Artificial

---

## 1. Justificación Técnica y Reglas de Transformación (Media Cuartilla)

### Regla de Transformación Aplicada
Se aplicó la **Regla 1 (Entidad Fuerte para Inferencia No Supervisada)** y la **Regla 4 (Propagación de Claves $1:N$)**. La tabla `enjambre_ai_clusters` modela los centroides y propiedades calculadas por algoritmos no supervisados de minería de datos y agrupamiento espaciotemporal que califican eventos sísmicos individuales.

### Justificación de la Estrategia y Tipos de Datos Elegidos
1. **Modelado de agrupamientos:** Un enjambre sísmico engloba decenas o cientos de sismos en una ventana de tiempo estrecha. Guardar el resultado en una tabla independiente permite que múltiples análisis y reclasificaciones convivan sin duplicar filas en la tabla base de eventos.
2. **Trazabilidad y reproducibilidad:** El atributo `version_modelo VARCHAR(50)` permite comparar desempeños entre versiones de DBSCAN o algoritmos bayesianos.
3. **Tipos de datos seleccionados:**
   * `probabilidad_enjambre NUMERIC(5, 4)`: Precisión exacta para cuantificar certidumbre estadística.
   * `tasa_eventos_hora NUMERIC(5, 2)`: Métrica de frecuencia de actividad.
   * `es_reactivacion_volcanica BOOLEAN`: Bandera booleana de alerta temprana para protección civil en zonas volcánicas.

### Impacto en los Datos Existentes
La estrategia no modifica esquemas previos ni exige migración de datos. La tabla se llena de forma incremental a medida que los modelos de agrupamiento procesan la información sísmica.

---

## 2. Consulta Demostrativa

```sql
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
```
