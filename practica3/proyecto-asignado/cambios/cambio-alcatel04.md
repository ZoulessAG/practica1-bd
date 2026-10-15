# Ejercicio 8: Cambio de Esquema por Integrante

* **Alumno:** Sánchez Palma Joel
* **Usuario de GitHub:** `alcatel04`
* **Issue Vinculado:** [#6 - [Propuesta] Registro histórico de daños estructurales](https://github.com/ZoulessAG/practica1-bd/issues/6)
* **Área:** Requisito de Ingeniería en Inteligencia Artificial

---

## 1. Justificación Técnica y Reglas de Transformación

### Regla de Transformación Aplicada
Para implementar esta propuesta sobre el modelo relacional preexistente del proyecto, se aplicó la regla de traducción de una relación de Muchos a Muchos (M:N) entre entidades independientes (Sismo y Unidad_Economica). Dado que una relación M:N no puede coexistir de forma directa en tablas relacionales sin normalizar, se transformó mediante la creación de una entidad asociativa (tabla intermedia) denominada reporte_daño. Esta entidad absorbe las llaves primarias de ambas tablas como llaves foráneas compuestas y almacena los atributos descriptivos propios de la interacción (nivel de colapso, víctimas y costo estimado). Asimismo, se estableció una relación de Uno a Muchos (1:N) entre la entidad Municipio (del esquema original) y la nueva entidad Unidad_Economica mediante una llave foránea (id_municipio).

### Elección de la Estrategia y Requisito de Inteligencia Artificial
Se eligió esta arquitectura normalizada (en lugar de añadir columnas planas en la tabla de sismos o de unidades) porque preserva la flexibilidad y la escalabilidad del sistema. Permite que un mismo edificio o negocio pueda acumular historial de afectaciones a lo largo del tiempo ante múltiples sismos, y a su vez, que un sismo afecte de manera independiente a múltiples unidades económicas sin redundancia de datos ni pérdida de integridad referencial. Para el requisito de Inteligencia Artificial, la tabla asociativa prevé la incorporación de métricas analíticas de predicción de colapso y anomalías estructurales pos-evento calculadas por modelos de Machine Learning: `probabilidad_colapso NUMERIC(5, 4)`, `es_anomalia_estructural BOOLEAN`, `version_modelo VARCHAR(50)` y `fecha_prediccion TIMESTAMP WITH TIME ZONE`.

### Comportamiento con los Datos Existentes
Al tratarse de tablas de nueva creación (unidad_economica y reporte_daño) y de la adición de restricciones con tablas maestras ya pobladas, los datos históricos que ya existían en el proyecto base (como los sismos y los municipios anteriores) no sufren alteraciones destructivas (*zero-downtime*). Las tablas nuevas se inicializan vacías; por lo tanto, no se pierden registros previos.

---

## 2. Script DDL y Consulta Demostrativa

El script DDL se encuentra disponible en [`cambio-alcatel04.sql`](./cambio-alcatel04.sql).

### Consulta Demostrativa (Ejecutable en Clase)
```sql
SELECT 
    m.nombre_municipio,
    COUNT(DISTINCT s.id_sismo) AS total_sismos_afectantes,
    COUNT(rd.id_unidad) AS unidades_afectadas_historico,
    SUM(rd.victimas_registradas) AS total_victimas_infraestructura,
    SUM(rd.costo_estimado) AS costo_total_perdidas
FROM municipio m
JOIN unidad_economica ue ON m.id_municipio = ue.id_municipio
JOIN reporte_daño rd ON ue.id_unidad = rd.id_unidad
JOIN sismo s ON rd.id_sismo = s.id_sismo
WHERE s.magnitud > 6.0
GROUP BY m.id_municipio, m.nombre_municipio
ORDER BY costo_total_perdidas DESC;
```

### Resultado de la Consulta

| nombre_municipio | total_sismos_afectantes | unidades_afectadas_historico | total_victimas_infraestructura | costo_total_perdidas ($ MXN) |
| :--- | :---: | :---: | :---: | :---: |
| **Cuauhtémoc (CDMX)** | 2 | 15 | 42 | $145,500,000.00 |
