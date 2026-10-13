# Ejercicio 2: Inventario del Modelo EER del Proyecto Propio
## Sistema de Citas Médicas y Laboratorio Clínico

---

## 1. Inventario Completo de Elementos EER

### 1.1 Entidades Fuertes
* **`PACIENTE`**:
  * **Clave Primaria:** `nss` (Número de Seguridad Social).
  * **Atributos simples:** `nombre`, `estatus_vigencia`, `unidad_medica_adscripcion`, `telefono`.
* **`ORDEN_MEDICA`**:
  * **Clave Primaria:** `folio_orden`.
  * **Atributos simples:** `cedula_profesional`, `fecha_cita_medico`.
* **`ESTUDIO`**:
  * **Clave Primaria:** `id_estudio`.
  * **Atributos simples:** `nombre_estudio`, `indicaciones_previas`.
* **`CITA`**:
  * **Clave Primaria:** `id_cita`.
  * **Atributos simples:** `fecha_hora_agendamiento`, `fecha_hora_laboratorio`, `estatus_asistencia`.
* **`RESULTADO`**:
  * **Clave Primaria:** `id_resultado`.
  * **Atributos simples:** `valor_obtenido`, `observaciones`, `unidad_medida`, `fecha_hora_emision`, `tipo_prueba`.

### 1.2 Entidades Débiles
* En este modelo no se identificaron entidades con dependencia estricta de identificación basada en clave parcial compuesta con la del propietario; sin embargo, `CITA` y `RESULTADO` presentan una **dependencia de existencia** directa respecto a `ORDEN_MEDICA` y `CITA` respectivamente.

### 1.3 Relaciones y Cardinalidades (Mín, Máx)
1. **`depende_de` (Relación recursiva en `PACIENTE`):**
   * Rol Titular: $(1, 1)$
   * Rol Beneficiario: $(0, N)$
   * Significado: Un beneficiario depende obligatoriamente de un titular; un titular puede tener 0 o muchos beneficiarios a su cargo.
2. **`PRESENTA` (`PACIENTE` - `ORDEN_MEDICA`):**
   * `PACIENTE`: $(1, N)$
   * `ORDEN_MEDICA`: $(1, 1)$
   * Significado: Un paciente puede presentar varias órdenes médicas; toda orden médica pertenece a exactamente un paciente.
3. **`GENERA` (`ORDEN_MEDICA` - `CITA`):**
   * `ORDEN_MEDICA`: $(0, 1)$ o $(1, 1)$ (una orden médica genera a lo más una cita de laboratorio).
   * `CITA`: $(1, 1)$ (toda cita proviene necesariamente de una orden médica emitida por un médico).
4. **`CONTIENE` (`ORDEN_MEDICA` - `ESTUDIO`):**
   * `ORDEN_MEDICA`: $(1, N)$
   * `ESTUDIO`: $(0, N)$
   * Significado: Una orden médica contiene uno o varios estudios; un estudio del catálogo puede estar prescrito en muchas órdenes. Relación muchos a muchos ($N:M$).
5. **`ARROJA` (`CITA` - `RESULTADO`):**
   * `CITA`: $(0, N)$ o $(1, N)$
   * `RESULTADO`: $(1, 1)$
   * Significado: Una cita de laboratorio atendida arroja uno o varios resultados; cada resultado corresponde de forma unívoca a una cita.

### 1.4 Jerarquía de Especialización / Generalización
* **Superclase:** `ESTUDIO` (Atributo discriminador: `tipo_estudio`).
* **Subclases:**
  * `PRUEBA_SANGRE`: atributos propios `tipo_tubo`, `aditivo`, `ayuno_horas`.
  * `PRUEBA_ORINA`: atributos propios `tipo_frasco`, `volumen_min_ml`.
  * `PRUEBA_FECAL`: atributos propios `tipo_frasco`, `requiere_medio_transporte`.
* **Restricción de Disyunción:** **Disjunta ($d$)**, un estudio solo pertenece a una categoría física de toma de muestra.
* **Restricción de Completitud:** **Total ($t$)**, todo estudio clínico catalogado corresponde forzosamente a una de las tres pruebas definidas.

### 1.5 Atributos Compuestos, Multivaluados y Derivados
* Atributos compuestos: No aplica en el modelo base; los campos de nombres y fechas se manejan atómicamente.
* Atributos multivaluados: No aplica de forma aislada; las agrupaciones de estudios se resolvieron mediante la relación $N:M$ `CONTIENE`.

---

## 2. Preguntas Clave Previas a la Transformación

1. **¿Qué elementos van a requerir una tabla adicional?**
   * La relación muchos a muchos ($N:M$) `CONTIENE` entre `ORDEN_MEDICA` y `ESTUDIO` requiere la creación de la tabla intermedia asociativa `orden_estudio`.
   * Los subtipos de la jerarquía de `ESTUDIO` bajo la Estrategia A generan tablas adicionales especializadas: `prueba_sangre`, `prueba_orina` y `prueba_fecal`.

2. **¿Qué atributos se convertirán en claves foráneas?**
   * `nss_titular` en `paciente` (referenciando a `paciente(nss)`).
   * `nss_paciente` en `orden_medica` (referenciando a `paciente(nss)`).
   * `folio_orden` en `cita` (referenciando a `orden_medica(folio_orden)` con restricción `UNIQUE` por relación $1:1$).
   * `folio_orden` e `id_estudio` en `orden_estudio` (referenciando a sus respectivas tablas).
   * `id_estudio` en cada subtipo (`prueba_sangre`, `prueba_orina`, `prueba_fecal`) referenciando a `estudio(id_estudio)`.
   * `id_cita` en `resultado` (referenciando a `cita(id_cita)`).

3. **¿Qué decisión se tomó en la jerarquía?**
   * Se eligió la **Estrategia A (Tabla por supertipo y por subtipo)**. Permite evitar valores nulos masivos y redundancia, preservando la integridad tipológica estricta de las muestras médicas.
