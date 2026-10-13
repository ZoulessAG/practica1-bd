# Diccionario de Datos y Preservación del Significado
## Proyecto Propio: Citas Médicas y Laboratorio

---

## 1. Diccionario de Datos Relacional

| Tabla | Columna | Tipo de Dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `paciente` | `nss` | `VARCHAR(15)` | `PRIMARY KEY`, `NOT NULL` | Número de Seguridad Social, identificador único del paciente. |
| `paciente` | `nombre` | `VARCHAR(120)` | `NOT NULL` | Nombre completo del derechohabiente. |
| `paciente` | `estatus_vigencia` | `BOOLEAN` | `NOT NULL`, `DEFAULT TRUE` | Bandera de vigencia de derechos ante el instituto. |
| `paciente` | `unidad_medica_adscripcion`| `VARCHAR(100)`| `NOT NULL` | Clínica o UMF asignada al derechohabiente. |
| `paciente` | `telefono` | `VARCHAR(15)` | `CHECK(LENGTH(telefono) >= 8)` | Teléfono de contacto del paciente. |
| `paciente` | `nss_titular` | `VARCHAR(15)` | `FOREIGN KEY REFERENCES paciente(nss)` | NSS del titular si este registro es beneficiario (recursivo). |
| `orden_medica` | `folio_orden` | `VARCHAR(20)` | `PRIMARY KEY`, `NOT NULL` | Código de folio alfanumérico emitido por el médico. |
| `orden_medica` | `nss_paciente` | `VARCHAR(15)` | `NOT NULL`, `FOREIGN KEY REFERENCES paciente(nss)` | Derechohabiente al que se le expidió la orden médica. |
| `orden_medica` | `cedula_profesional` | `VARCHAR(20)` | `NOT NULL`, `CHECK` | Cédula del médico tratante que prescribe los estudios. |
| `orden_medica` | `fecha_cita_medico` | `DATE` | `NOT NULL` | Fecha en la que el médico expidió la orden. |
| `cita` | `id_cita` | `SERIAL` | `PRIMARY KEY`, `NOT NULL` | Identificador secuencial de la cita en laboratorio. |
| `cita` | `folio_orden` | `VARCHAR(20)` | `NOT NULL`, `UNIQUE`, `FOREIGN KEY` | Folio de la orden médica asociada a la cita ($1:1$). |
| `cita` | `fecha_hora_agendamiento` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Fecha y hora en que se agendó la cita. |
| `cita` | `fecha_hora_laboratorio` | `TIMESTAMPTZ` | `NOT NULL`, `CHECK(>= agendamiento)`| Fecha y hora programada para acudir a toma de muestra. |
| `cita` | `estatus_asistencia` | `VARCHAR(20)` | `NOT NULL`, `CHECK(IN(...))` | Estado de la cita ('PROGRAMADA', 'CONFIRMADA', 'ASISTIO', etc.). |
| `estudio` | `id_estudio` | `SERIAL` | `PRIMARY KEY`, `NOT NULL` | Identificador autoincremental del catálogo de estudios. |
| `estudio` | `nombre_estudio` | `VARCHAR(120)` | `NOT NULL`, `UNIQUE` | Denominación del estudio clínico. |
| `estudio` | `indicaciones_previas` | `TEXT` | Opcional | Instrucciones preparatorias para el paciente. |
| `estudio` | `tipo_estudio` | `VARCHAR(20)` | `NOT NULL`, `CHECK(IN('SANGRE','ORINA','FECAL'))` | Discriminador tipológico para la especialización. |
| `prueba_sangre`| `id_estudio` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | Vínculo de supertipo hacia `estudio(id_estudio)`. |
| `prueba_sangre`| `tipo_tubo` | `VARCHAR(50)` | `NOT NULL` | Color y tipo de tapón del tubo de ensayo (ej. EDTA, lila). |
| `prueba_sangre`| `aditivo` | `VARCHAR(50)` | `NOT NULL` | Sustancia química anticoagulante o gel separador. |
| `prueba_sangre`| `ayuno_horas` | `INT` | `NOT NULL`, `CHECK(>= 0 AND <= 24)` | Horas mínimas requeridas de ayuno previo. |
| `prueba_orina` | `id_estudio` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | Vínculo de supertipo hacia `estudio(id_estudio)`. |
| `prueba_orina` | `tipo_frasco` | `VARCHAR(50)` | `NOT NULL` | Envase estéril recolector. |
| `prueba_orina` | `volumen_min_ml`| `NUMERIC(5,2)`| `NOT NULL`, `CHECK(> 0)` | Volumen mínimo en mililitros requerido para el análisis. |
| `prueba_fecal` | `id_estudio` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | Vínculo de supertipo hacia `estudio(id_estudio)`. |
| `prueba_fecal` | `tipo_frasco` | `VARCHAR(50)` | `NOT NULL` | Frasco o vial colector de muestra fecal. |
| `prueba_fecal` | `requiere_medio_transporte` | `BOOLEAN` | `NOT NULL`, `DEFAULT FALSE`| Indica si requiere medio líquido preservador Cary-Blair. |
| `orden_estudio`| `folio_orden` | `VARCHAR(20)` | `NOT NULL`, `FOREIGN KEY`, `PK COMPUESTA` | Orden médica que prescribe el estudio ($N:M$). |
| `orden_estudio`| `id_estudio` | `INT` | `NOT NULL`, `FOREIGN KEY`, `PK COMPUESTA` | Estudio prescrito en la orden. |
| `resultado` | `id_resultado` | `SERIAL` | `PRIMARY KEY`, `NOT NULL` | Identificador único del reporte analítico emitido. |
| `resultado` | `id_cita` | `INT` | `NOT NULL`, `FOREIGN KEY` | Cita de laboratorio que generó este resultado. |
| `resultado` | `tipo_prueba` | `VARCHAR(100)`| `NOT NULL` | Analito específico evaluado (ej. Glucosa, Leucocitos). |
| `resultado` | `valor_obtenido`| `VARCHAR(100)`| `NOT NULL` | Lectura numérica o cualitativa obtenida en laboratorio. |
| `resultado` | `unidad_medida` | `VARCHAR(30)` | Opcional | Unidad física de medición (mg/dL, g/L, mm3). |
| `resultado` | `observaciones` | `TEXT` | Opcional | Comentarios clínicos o alertas de rango de referencia. |
| `resultado` | `fecha_hora_emision` | `TIMESTAMPTZ`| `NOT NULL`, `DEFAULT NOW()`| Marca de tiempo exacta de liberación del resultado. |

---

## 2. Matriz de Preservación del Significado (Ejercicio 6.5)

| Elemento en Modelo EER | Representación en Esquema Relacional | Mecanismo de Preservación de Reglas de Negocio | ¿Se perdió información? |
| :--- | :--- | :--- | :--- |
| **Entidad `PACIENTE`** | Tabla `paciente` | Clave primaria en `nss`. | No. Íntegro. |
| **Relación recursiva `depende_de`** | Columna `nss_titular` en tabla `paciente` | Clave foránea autorreferencial con `RESTRICT`. Permite titulares sin dependientes y beneficiarios ligados. | No. Mantiene semántica $1:N$. |
| **Relación `PRESENTA`** | Clave foránea `nss_paciente` en `orden_medica` | `NOT NULL` y `FOREIGN KEY`, obligando a que toda orden pertenezca a un paciente existente. | No. Preservado con integridad referencial. |
| **Relación $1:1$ `GENERA`** | Clave foránea `folio_orden` en tabla `cita` | Restricción `UNIQUE` y `NOT NULL`. Evita que una orden agende múltiples citas. | No. Cumple restricción estricta $1:1$. |
| **Relación $N:M$ `CONTIENE`** | Tabla asociativa `orden_estudio` | Clave primaria compuesta `(folio_orden, id_estudio)` con claves foráneas en cascada. | No. Preserva la multiplicidad completa. |
| **Jerarquía `ESTUDIO` ($d, t$)** | Supertipo `estudio` + subtipos `prueba_sangre`, `prueba_orina`, `prueba_fecal` | Claves primarias foráneas compartidas (`ON DELETE CASCADE`) y restricción `CHECK(tipo_estudio IN (...))`. | No. No hay nulos indeseados ni pérdida de atributos. |
| **Relación `ARROJA` ($1:N$)** | Clave foránea `id_cita` en tabla `resultado` | `NOT NULL` y `ON DELETE CASCADE`. Un resultado no existe sin su cita. | No. Preservado fielmente. |
