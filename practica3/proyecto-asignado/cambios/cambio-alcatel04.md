# Ejercicio 8: Cambio de Esquema por Integrante

* **Alumno:** Sanchez Palma Joel
* **Usuario de GitHub:** `alcatel04`
* **Issue Vinculado:** [#6 - [Propuesta] Registro Histórico de Daños Estructurales](https://github.com/ZoulessAG/practica1-bd/issues/6)
* **Área:** Requisito de Ingeniería en Inteligencia Artificial

---

## 1. Justificación Técnica y Reglas de Transformación (Media Cuartilla)

### Regla de Transformación Aplicada
Se aplicó la **Regla 1 (Entidad Fuerte)** para la entidad `unidad_economica` y la **Regla 5 (Relación N:M con Atributos Propios / Tabla Asociativa)** para `reporte_dano`. La tabla `reporte_dano` conecta la ocurrencia sísmica con la infraestructura afectada y hospeda los campos derivados de modelos de Aprendizaje Automático supervisado (redes neuronales convolucionales y árboles de decisión) entrenados para estimar probabilidad de colapso y clasificar anomalías de vulnerabilidad estructural pos-evento.

### Justificación de la Estrategia y Tipos de Datos Elegidos
1. **Modelado relacional asociativo:** Una unidad económica o edificio público puede experimentar múltiples eventos sísmicos a lo largo de su vida útil, y un sismo mayor afecta a cientos de inmuebles simultáneamente. La tabla intermedia `reporte_dano` con clave primaria compuesta `(id_sismo, id_unidad)` garantiza unicidad del reporte sin generar redundancia.
2. **Requisitos de Inteligencia Artificial y MLOps:**
   * `probabilidad_colapso NUMERIC(5, 4)`: Almacena valores continuos en el intervalo $[0.0000, 1.0000]$ con cuatro posiciones decimales fijas, eliminando discrepancias de redondeo en aritmética flotante.
   * `es_anomalia_estructural BOOLEAN`: Indicador booleano para priorizar inmuebles con deformación imprevista no explicable por la distancia epicentral.
   * `version_modelo VARCHAR(50)`: Registro del modelo exacto inferido (ej. `damage-eval-ann-v1.0`).
   * `fecha_prediccion TIMESTAMP WITH TIME ZONE`: Marca temporal exacta para auditoría de protección civil.

### Impacto en los Datos Existentes
La creación de las tablas `unidad_economica` y `reporte_dano` es puramente aditiva (*non-breaking schema evolution*). No modifica la estructura de las tablas base preexistentes del repositorio sísmico ni interrumpe consultas en ejecución.

---

## 2. Consulta Demostrativa

```sql
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
```

### Resultado de la Consulta
| id_sismo | unidad_economica | giro_comercial | nivel_colapso | probabilidad_colapso_pct | costo_estimado | es_anomalia_estructural | version_modelo | fecha_prediccion |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 301 | Escuela Secundaria Tecnica 14 | Educacion | Total | 94.20 | 8500000.00 | true | damage-eval-ann-v1.0 | 2026-10-14 23:15:00-06 |
| 301 | Hospital General Regional | Salud Publica | Moderado | 78.50 | 1500000.00 | true | damage-eval-ann-v1.0 | 2026-10-14 23:15:00-06 |
