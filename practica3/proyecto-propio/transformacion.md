# Ejercicios 3, 4 y 5: Reglas de Transformación EER a Relacional
## Proyecto Propio: Citas Médicas y Laboratorio

---

## 1. Ejercicio 3: Reglas de Transformación Básicas

### Regla 1: Transformación de Entidades Fuertes
Cada entidad fuerte del modelo EER se convirtió en una tabla relacional independiente:
* `PACIENTE` $\rightarrow$ Tabla `paciente`: Clave primaria `nss VARCHAR(15)`, columnas `nombre`, `estatus_vigencia`, `unidad_medica_adscripcion`, `telefono`. Restricciones: `NOT NULL`, `DEFAULT TRUE`, `CHECK`.
* `ORDEN_MEDICA` $\rightarrow$ Tabla `orden_medica`: Clave primaria `folio_orden VARCHAR(20)`, columnas `nss_paciente`, `cedula_profesional`, `fecha_cita_medico`.
* `ESTUDIO` $\rightarrow$ Tabla `estudio`: Clave primaria `id_estudio SERIAL`, columnas `nombre_estudio UNIQUE`, `indicaciones_previas`, `tipo_estudio`.
* `CITA` $\rightarrow$ Tabla `cita`: Clave primaria `id_cita SERIAL`, columnas `folio_orden`, `fecha_hora_agendamiento`, `fecha_hora_laboratorio`, `estatus_asistencia`.
* `RESULTADO` $\rightarrow$ Tabla `resultado`: Clave primaria `id_resultado SERIAL`, columnas `id_cita`, `tipo_prueba`, `valor_obtenido`, `unidad_medida`, `observaciones`, `fecha_hora_emision`.

### Regla 2: Descomposición de Atributos Compuestos
En el diseño conceptual, los atributos compuestos fueron aplanados en componentes atómicos simples (por ejemplo, el nombre completo se almacena como un único componente indexable o en subcomponentes atómicos sin estructuras anidadas).

### Regla 3: Atributos Multivaluados
No se presentaron atributos multivaluados sueltos; los conjuntos de indicaciones o teléfonos se modelaron en el dominio como atributos escalares o mediante relaciones formales.

---

## 2. Ejercicio 4: Transformación de Relaciones

### Regla 4: Relaciones Uno a Muchos ($1:N$)
* **Relación `PRESENTA` (`paciente` $1 \rightarrow N$ `orden_medica`):**
  * La PK de `paciente` (`nss`) se propaga a la tabla `orden_medica` como la FK `nss_paciente`. Dado que una orden médica requiere obligatoriamente pertenecer a un paciente registrado, la FK se define como `NOT NULL` con acción referencial `ON DELETE RESTRICT ON UPDATE CASCADE`.
* **Relación `ARROJA` (`cita` $1 \rightarrow N$ `resultado`):**
  * La PK de `cita` (`id_cita`) se propaga como FK a la tabla `resultado`. Es `NOT NULL` con acción `ON DELETE CASCADE`.
* **Relación Recursiva `depende_de` (`paciente` $1 \rightarrow N$ `paciente`):**
  * La PK `nss` se propaga a la misma tabla como la columna `nss_titular` (permite valores nulos para pacientes que son ellos mismos titulares o no tienen dependientes).

### Regla 5: Relaciones Muchos a Muchos ($N:M$)
* **Relación `CONTIENE` (`orden_medica` $N \leftrightarrow M$ `estudio`):**
  * Se transforma en la tabla asociativa `orden_estudio`.
  * Claves foráneas: `folio_orden` referenciando a `orden_medica(folio_orden)` e `id_estudio` referenciando a `estudio(id_estudio)`.
  * Clave primaria compuesta: `PRIMARY KEY (folio_orden, id_estudio)`.

### Regla 6: Relaciones Uno a Uno ($1:1$)
* **Relación `GENERA` (`orden_medica` $1 \leftrightarrow 1$ `cita`):**
  * **Estrategia elegida:** Estrategia 1 (Propagación de clave con restricción `UNIQUE`).
  * **Justificación:** Una orden médica existe primero en el tiempo cuando el médico la expide, mientras que la cita de laboratorio se agenda con posterioridad (cardinalidad mínima 0 en la orden antes de agendar). Por ello, se propagó `folio_orden` hacia la tabla `cita` con restricción `UNIQUE` y `NOT NULL`. Esto garantiza que una orden jamás pueda tener más de una cita asignada.

---

## 3. Ejercicio 5: Jerarquías y Especializaciones

### Regla 9: Jerarquía de Especialización de `ESTUDIO`
* **Tipo de Jerarquía:** Disjunta ($d$) y Total ($t$).
* **Estrategia seleccionada:** **Estrategia A (Tabla por supertipo y por subtipo)**.
* **Justificación de la elección:**
  * Cada subtipo de estudio clínico maneja atributos físicos completamente diferenciados (tubo y aditivo en sangre; volumen mínimo en orina; medio de transporte en muestras fecales).
  * La Estrategia B (tabla única) generaría un porcentaje excesivo de valores nulos (desperdicio de almacenamiento e inconsistencia de integridad).
  * La Estrategia C (tablas de subtipo sin supertipo) impediría relacionar limpiamente la tabla intermedia `orden_estudio` con un único identificador global de catálogo `id_estudio`.
* **Diseño resultante:**
  * Tabla Supertipo: `estudio (id_estudio, nombre_estudio, indicaciones_previas, tipo_estudio)` con discriminador `tipo_estudio IN ('SANGRE', 'ORINA', 'FECAL')`.
  * Tabla Subtipo: `prueba_sangre (id_estudio PK/FK, tipo_tubo, aditivo, ayuno_horas)`.
  * Tabla Subtipo: `prueba_orina (id_estudio PK/FK, tipo_frasco, volumen_min_ml)`.
  * Tabla Subtipo: `prueba_fecal (id_estudio PK/FK, tipo_frasco, requiere_medio_transporte)`.
