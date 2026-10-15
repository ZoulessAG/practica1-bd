# Ejercicio 8: Cambio de Esquema por Integrante

* **Alumno:** Vega Treviño Kevin Edu
* **Usuario de GitHub:** `Elslowee`
* **Issue Vinculado:** [#14 - [Propuesta] Intersección Espacial con Infraestructura Crítica](https://github.com/ZoulessAG/practica1-bd/issues/14)
* **Área:** Requisito de Ingeniería en Inteligencia Artificial

---

## 1. Justificación Técnica y Reglas de Transformación (Media Cuartilla)

### Regla de Transformación Aplicada
Se aplicó la **Regla 1 (Entidad Fuerte para Inferencia Analítica)** y la **Regla 4 (Propagación de Claves $1:N$)**. La tabla `infraestructura_ai_vulnerability` actúa como receptáculo de hechos generados por modelos predictivos de Machine Learning que evalúan la intersección del campo de ondas sísmicas con inventarios de infraestructura crítica.

### Justificación de la Estrategia y Tipos de Datos Elegidos
1. **Desacoplamiento analítico:** No se alteran las tablas transaccionales base de sismos ni el catálogo de infraestructura. Esto evita bloqueos de tabla y sobreescrituras en sistemas concurrentes.
2. **Trazabilidad de inferencias:** El campo `version_modelo VARCHAR(50)` permite versionar los pesos del algoritmo (ej. Random Forest / XGBoost) y `fecha_analisis TIMESTAMP WITH TIME ZONE` otorga soporte para auditorías pos-desastre.
3. **Tipos de datos:**
   * `probabilidad_danio NUMERIC(5, 4)`: Representa la probabilidad matemática exacta en $[0.0000, 1.0000]$ sin errores de punto flotante binario.
   * `indice_vulnerabilidad NUMERIC(4, 2)`: Escala normalizada del 0.00 al 10.00.
   * `anomalia_estructural BOOLEAN`: Clasificación binaria rápida para filtrado de urgencia.

### Impacto en los Datos Existentes
La creación de la tabla es completamente aditiva. No destruye, modifica ni bloquea los datos históricos existentes en el repositorio del proyecto sísmico asignado.

---

## 2. Consulta Demostrativa

```sql
SELECT 
    id_evaluacion,
    id_sismo_origen,
    id_activo_infraestructura,
    ROUND(probabilidad_danio * 100, 2) AS pct_probabilidad_danio,
    indice_vulnerabilidad,
    prioridad_inspeccion,
    anomalia_estructural,
    version_modelo,
    fecha_analisis
FROM infraestructura_ai_vulnerability
WHERE prioridad_inspeccion IN ('ALTA', 'URGENTE')
ORDER BY probabilidad_danio DESC;
```
