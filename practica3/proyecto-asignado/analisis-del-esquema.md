# Ejercicio 7.1 y 7.2: Análisis del Esquema del Proyecto Asignado
## Proyecto: Seismic Data Visualization System

---

## 1. Ejercicio 7.1: Las Reglas Detrás del Esquema

El proyecto asignado implementa una arquitectura analítica dimensional orientada al análisis geoespacial y temporal de eventos sísmicos. A continuación se analiza el origen de sus tablas según las reglas de transformación EER a Relacional:

### 1. `Fact_Sismos` / `Earthquakes` (Tabla de Hechos)
* **Regla que explica su origen:** **Regla 1 (Entidad Fuerte / Hecho Central)** combinada con **Regla 4 (Propagación de Claves)**.
* **Clave Primaria:** `id` / `id_sismo` (`SERIAL` o `BIGINT`).
* **Claves Foráneas Declaradas:**
  * Referencia a la dimensión geográfica (`id_ubicacion` $\rightarrow$ `Dim_Ubicacion`).
  * Referencia a la estación de referencia (`id_estacion` $\rightarrow$ `Dim_Estacion`).
* **Restricciones:** Restricciones `NOT NULL` en coordenadas del epicentro (`latitud`, `longitud`), `fecha_hora_utc` y `magnitud`. `CHECK` de rango en magnitud ($0.0 \le \text{magnitud} \le 10.0$).

### 2. `Dim_Ubicacion` (Tabla de Dimensión Espacial)
* **Regla que explica su origen:** **Regla 1 (Entidad Fuerte Normalizada en Origen)**.
* **Clave Primaria:** `id_ubicacion` (Clave subrogada artificial).
* **Atributos:** `estado`, `municipio`, `region_sismica`, `latitud_referencia`, `longitud_referencia`.

### 3. `Dim_Estacion` (Tabla de Dimensión de Sensores)
* **Regla que explica su origen:** **Regla 1 (Entidad Fuerte)**.
* **Clave Primaria:** `id_estacion` o `codigo_estacion`.
* **Atributos:** `nombre_estacion`, `red_sismica`, `tipo_sensor`, `estatus_operativo`.

---

## 2. Ejercicio 7.2: Dónde se Aparta de las Reglas (Desnormalización Dimensional)

Un almacén de datos dimensional desnormaliza deliberadamente para maximizar el rendimiento analítico (*OLAP*). En el proyecto asignado se identifican las siguientes tres decisiones donde el esquema real se aparta de una transformación relacional estricta:

### Decisión 1: Jerarquías territoriales aplanadas en una sola tabla (`Dim_Ubicacion`)
* **Qué se aparta:** En una transformación 3FN estricta, `Municipio` pertenecería a `Estado`, generando tablas separadas con una FK intermedia. En el sistema sísmico, `Estado` y `Municipio` conviven como columnas en una misma dimensión plana.
* **Qué se gana:** Evita operaciones de `JOIN` multinivel en consultas de agregación regional, agilizando filtros masivos como `GROUP BY estado, municipio`.
* **Qué se pierde:** Redundancia en los nombres de los estados y riesgo de anomalías de actualización si se modificara la denominación de una demarcación territorial.

### Decisión 2: Claves subrogadas en lugar de las claves naturales del dominio
* **Qué se aparta:** El evento sísmico tiene identificadores naturales en la red sismológica (como el identificador alfanumérico del SSN o USGS). El esquema utiliza un `id` secuencial artificial como PK.
* **Qué se gana:** Índices compactos de tipo entero de ancho fijo de 4 u 8 bytes, que aceleran drásticamente los recorridos de índices en tablas con millones de registros sísmicos.
* **Qué se pierde:** Se pierde la verificación semántica directa a nivel de clave en el gestor sin recurrir a un índice `UNIQUE` secundario sobre la clave de negocio original.

### Decisión 3: Atributos de lecturas de estación colapsados en la tabla de hechos
* **Qué se aparta:** En el modelo EER, la captura de la onda sísmica por cada estación es una entidad débil o relación $N:M$ con lecturas específicas. El almacén asignado consolidó la estación con mayor amplitud o estación de referencia directamente en la fila del evento sísmico.
* **Qué se gana:** Reducción masiva en el volumen de filas de la tabla de hechos y simplificación de las consultas para visualización en mapas en tiempo real.
* **Qué se pierde:** Pérdida de la granularidad fina para reconstruir la señal individual y el tiempo de arribo ($P$ y $S$) captado por cada sismógrafo secundario.
