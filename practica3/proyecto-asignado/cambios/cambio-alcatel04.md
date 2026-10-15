# Ejercicio 8: Cambio de Esquema por Integrante

* **Alumno:** Sánchez Palma Joel
* **Usuario de GitHub:** `alcatel04`
* **Issue Vinculado:** [#6 - [Propuesta] Registro histórico de daños estructurales](https://github.com/ZoulessAG/practica1-bd/issues/7)
* **Área:** Requisito de Ingeniería en Inteligencia Artificial

---

## 1. Justificación Técnica y Reglas de Transformación

Nota de Transformación y Impacto de Datos:
Regla de transformación aplicada: Para implementar esta propuesta sobre el modelo relacional preexistente del proyecto, se aplicó la regla de traducción de una
relación de Muchos a Muchos (M:N) entre entidades independientes (Sismo y Unidad_Economica). Dado que una relación M:N no puede coexistir de forma directa en tablas
relacionales sin normalizar, se transformó mediante la creación de una entidad asociativa (tabla intermedia) denominada reporte_daño. Esta entidad absorbe las
llaves primarias de ambas tablas como llaves foráneas compuestas y almacena los atributos descriptivos propios de la interacción (nivel de colapso, víctimas y
costo estimado). Asimismo, se estableció una relación de Uno a Muchos (1:N) entre la entidad Municipio (del esquema original) y la nueva entidad Unidad_Economica
mediante una llave foránea (id_municipio).
Elección de la estrategia: Se eligió esta arquitectura normalizada (en lugar de añadir columnas planas en la tabla de sismos o de unidades) porque preserva la 
flexibilidad y la escalabilidad del sistema. Permite que un mismo edificio o negocio pueda acumular historial de afectaciones a lo largo del tiempo ante múltiples
sismos, y a su vez, que un sismo afecte de manera independiente a múltiples unidades económicas sin redundancia de datos ni pérdida de integridad referencial.
Comportamiento con los datos existentes: Al tratarse de tablas de nueva creación (unidad_economica y reporte_daño) y de la adición de restricciones con tablas
maestras ya pobladas, los datos históricos que ya existían en el proyecto base (como los sismos y los municipios anteriores) no sufren alteraciones destructivas.
Las tablas nuevas se inicializan vacías; por lo tanto, no se pierden registros previos. Sin embargo, para que la consulta analítica funcione y devuelva resultados 
significativos, es necesario realizar una inserción posterior de datos de prueba en estas nuevas tablas (asociando unidades económicas reales de los municipios 
existentes a los sismos registrados históricamente).

---

## 2. Script DDL y Consulta Demostrativa

El script DDL se encuentra disponible en [`cambio-alcatel04.sql`](./cambio-alcatel04.sql).

### Consulta Demostrativa (Ejecutable en Clase)
```sql
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
```

### Resultado de la Consulta

| id_prediccion | id_evento_origen | nivel_alerta | probabilidad_porcentaje | replica_magnitud_esperada | ventana_tiempo_horas | es_anomalia | version_modelo | fecha_generacion |

|---|---|---|---|---|---|---|---|---|

| 1 | 101 | CRITICO | 88.50 | 6.2 | 24 | true | aftershock-net-v1.4.2 | 2026-10-13 15:52:00-06 |
