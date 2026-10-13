# Ejercicio 8: Cambio de Esquema por Integrante

* **Alumno:** Aguilar Garcia Ian Andrew
* **Usuario de GitHub:** `ZoulessAG`
* **Issue Vinculado:** [#2 - [Propuesta] Sistema de alertas tempranas y cálculo de réplicas en tiempo real](https://github.com/ZoulessAG/practica1-bd/issues/2)
* **Área:** Requisito de Ingeniería en Inteligencia Artificial

---

## 1. Justificación Técnica y Reglas de Transformación (Media Cuartilla)

### Regla de Transformación Aplicada
Se aplicó la **Regla 4 (Relación 1 a N / Entidad Débil por Identificación / Dependencia de Existencia)** y la **Regla 1 (Entidad Fuerte para Resultados Analíticos)**. La entidad `replica_ai_predictions` se estructura como una tabla receptora de hechos generados por un proceso analítico externo (inferencia de Aprendizaje Automático). Cada predicción califica a un hecho sísmico preexistente (`id_evento_origen`), existiendo una relación $1:N$ donde un evento sísmico puede ser evaluado por múltiples versiones de modelos o en diferentes ventanas temporales posteriores al evento principal.

### Justificación de la Estrategia y Tipos de Datos Elegidos
Se optó por no alterar la tabla base de eventos mediante columnas estáticas (`ALTER TABLE earthquakes ADD COLUMN...`), sino por una **tabla desacoplada de predicciones**, debido a:
1. **Multiplicidad de inferencias:** Un sismo mayor genera múltiples evaluaciones de réplicas conforme evoluciona la sismicidad. Agregar columnas a la tabla principal obligaría a sobreescribir la predicción anterior o a poblar con valores nulos los sismos donde no corrió el modelo.
2. **Trazabilidad y MLOps:** En Inteligencia Artificial es crítico registrar la versión exacta del modelo (`version_modelo VARCHAR(50)`) y la marca temporal exacta de inferencia (`fecha_generacion TIMESTAMP WITH TIME ZONE`).
3. **Precisión numérica:** 
   - `probabilidad_replica NUMERIC(5, 4)`: Se seleccionó punto fijo con escala de 4 decimales para representar probabilidades exactas en el intervalo $[0.0000, 1.0000]$ sin imprecisiones de coma flotante (`FLOAT`/`REAL`).
   - `magnitud_estimada NUMERIC(3, 1)`: Coincide con la resolución estándar sismológica (escala Richter/Momento).
   - `es_anomalia BOOLEAN`: Bandera booleana de bajo costo de almacenamiento (1 byte) para clasificación binaria de patrones atípicos.

### Impacto en los Datos Existentes
La creación de la tabla independiente `replica_ai_predictions` **no altera, bloquea ni corrompe los datos históricos existentes**. No requiere recrear tablas ni causa tiempo de inactividad (*zero-downtime*). Los datos históricos permanecen intactos y las predicciones históricas o en tiempo real se insertan de forma incremental.

---

## 2. Script DDL y Consulta Demostrativa

El script DDL se encuentra disponible en [`cambio-ZoulessAG.sql`](./cambio-ZoulessAG.sql).

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
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 101 | CRITICO | 88.50 | 6.2 | 24 | true | aftershock-net-v1.4.2 | 2026-10-13 15:52:00-06 |
