# Ejercicio 1.4: El Almacén Asignado Frente a las Formas Normales
## Análisis Dimensional del Sistema de Monitoreo Sísmico (Proyecto Asignado: Sismos)
**Equipo de Trabajo:** Ian Andrew Aguilar Garcia, Kevin Edú Vega Treviño, Alondra Quintanar Sanchez, Joel Sanchez Palma.  
**Materia:** Bases de Datos (ISC / IIA - ESCOM IPN)  
**Semestre:** 2027-1

---

## 1. El Paradigma Dimensional vs. El Paradigma Transaccional Normalizado

Mientras que un sistema transaccional (OLTP, como nuestro proyecto clínico de *CitasMed*) prioriza la **eliminación de redundancias y la prevención absoluta de anomalías de modificación** mediante esquemas en 3FN o BCNF, un almacén de datos (*Data Warehouse* / OLAP, como el sistema sismológico asignado) prioriza la **velocidad de lectura, la simplicidad de consulta y el rendimiento de agregaciones masivas** sobre millones de eventos históricos.

Para lograr esto, los esquemas en estrella (*Star Schema*) o copo de nieve (*Snowflake*) desnormalizan deliberadamente sus dimensiones.

---

## 2. Diagnóstico de Formas Normales en el Esquema Sísmico Asignado

Analizamos la estructura de las tablas del almacén dimensional de sismos (`sismos_p4_5`):

### 1. `Dim_Ubicacion` (Dimensión Geográfica Espacial)
* **Atributos:** `id_ubicacion` (PK), `latitud`, `longitud`, `municipio_epicentro`, `estado_epicentro`, `region_geografica`, `pais`.
* **Dependencias funcionales presentes en el dominio:**
  1. $\text{id\_ubicacion} \rightarrow \{\text{latitud}, \text{longitud}, \text{municipio\_epicentro}, \text{estado\_epicentro}, \text{region\_geografica}, \text{pais}\}$
  2. $\text{municipio\_epicentro} \rightarrow \text{estado\_epicentro}$
  3. $\text{estado\_epicentro} \rightarrow \text{region\_geografica}$
  4. $\text{region\_geografica} \rightarrow \text{pais}$
* **Forma Normal:** **2FN (Segunda Forma Normal), NO cumple 3FN**.
* **Justificación:**
  * Está en 2FN porque la clave primaria es simple (`id_ubicacion`) y no existen dependencias parciales.
  * **Falla 3FN:** Existen múltiples **dependencias transitivas** donde atributos no primos determinan a otros atributos no primos:
    $$\text{id\_ubicacion} \longrightarrow \text{municipio\_epicentro} \longrightarrow \text{estado\_epicentro} \longrightarrow \text{region\_geografica}$$
    En una base de datos normalizada clásica en 3FN, estas entidades territoriales estarían descompuestas en cascada: `Pais` $\rightarrow$ `Region` $\rightarrow$ `Estado` $\rightarrow$ `Municipio` $\rightarrow$ `Coordenada`.

### 2. `Dim_Estacion` (Dimensión de Sensores y Redes)
* **Atributos:** `id_estacion` (PK), `codigo_estacion`, `nombre_estacion`, `red_sismica`, `institucion_operadora`, `tipo_sensor`.
* **Dependencias funcionales:**
  1. $\text{id\_estacion} \rightarrow \{\text{codigo\_estacion}, \text{nombre\_estacion}, \text{red\_sismica}, \text{institucion\_operadora}, \text{tipo\_sensor}\}$
  2. $\text{red\_sismica} \rightarrow \text{institucion\_operadora}$ (ej. la red SSN pertenece a la UNAM, la red CIRES pertenece al CIRES A.C.).
* **Forma Normal:** **2FN, NO cumple 3FN**.
* **Justificación:** Conserva la dependencia transitiva entre la red sismológica y la institución u organismo que la opera dentro de la misma fila de estación.

### 3. `Fact_Sismos` (Tabla de Hechos Central)
* **Atributos:** `id_sismo` (PK), `fecha_hora_utc`, `magnitud`, `profundidad_km`, `id_ubicacion` (FK), `id_estacion` (FK).
* **Forma Normal:** **BCNF**.
* **Justificación:** Toda la información atómica del sismo está referenciada a través de claves foráneas hacia las dimensiones; cada atributo de métrica numérica (magnitud, profundidad) depende exclusivamente de la clave primaria del evento (`id_sismo`).

---

## 3. ¿Qué Dependencia Transitiva Conserva y Qué Gana el Almacén al Conservarla?

### La dependencia transitiva clave:
$$\text{id\_ubicacion} \xrightarrow{\quad\quad} \text{municipio\_epicentro} \xrightarrow{\quad\quad} \text{estado\_epicentro}$$

### ¿Qué gana el almacén al conservarla?
1. **Eliminación radical de operaciones `JOIN` en consultas analíticas:**  
   En un análisis de series temporales de 1,000,000 de sismos registrados en 20 años, si un investigador solicita:
   ```sql
   SELECT u.estado_epicentro, COUNT(*), AVG(s.magnitud)
   FROM fact_sismos s
   JOIN dim_ubicacion u ON s.id_ubicacion = u.id_ubicacion
   GROUP BY u.estado_epicentro;
   ```
   El motor de base de datos resuelve la consulta realizando **un solo `JOIN`** entre la tabla de hechos y la dimensión aplanada.  
   Si la dimensión estuviera en 3FN (normalizada), el motor se vería forzado a encadenar cuatro `JOIN` relacionales sucesivos (`fact_sismos` $\bowtie$ `ubicacion` $\bowtie$ `municipio` $\bowtie$ `estado`), lo que dispararía el costo computacional de I/O, el uso de memoria en buffers y la latencia de respuesta de milisegundos a varios segundos.

2. **Facilidad de agrupaciones jerárquicas directas:**  
   Los analistas y científicos de datos pueden agrupar por estado, región sismotectónica o país directamente en la misma cláusula `GROUP BY`, sin necesidad de reconstruir complejas vistas intermedias.

3. **Caché y compresión columnar más eficiente:**  
   Los motores modernos de analítica (como DuckDB, BigQuery o PostgreSQL con índices BRIN) comprimen de manera sumamente eficiente columnas desnormalizadas repetitivas mediante algoritmos de *Dictionary Encoding* o *Run-Length Encoding (RLE)*, mitigando el desperdicio de almacenamiento en disco.

---

## 4. Cuándo Conviene Desnormalizar y Qué Habría que Vigilar en Producción

### ¿Cuándo conviene desnormalizar?
* **Sistemas orientados a lectura masiva (OLAP / BI / Dashboards):** Donde la proporción de lecturas frente a escrituras es abrumadora (ej. 98% lecturas analíticas frente a 2% de inserciones por lotes).
* **Consultas de latencia crítica en interfaces de usuario:** Como los tableros ejecutivos en tiempo real o el mapa interactivo de sismos de la República Mexicana, donde una agregación no puede demorar más de 100 ms.
* **Procesamiento de datos en arquitecturas Data Lake / Data Warehouse:** Donde las dimensiones son estables y no sufren mutaciones transaccionales constantes.

### ¿Qué se tendría que vigilar si se desnormalizara en nuestro proyecto propio (`CitasMed`)?
Si decidiéramos desnormalizar nuestro sistema clínico (por ejemplo, guardando el nombre y teléfono del paciente directamente dentro de cada fila de `cita` o `resultado` para evitar hacer `JOIN` con `paciente`):

1. **Riesgo crítico de inconsistencia de datos (Anomalías de Actualización):**  
   Si un paciente cambia su número telefónico de emergencia o corrige un error ortográfico en su nombre legal, tendríamos que actualizar cientos de filas históricas de citas y resultados. Si falla la transacción a la mitad, el mismo derechohabiente tendría dos nombres distintos registrados, lo que en el sector salud representa un riesgo médico y legal severo.
2. **Procesos de carga y sincronización controlados (ETL / Event-Driven):**  
   Si se adopta una desnormalización para lectura rápida, las escrituras nunca deben hacerse directamente sobre las tablas desnormalizadas. Se debe vigilar que la persistencia primaria ocurra en un esquema transaccional 3FN/BCNF y que un proceso asíncrono (o un disparador / *Trigger*) propague ordenadamente las réplicas desnormalizadas.
3. **Bloqueos de concurrencia (*Locking*):**  
   Actualizar una dimensión desnormalizada con miles de filas redundantes bloquea tablas masivas durante segundos, degradando el servicio para otros médicos y laboratoristas.
4. **Almacenamiento y costo de caché:**  
   La redundancia de texto plano (`VARCHAR`) multiplica el tamaño de la base de datos y satura la memoria RAM del gestor (`shared_buffers`), reduciendo la cantidad de páginas de datos útiles que caben en memoria.

**Conclusión:**  
La normalización a 3FN/BCNF es el estándar indiscutible para garantizar integridad referencial y atomicidad en los sistemas operativos transaccionales como nuestro laboratorio de análisis clínicos. La desnormalización es una técnica de optimización especializada que debe restringirse a capas analíticas y almacenes de datos donde las actualizaciones en vivo son nulas o se gestionan por lotes.
