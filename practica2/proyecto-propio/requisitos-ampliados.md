# Proyecto Propio: Requisitos Ampliados del Sistema de Laboratorio Clínico

## 1. Descripción del Problema
El sistema administra la recepción de pacientes, la programación de citas, la emisión de órdenes de laboratorio y el registro de resultados analíticos. Para garantizar un control estricto, el modelo conceptual debe capturar relaciones avanzadas entre el personal médico, las muestras biológicas tomadas y los parámetros analizados en cada estudio.

---

## 2. Definición de Conceptos Extendidos (EER)

### A. Restricciones de Cardinalidad (mín, máx)
1. **[Paciente] - (Agenda) - [Cita]:**
    * Regla de negocio: Un paciente puede registrar $0$ o $N$ citas en el historial. Toda cita pertenece obligatoriamente a $1$ y solo $1$ paciente.
    * Cardinalidad: `(0, N) : (1, 1)`

2. **[Medico_Tratante] - (Emite) - [Orden_Estudio]:**
    * Regla de negocio: Un médico tratante emite al menos $1$ o muchas órdenes de laboratorio. Cada orden es emitida por exactamente $1$ médico responsable.
    * Cardinalidad: `(1, N) : (1, 1)`

3. **[Orden_Estudio] - (Contiene) - [Estudio_Clinico]:**
    * Regla de negocio: Una orden debe incluir al menos $1$ o varios estudios clínicos. Un tipo de estudio puede estar contenido en $0$ o muchas órdenes.
    * Cardinalidad: `(1, N) : (0, N)`

---

### B. Entidades Débiles
1. **`Muestra_Clinica` (Dependencia de Identificación y Existencia):**
    * No existe de forma independiente sin una `Orden_Estudio`. Se identifica parcialmente por un identificador local (`num_muestra`) combinado con la clave primaria de la orden.
2. **`Parametro_Resultado` (Dependencia de Existencia):**
    * Registra valores cuantitativos o cualitativos específicos (ej. Glucosa, Hemoglobina). Depende de la existencia de la entidad fuerte `Estudio_Clinico`.

---

### C. Jerarquía de Generalización y Especialización
* **Superclase:** `Personal_Salud` (Atributos: `id_personal`, `nombre`, `RFC`, `telefono`).
* **Subclases:**
    * `Medico_Tratante`: Atributos propios `cedula_profesional`, `especialidad`.
    * `Laboratorista`: Atributos propios `turno`, `cedula_tecnica`.
* **Restricciones:**
    * **Disyuntiva ($d$):** Un miembro del personal no puede ser médico tratante y laboratorista al mismo tiempo.
    * **Total ($t$):** Todo registro de personal de salud debe ser obligatoriamente un médico o un laboratorista.

---

## 3. Consultas habilitadas por el Modelo Extendido
1. Identificar qué laboratorista procesó una `Muestra_Clinica` específica ligada a una orden con inconsistencias.
2. Filtrar parámetros de resultados clínicos de forma individualizada para estudios compuestos (ej. Biometría Hemática) comparando con valores de referencia por edad y sexo del paciente.
3. Consultar la carga de trabajo y volumen de órdenes emitidas desglosadas por la especialidad médica del `Medico_Tratante`.