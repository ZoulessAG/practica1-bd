# Práctica 6: Dependencias Funcionales y Normalización
## Proyecto Propio: Sistema Clínico y Laboratorio de Análisis (CitasMed)
**Equipo de Trabajo:** Ian Andrew Aguilar Garcia, Kevin Edú Vega Treviño, Alondra Quintanar Sanchez, Joel Sanchez Palma.  
**Materia:** Bases de Datos (ISC / IIA - ESCOM IPN)  
**Semestre:** 2027-1

---

## Ejercicio 1.1. Pautas Informales de Diseño Relacional

En el diseño relacional formal, la calidad de un esquema no se mide únicamente por la intuición, sino por cuatro pautas informales de diseño:
1. **Pauta 1 (Semántica clara):** Diseñar relaciones de modo que sea fácil explicar su significado; los atributos de diferentes entidades o relaciones no deben mezclarse en una sola relación.
2. **Pauta 2 (Reducción de anomalías de actualización):** Diseñar esquemas relacionales sin redundancias que causen anomalías de inserción, eliminación o modificación.
3. **Pauta 3 (Reducción de valores nulos):** Diseñar relaciones que coloquen atributos con frecuencia nulos en relaciones secundarias independientes.
4. **Pauta 4 (Prevención de tuplas espurias):** Asegurar que las relaciones se unan mediante claves primarias o foráneas válidas, garantizando la reunión sin pérdida.

A continuación, se define la semántica informal («cada fila es…») de cada una de las diez tablas del proyecto propio y se evalúa rigurosamente contra las cuatro pautas:

### 1. `paciente`
* **Semántica:** «Cada fila representa a un derechohabiente único adscrito formalmente al instituto de salud, con su identificación ciudadana (NSS), nombre legal, clínica de adscripción y su vínculo de dependencia jurídica en caso de ser beneficiario».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Representa exclusivamente la entidad fuerte `PACIENTE` del modelo conceptual.
  * *Pauta 2 (Anomalías):* **Cumple.** No existe redundancia de datos personales; cada paciente se registra una sola vez.
  * *Pauta 3 (Nulos):* **Cumple con justificación.** El único atributo que admite `NULL` es `nss_titular`, el cual es nulo estrictamente cuando el paciente es titular directo de sus derechos. No existe desperdicio de espacio estructural.
  * *Pauta 4 (Tuplas espurias):* **Cumple.** La clave primaria `nss` garantiza reuniones exactas y sin pérdida con `orden_medica` y `paciente_telefono`.

### 2. `paciente_telefono`
* **Semántica:** «Cada fila representa una línea telefónica específica de contacto asignada a un derechohabiente».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Aísla el atributo multivaluado `telefono` de la entidad paciente.
  * *Pauta 2 (Anomalías):* **Cumple.** Si un paciente cambia o elimina un número secundario, se modifica o borra únicamente su fila en esta tabla sin alterar los datos del derechohabiente.
  * *Pauta 3 (Nulos):* **Cumple al 100%.** Ningún atributo admite nulos; la clave primaria compuesta es `(nss, telefono)`.
  * *Pauta 4 (Tuplas espurias):* **Cumple.** La reunión con `paciente` a través de `nss` es determinista.

### 3. `orden_medica`
* **Semántica:** «Cada fila representa una prescripción médica formal expedida por un médico tratante a un derechohabiente específico en una fecha determinada».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Modela la relación formal entre el médico emisor y el paciente receptor.
  * *Pauta 2 (Anomalías):* **Cumple.** Si un paciente tiene múltiples órdenes médicas a lo largo del año, los datos demográficos del paciente no se repiten en esta tabla; únicamente se propaga la clave foránea `nss_paciente`.
  * *Pauta 3 (Nulos):* **Cumple al 100%.** Todos los atributos (`folio_orden`, `fecha_cita_medico`, `medico_emisor`, `nss_paciente`) son estrictamente `NOT NULL`.
  * *Pauta 4 (Tuplas espurias):* **Cumple.** Se reúne sin pérdida mediante `folio_orden` y `nss_paciente`.

### 4. `cita`
* **Semántica:** «Cada fila representa la reserva formal de fecha y hora en el laboratorio clínico para la toma de muestras de una orden médica emitida».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Modela el agendamiento operativo y el estatus de asistencia del paciente.
  * *Pauta 2 (Anomalías):* **Cumple.** Como la relación con `orden_medica` es $1:1$ (un folio de orden genera una única cita en laboratorio), `folio_orden` es clave candidata única (`UNIQUE`).
  * *Pauta 3 (Nulos):* **Cumple al 100%.** Todos los atributos son obligatorios.
  * *Pauta 4 (Tuplas espurias):* **Cumple.** La reunión natural entre `cita` y `orden_medica` sobre `folio_orden` es biyectiva.

### 5. `estudio`
* **Semántica:** «Cada fila representa una prueba diagnóstica ofertada en el catálogo general de servicios del laboratorio clínico».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Modela el supertipo general del catálogo de análisis.
  * *Pauta 2 (Anomalías):* **Cumple.** El nombre y las instrucciones de preparación de una prueba se almacenan una sola vez.
  * *Pauta 3 (Nulos):* **Cumple.** `indicaciones_previas` admite nulo únicamente si el estudio no exige preparación especial del paciente (ayuno o abstinencia).
  * *Pauta 4 (Tuplas espurias):* **Cumple.** `id_estudio` es clave primaria única.

### 6. `orden_estudio`
* **Semántica:** «Cada fila representa la inclusión y prescripción de un estudio de laboratorio específico dentro de una orden médica».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Resuelve limpiamente la relación muchos a muchos ($N:M$) entre órdenes y estudios.
  * *Pauta 2 (Anomalías):* **Cumple.** Se pueden agregar o deseleccionar estudios de una orden médica sin tocar la orden ni el catálogo general.
  * *Pauta 3 (Nulos):* **Cumple al 100%.** No contiene columnas anulables; su clave es `(folio_orden, id_estudio)`.
  * *Pauta 4 (Tuplas espurias):* **Cumple.** Toda reunión con `orden_medica` o `estudio` es exacta.

### 7. `prueba_sangre`
* **Semántica:** «Cada fila especifica los parámetros técnicos de recolección y conservación hematológica (tipo de tubo de ensayo, color de tapón y horas de ayuno) de un estudio de sangre».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Modela el subtipo disjunto de muestras sanguíneas.
  * *Pauta 2 (Anomalías):* **Cumple.** Al separar los subtipos en tablas hijas (Estrategia A de generalización/especialización), se evita que un estudio de orina tenga atributos de sangre.
  * *Pauta 3 (Nulos):* **Cumple al 100%.** Elimina el 100% de los nulos que ocurrirían si se hubieran aplanado los subtipos en la tabla `estudio`.
  * *Pauta 4 (Tuplas espurias):* **Cumple.** Se conecta mediante `id_estudio` (PK y FK simultánea).

### 8. `prueba_orina`
* **Semántica:** «Cada fila especifica el recipiente de recolección estéril y el volumen mínimo requerido para un análisis uroanalítico».
* **Revisión contra las 4 pautas:**
  * *Pauta 1, 2, 3 y 4:* **Cumple al 100%.** Evita nulos masivos y mantiene semántica atómica.

### 9. `prueba_fecal`
* **Semántica:** «Cada fila especifica el recipiente recolector y el requerimiento de medio de transporte líquido para análisis coprológicos».
* **Revisión contra las 4 pautas:**
  * *Pauta 1, 2, 3 y 4:* **Cumple al 100%.** Aislamiento de atributos específicos de materia fecal.

### 10. `resultado`
* **Semántica:** «Cada fila representa la lectura analítica validada (numérica o cualitativa), unidad de medida y rango de referencia obtenida para un estudio en una cita de laboratorio».
* **Revisión contra las 4 pautas:**
  * *Pauta 1 (Semántica):* **Cumple.** Representa el reporte de laboratorio emitido.
  * *Pauta 2 (Anomalías):* **Cumple.** Cada resultado es una medición individual; si se corrige un valor, se actualiza solo una fila.
  * *Pauta 3 (Nulos):* **Cumple.** `unidad_medida`, `rango_referencia` y `observaciones` admiten nulo cuando la prueba es cualitativa (ej. prueba reactiva de embarazo: Negativo/Positivo, sin unidades físicas).
  * *Pauta 4 (Tuplas espurias):* **Cumple.** `id_resultado` es PK única, con FKs a `cita` y `estudio`.

---

### Análisis Crítico: ¿Qué tabla fallaría cuál pauta si se alterara el diseño?
* **Falla de Pauta 1 y 2 si se unificara `paciente` y `paciente_telefono`:**
  Si los teléfonos se mantuvieran dentro de la tabla `paciente` mediante columnas repetidas (`telefono1`, `telefono2`) o generando una fila de paciente por cada teléfono, se violaría la 1FN (multivaluado) o se producirían **anomalías de actualización**: si un paciente cambia de domicilio o de nombre, habría que actualizar múltiples tuplas idénticas.
* **Falla de Pauta 3 si se aplanaran los subtipos de `estudio`:**
  Si `estudio` absorbiera a `prueba_sangre`, `prueba_orina` y `prueba_fecal` en una sola tabla ancha con 12 columnas, los estudios de orina tendrían obligatoriamente valores `NULL` en `tipo_tubo`, `color_tapon` y `ayuno_horas`, violando flagrantemente la Pauta 3 (desperdicio de memoria y pérdida de significado de nulos).

---

## Ejercicio 1.2. Las Dependencias Funcionales

### 1. Conjunto F de Dependencias Funcionales Justificadas por Reglas de Negocio

El conjunto $F$ se deduce estrictamente de los estatutos operativos y biológicos del laboratorio clínico, no de la inspección fortuita de datos:

1. **Regla de Negocio 1 (Identidad del derechohabiente):** El Número de Seguridad Social (NSS) asignado por el Estado es único para cada ciudadano. Conociendo el NSS se determina inequívocamente su nombre, su estatus de vigencia médica, la clínica hospitalaria a la que está adscrito y el NSS de su titular legal:
   $$F_1: \{\text{nss}\} \rightarrow \{\text{nombre}, \text{estatus\_vigencia}, \text{unidad\_medica\_adscripcion}, \text{nss\_titular}\}$$

2. **Regla de Negocio 2 (Telefonía de pacientes):** Un paciente puede registrar múltiples números de teléfono, y un mismo número puede ser compartido por miembros de una misma familia. Por tanto, no hay dependencias funcionales no triviales hacia atributos adicionales; la clave es compuesta completa:
   $$F_2: \{\text{nss}, \text{telefono}\} \rightarrow \emptyset$$

3. **Regla de Negocio 3 (Prescripción médica formal):** Cada orden médica tiene un folio alfanumérico único institucional emitido en talonario oficial. Conociendo el folio de la orden se determina con exactitud la fecha de emisión de la orden, el médico tratante que la firmó y el derechohabiente al que pertenece:
   $$F_3: \{\text{folio\_orden}\} \rightarrow \{\text{fecha\_cita\_medico}, \text{medico\_emisor}, \text{nss\_paciente}\}$$

4. **Regla de Negocio 4 (Cita de toma de muestra y relación 1:1):** Cada cita de laboratorio tiene un identificador único entero (`id_cita`). Conociendo el `id_cita` se conoce la fecha de agendamiento, la fecha de toma de laboratorio, el estatus de asistencia y el folio de orden. Además, debido a que una orden médica genera una y solo una cita de laboratorio y viceversa (restricción `UNIQUE` en `folio_orden`), el folio de orden también determina funcionalmente todos los atributos de la cita:
   $$F_{4a}: \{\text{id\_cita}\} \rightarrow \{\text{fecha\_hora\_agendamiento}, \text{fecha\_hora\_laboratorio}, \text{estatus\_asistencia}, \text{folio\_orden}\}$$
   $$F_{4b}: \{\text{folio\_orden}\} \rightarrow \{\text{id\_cita}, \text{fecha\_hora\_agendamiento}, \text{fecha\_hora\_laboratorio}, \text{estatus\_asistencia}\}$$

5. **Regla de Negocio 5 (Catálogo de estudios clínicos):** Cada prueba tiene una clave única de catálogo (`id_estudio`) y una denominación oficial irrepetible (`nombre_estudio` con restricción `UNIQUE`):
   $$F_{5a}: \{\text{id\_estudio}\} \rightarrow \{\text{nombre\_estudio}, \text{indicaciones\_previas}\}$$
   $$F_{5b}: \{\text{nombre\_estudio}\} \rightarrow \{\text{id\_estudio}, \text{indicaciones\_previas}\}$$

6. **Regla de Negocio 6 (Detalle de prescripción de estudios):** Una orden médica puede prescribir varios estudios, y un estudio puede ser ordenado en múltiples folios. La clave de la relación es la tupla completa:
   $$F_6: \{\text{folio\_orden}, \text{id\_estudio}\} \rightarrow \emptyset$$

7. **Regla de Negocio 7 (Protocolo hematológico):** El código del estudio de sangre determina el tipo de tubo requerido, el color del tapón normalizado (código Vacutainer) y las horas de ayuno metabólico:
   $$F_7: \{\text{id\_estudio}\} \rightarrow \{\text{tipo\_tubo}, \text{color\_tapon}, \text{ayuno\_horas}\}$$

8. **Regla de Negocio 8 (Protocolo uroanalítico):** El código del estudio de orina determina el frasco y el volumen mínimo necesario para centrifugación:
   $$F_8: \{\text{id\_estudio}\} \rightarrow \{\text{tipo\_frasco}, \text{volumen\_minimo}\}$$

9. **Regla de Negocio 9 (Protocolo coprológico):** El código del estudio fecal determina el tipo de frasco recolector y si el patógeno exige medio de transporte Cary-Blair o similar:
   $$F_9: \{\text{id\_estudio}\} \rightarrow \{\text{tipo\_frasco}, \text{requiere\_medio\_transporte}\}$$

10. **Regla de Negocio 10 (Resultados emitidos):** Cada resultado emitido posee un folio secuencial de resultado (`id_resultado`) que determina el valor, unidad, rango de referencia, fecha de emisión, observaciones, la cita a la que pertenece y el estudio evaluado:
    $$F_{10a}: \{\text{id\_resultado}\} \rightarrow \{\text{valor\_obtenido}, \text{unidad\_medida}, \text{rango\_referencia}, \text{fecha\_hora\_emision}, \text{observaciones}, \text{id\_cita}, \text{id\_estudio}\}$$
    Adicionalmente, por regla biológica institucional, en una misma cita de laboratorio no se puede emitir más de un resultado para el mismo estudio clínico:
    $$F_{10b}: \{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \{\text{id\_resultado}, \text{valor\_obtenido}, \text{unidad\_medida}, \text{rango\_referencia}, \text{fecha\_hora\_emision}, \text{observaciones}\}$$

---

### 2. Cálculo Paso a Paso del Cierre de Atributos (X⁺) para Hallar las Claves Candidatas

Para cada tabla, calculamos el cierre de atributos aplicando formalmente los axiomas de Armstrong:

#### A) Tabla `paciente`:
* Atributos: $R = \{\text{nss}, \text{nombre}, \text{estatus\_vigencia}, \text{unidad\_medica\_adscripcion}, \text{nss\_titular}\}$
* Evaluamos $X = \{\text{nss}\}$:
  1. $X^{(0)} = \{\text{nss}\}$ (por reflexividad).
  2. Aplicando $F_1$, como $\{\text{nss}\} \subseteq X^{(0)}$, agregamos el lado derecho:
     $$X^{(1)} = \{\text{nss}, \text{nombre}, \text{estatus\_vigencia}, \text{unidad\_medica\_adscripcion}, \text{nss\_titular}\}$$
  3. $X^{(1)} = R$.
  4. Como ningún subconjunto propio de $\{\text{nss}\}$ (es decir $\emptyset$) genera $R$, **$\{\text{nss}\}$ es la única clave candidata y clave primaria**.

#### B) Tabla `orden_medica`:
* Atributos: $R = \{\text{folio\_orden}, \text{fecha\_cita\_medico}, \text{medico\_emisor}, \text{nss\_paciente}\}$
* Evaluamos $X = \{\text{folio\_orden}\}$:
  1. $X^{(0)} = \{\text{folio\_orden}\}$.
  2. Aplicando $F_3$:
     $$X^{(1)} = \{\text{folio\_orden}, \text{fecha\_cita\_medico}, \text{medico\_emisor}, \text{nss\_paciente}\} = R$$
  3. **$\{\text{folio\_orden}\}$ es la única clave candidata y clave primaria**.

#### C) Tabla `cita`:
* Atributos: $R = \{\text{id\_cita}, \text{fecha\_hora\_agendamiento}, \text{fecha\_hora\_laboratorio}, \text{estatus\_asistencia}, \text{folio\_orden}\}$
* Evaluamos $X_1 = \{\text{id\_cita}\}$:
  1. $X_1^{(0)} = \{\text{id\_cita}\}$.
  2. Aplicando $F_{4a}$:
     $$X_1^{(1)} = \{\text{id\_cita}, \text{fecha\_hora\_agendamiento}, \text{fecha\_hora\_laboratorio}, \text{estatus\_asistencia}, \text{folio\_orden}\} = R$$
* Evaluamos $X_2 = \{\text{folio\_orden}\}$:
  1. $X_2^{(0)} = \{\text{folio\_orden}\}$.
  2. Aplicando $F_{4b}$:
     $$X_2^{(1)} = \{\text{folio\_orden}, \text{id\_cita}, \text{fecha\_hora\_agendamiento}, \text{fecha\_hora\_laboratorio}, \text{estatus\_asistencia}\} = R$$
* **Conclusión:** Existen **dos claves candidatas**: $\{\text{id\_cita}\}$ y $\{\text{folio\_orden}\}$. Se elige $\{\text{id\_cita}\}$ como clave primaria y $\{\text{folio\_orden}\}$ como clave alternativa (`UNIQUE`).

#### D) Tabla `estudio`:
* Atributos: $R = \{\text{id\_estudio}, \text{nombre\_estudio}, \text{indicaciones\_previas}\}$
* Evaluamos $X_1 = \{\text{id\_estudio}\}$:
  $$X_1^+ = \{\text{id\_estudio}, \text{nombre\_estudio}, \text{indicaciones\_previas}\} = R$$
* Evaluamos $X_2 = \{\text{nombre\_estudio}\}$:
  $$X_2^+ = \{\text{nombre\_estudio}, \text{id\_estudio}, \text{indicaciones\_previas}\} = R$$
* **Conclusión:** Existen **dos claves candidatas**: $\{\text{id\_estudio}\}$ (PK) y $\{\text{nombre\_estudio}\}$ (Clave Alterna UNIQUE).

#### E) Tabla `resultado`:
* Atributos: $R = \{\text{id\_resultado}, \text{valor\_obtenido}, \text{unidad\_medida}, \text{rango\_referencia}, \text{fecha\_hora\_emision}, \text{observaciones}, \text{id\_cita}, \text{id\_estudio}\}$
* Evaluamos $X_1 = \{\text{id\_resultado}\}$:
  $$X_1^+ = R \implies \text{Clave candidata (PK)}$$
* Evaluamos $X_2 = \{\text{id\_cita}, \text{id\_estudio}\}$:
  1. $X_2^{(0)} = \{\text{id\_cita}, \text{id\_estudio}\}$.
  2. Aplicando $F_{10b}$:
     $$X_2^{(1)} = \{\text{id\_cita}, \text{id\_estudio}, \text{id\_resultado}, \text{valor\_obtenido}, \text{unidad\_medida}, \text{rango\_referencia}, \text{fecha\_hora\_emision}, \text{observaciones}\} = R$$
  3. Comprobación de minimalidad:
     * $\{\text{id\_cita}\}^+ = \{\text{id\_cita}\} \neq R$
     * $\{\text{id\_estudio}\}^+ = \{\text{id\_estudio}\} \neq R$
  4. Ningún subconjunto propio es superclave.
* **Conclusión:** Existen **dos claves candidatas**: $\{\text{id\_resultado}\}$ (PK subrogada) y $\{\text{id\_cita}, \text{id\_estudio}\}$ (Clave compuesta de negocio).

---

### 3. Reducción de F a su Recubrimiento Mínimo / Canónico (Fc)

Un conjunto de dependencias funcionales $F_c$ es un recubrimiento mínimo de $F$ si cumple tres condiciones formales:
1. **Paso 1 (Lados derechos simples):** Toda dependencia en $F_c$ tiene un único atributo en su consecuente ($X \rightarrow A$).
2. **Paso 2 (Sin atributos extraños a la izquierda):** Para toda $X \rightarrow A$, no existe $Y \subset X$ tal que $(F - \{X \rightarrow A\} \cup \{Y \rightarrow A\}) \equiv F$.
3. **Paso 3 (Sin dependencias redundantes):** Para toda $X \rightarrow A \in F_c$, $(F - \{X \rightarrow A\}) \not\models X \rightarrow A$, lo cual se demuestra si $A \notin X^+_{F - \{X \rightarrow A\}}$.

#### Ejecución formal:

**Paso 1: Descomponer lados derechos (Regla de descomposición):**
* $F_1$:
  * $\text{nss} \rightarrow \text{nombre}$
  * $\text{nss} \rightarrow \text{estatus\_vigencia}$
  * $\text{nss} \rightarrow \text{unidad\_medica\_adscripcion}$
  * $\text{nss} \rightarrow \text{nss\_titular}$
* $F_3$:
  * $\text{folio\_orden} \rightarrow \text{fecha\_cita\_medico}$
  * $\text{folio\_orden} \rightarrow \text{medico\_emisor}$
  * $\text{folio\_orden} \rightarrow \text{nss\_paciente}$
* $F_{4a}$ y $F_{4b}$:
  * $\text{id\_cita} \rightarrow \text{fecha\_hora\_agendamiento}$
  * $\text{id\_cita} \rightarrow \text{fecha\_hora\_laboratorio}$
  * $\text{id\_cita} \rightarrow \text{estatus\_asistencia}$
  * $\text{id\_cita} \rightarrow \text{folio\_orden}$
  * $\text{folio\_orden} \rightarrow \text{id\_cita}$
* $F_7, F_8, F_9$:
  * $\text{id\_estudio} \rightarrow \text{tipo\_tubo}$
  * $\text{id\_estudio} \rightarrow \text{color\_tapon}$
  * $\text{id\_estudio} \rightarrow \text{ayuno\_horas}$
  * $\text{id\_estudio} \rightarrow \text{tipo\_frasco}$
  * $\text{id\_estudio} \rightarrow \text{volumen\_minimo}$
  * $\text{id\_estudio} \rightarrow \text{requiere\_medio\_transporte}$
* $F_{10}$:
  * $\text{id\_resultado} \rightarrow \text{valor\_obtenido}$
  * $\text{id\_resultado} \rightarrow \text{unidad\_medida}$
  * $\text{id\_resultado} \rightarrow \text{rango\_referencia}$
  * $\text{id\_resultado} \rightarrow \text{fecha\_hora\_emision}$
  * $\text{id\_resultado} \rightarrow \text{observaciones}$
  * $\text{id\_resultado} \rightarrow \text{id\_cita}$
  * $\text{id\_resultado} \rightarrow \text{id\_estudio}$
  * $\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{id\_resultado}$

**Paso 2: Eliminar atributos extraños en lados izquierdos:**
Analizamos la única dependencia con lado izquierdo compuesto:
$$\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{id\_resultado}$$
* ¿Es $\text{id\_cita}$ extraño? Probamos si $\{\text{id\_estudio}\} \rightarrow \text{id\_resultado}$:
  $\{\text{id\_estudio}\}^+ = \{\text{id\_estudio}, \text{nombre\_estudio}, \text{indicaciones\_previas}, \dots\} \not\ni \text{id\_resultado}$. No es extraño.
* ¿Es $\text{id\_estudio}$ extraño? Probamos si $\{\text{id\_cita}\} \rightarrow \text{id\_resultado}$:
  $\{\text{id\_cita}\}^+ = \{\text{id\_cita}, \text{folio\_orden}, \dots\} \not\ni \text{id\_resultado}$. No es extraño.
* Conclusión: Ningún atributo del lado izquierdo es extraño.

**Paso 3: Eliminar dependencias redundantes:**
Analizamos si alguna dependencia se puede deducir de las demás:
* En `cita`, teníamos $\{\text{folio\_orden}\} \rightarrow \text{fecha\_hora\_laboratorio}$.
  Calculamos $\{\text{folio\_orden}\}^+$ en $F - \{\text{folio\_orden} \rightarrow \text{fecha\_hora\_laboratorio}\}$:
  $\{\text{folio\_orden}\} \rightarrow \text{id\_cita}$, y como $\text{id\_cita} \rightarrow \text{fecha\_hora\_laboratorio}$, por transitividad se obtiene $\text{fecha\_hora\_laboratorio}$.
  Por tanto, las dependencias de atributos de cita con determinante $\text{folio\_orden}$ son **redundantes** gracias a $\text{folio\_orden} \rightarrow \text{id\_cita}$ e $\text{id\_cita} \rightarrow \text{atributos}$.
  Se eliminan de $F_c$ conservando únicamente la bijección entre claves:
  $$\text{folio\_orden} \rightarrow \text{id\_cita} \quad \text{y} \quad \text{id\_cita} \rightarrow \text{folio\_orden}$$

* En `resultado`, evaluamos si $\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{valor\_obtenido}$ es redundante:
  Como $\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{id\_resultado}$ y $\text{id\_resultado} \rightarrow \text{valor\_obtenido}$, por transitividad se preserva.
  Se eliminan las redundancias directas y se conserva $\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{id\_resultado}$.

#### Conjunto Mínimo Final Fc:

El conjunto canónico mínimo irreducible $F_c$ consta de las siguientes 29 dependencias funcionales atómicas:

* **Entidad `paciente`:**
  * $\text{nss} \rightarrow \text{nombre}$
  * $\text{nss} \rightarrow \text{estatus\_vigencia}$
  * $\text{nss} \rightarrow \text{unidad\_medica\_adscripcion}$
  * $\text{nss} \rightarrow \text{nss\_titular}$
* **Entidad `orden_medica`:**
  * $\text{folio\_orden} \rightarrow \text{fecha\_cita\_medico}$
  * $\text{folio\_orden} \rightarrow \text{medico\_emisor}$
  * $\text{folio\_orden} \rightarrow \text{nss\_paciente}$
* **Entidad `cita` (Biyectiva con orden):**
  * $\text{id\_cita} \rightarrow \text{fecha\_hora\_agendamiento}$
  * $\text{id\_cita} \rightarrow \text{fecha\_hora\_laboratorio}$
  * $\text{id\_cita} \rightarrow \text{estatus\_asistencia}$
  * $\text{id\_cita} \rightarrow \text{folio\_orden}$
  * $\text{folio\_orden} \rightarrow \text{id\_cita}$
* **Entidad `estudio` y subtipos:**
  * $\text{id\_estudio} \rightarrow \text{nombre\_estudio}$
  * $\text{id\_estudio} \rightarrow \text{indicaciones\_previas}$
  * $\text{nombre\_estudio} \rightarrow \text{id\_estudio}$
  * $\text{id\_estudio} \rightarrow \text{tipo\_tubo}$
  * $\text{id\_estudio} \rightarrow \text{color\_tapon}$
  * $\text{id\_estudio} \rightarrow \text{ayuno\_horas}$
  * $\text{id\_estudio} \rightarrow \text{tipo\_frasco}$
  * $\text{id\_estudio} \rightarrow \text{volumen\_minimo}$
  * $\text{id\_estudio} \rightarrow \text{requiere\_medio\_transporte}$
* **Entidad `resultado`:**
  * $\text{id\_resultado} \rightarrow \text{valor\_obtenido}$
  * $\text{id\_resultado} \rightarrow \text{unidad\_medida}$
  * $\text{id\_resultado} \rightarrow \text{rango\_referencia}$
  * $\text{id\_resultado} \rightarrow \text{fecha\_hora\_emision}$
  * $\text{id\_resultado} \rightarrow \text{observaciones}$
  * $\text{id\_resultado} \rightarrow \text{id\_cita}$
  * $\text{id\_resultado} \rightarrow \text{id\_estudio}$
  * $\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{id\_resultado}$

---

### 4. Demostración de Equivalencia (F ≡ Fc)

Dos conjuntos de dependencias funcionales $F$ y $G$ son equivalentes ($F \equiv G$) si y solo si $F^+ = G^+$, lo cual se demuestra verificando que:
1. $F \models G$ (cada dependencia de $G$ puede inferirse de $F$, es decir, para cada $X \rightarrow Y \in G$, $Y \subseteq X^+_F$).
2. $G \models F$ (cada dependencia de $F$ puede inferirse de $G$, es decir, para cada $X \rightarrow Y \in F$, $Y \subseteq X^+_G$).

* **Prueba de $F \models F_c$:**
  Cada dependencia en $F_c$ se obtuvo mediante descomposición de lados derechos de dependencias originales de $F$ o de axiomas de transitividad básicos. Por tanto, trivialmente $F_c \subseteq F^+$.
* **Prueba de $F_c \models F$:**
  Las únicas dependencias de $F$ que no están textualmente en $F_c$ son las dependencias transitivas compuestas eliminadas en el Paso 3, tales como:
  * $\{\text{folio\_orden}\} \rightarrow \text{fecha\_hora\_laboratorio}$:  
    Calculamos $\{\text{folio\_orden}\}^+_{F_c}$:
    $$\{\text{folio\_orden}\} \rightarrow \text{id\_cita} \rightarrow \text{fecha\_hora\_laboratorio}$$
    Como $\text{fecha\_hora\_laboratorio} \in \{\text{folio\_orden}\}^+_{F_c}$, la dependencia se preserva en $F_c$.
  * $\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{valor\_obtenido}$:  
    Calculamos $\{\text{id\_cita}, \text{id\_estudio}\}^+_{F_c}$:
    $$\{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{id\_resultado} \rightarrow \text{valor\_obtenido}$$
    Como $\text{valor\_obtenido} \in \{\text{id\_cita}, \text{id\_estudio}\}^+_{F_c}$, la dependencia se preserva en $F_c$.

**Conclusión:** Se cumple formalmente $F^+ = F_c^+$, demostrando que **$F_c$ es un recubrimiento canónico equivalente**.

---

## Ejercicio 1.3. Las Formas Normales

### 1. Diagnóstico de Formas Normales del Esquema Actual

Evaluamos formalmente las definiciones de Codd y Boyce-Codd sobre las 10 tablas del esquema:
* **1FN (Primera Forma Normal):** Todos los dominios de los atributos son atómicos (no hay grupos repetitivos ni atributos multivaluados o compuestos).
* **2FN (Segunda Forma Normal):** Está en 1FN y ningún atributo no primo depende funcionalmente de un subconjunto propio de una clave candidata (no hay dependencias parciales).
* **3FN (Tercera Forma Normal):** Está en 2FN y ningún atributo no primo depende transitivamente de una clave candidata (para toda $X \rightarrow A$, $X$ es superclave o $A$ es un atributo primo).
* **BCNF (Forma Normal de Boyce-Codd):** Para toda dependencia funcional no trivial $X \rightarrow A$, $X$ es una superclave estricta.

| Tabla | Claves Candidatas | Atributos Primos | Atributos No Primos | Dependencias Funcionales Activas | Forma Normal Alcanzada | Justificación Teórica |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| `paciente` | $\{\text{nss}\}$ | `nss` | `nombre`, `estatus_vigencia`, `unidad_medica_adscripcion`, `nss_titular` | $\text{nss} \rightarrow \text{Atributos}$ | **BCNF** | La clave es simple. Todo determinante es superclave. |
| `paciente_telefono` | $\{\text{nss}, \text{telefono}\}$ | `nss`, `telefono` | Ninguno | Ninguna no trivial | **BCNF** | Todos los atributos son primos (relación todo-clave). |
| `orden_medica` | $\{\text{folio_orden}\}$ | `folio_orden` | `fecha_cita_medico`, `medico_emisor`, `nss_paciente` | $\text{folio\_orden} \rightarrow \text{Atributos}$ | **BCNF** | Clave simple, sin dependencias parciales ni transitivas. |
| `cita` | $\{\text{id_cita}\}$, $\{\text{folio_orden}\}$ | `id_cita`, `folio_orden` | `fecha_hora_agendamiento`, `fecha_hora_laboratorio`, `estatus_asistencia` | $\text{id\_cita} \leftrightarrow \text{folio\_orden} \rightarrow \text{Atributos}$ | **BCNF** | Toda dependencia tiene como determinante una superclave. |
| `estudio` | $\{\text{id_estudio}\}$, $\{\text{nombre_estudio}\}$ | `id_estudio`, `nombre_estudio` | `indicaciones_previas` | $\text{id\_estudio} \leftrightarrow \text{nombre\_estudio} \rightarrow \text{indicaciones}$ | **BCNF** | Claves alternas simples; todo determinante es superclave. |
| `orden_estudio` | $\{\text{folio_orden}, \text{id_estudio}\}$ | Ambos | Ninguno | Ninguna no trivial | **BCNF** | Relación todo-clave pura. |
| `prueba_sangre` | $\{\text{id_estudio}\}$ | `id_estudio` | `tipo_tubo`, `color_tapon`, `ayuno_horas` | $\text{id\_estudio} \rightarrow \text{Atributos}$ | **BCNF** | Clave simple; determinante es superclave. |
| `prueba_orina` | $\{\text{id_estudio}\}$ | `id_estudio` | `tipo_frasco`, `volumen_minimo` | $\text{id\_estudio} \rightarrow \text{Atributos}$ | **BCNF** | Clave simple; determinante es superclave. |
| `prueba_fecal` | $\{\text{id_estudio}\}$ | `id_estudio` | `tipo_frasco`, `requiere_medio_transporte` | $\text{id\_estudio} \rightarrow \text{Atributos}$ | **BCNF** | Clave simple; determinante es superclave. |
| `resultado` | $\{\text{id_resultado}\}$, $\{\text{id_cita}, \text{id_estudio}\}$ | `id_resultado`, `id_cita`, `id_estudio` | `valor_obtenido`, `unidad_medida`, `rango_referencia`, `fecha_hora_emision`, `observaciones` | $\text{id\_resultado} \leftrightarrow \{\text{id\_cita}, \text{id\_estudio}\} \rightarrow \text{Atributos}$ | **BCNF** | Todos los determinantes son superclaves candidatas válidas. |

**Conclusión:** Las 10 tablas del esquema actual se encuentran ya en la **Forma Normal de Boyce-Codd (BCNF)**, la forma normal más estricta de normalización funcional.

---

### 2. Demostración y Normalización de una Tabla Desnormalizada a Propósito

Conforme a la instrucción explícita de la rúbrica:
> *«Si su esquema ya estaba en 3FN, demuéstrelo con las dependencias y el cierre, y normalice en su lugar una tabla desnormalizada a propósito que construya con datos de su dominio.»*

Construimos la tabla desnormalizada intencionalmente representativa de un sistema legado plano de recepción:

$$\text{RECEPCION\_PLANA}(\underline{\text{nss}}, \text{nombre\_paciente}, \text{unidad\_medica}, \underline{\text{telefono}}, \underline{\text{folio\_orden}}, \text{fecha\_orden}, \text{medico\_emisor}, \underline{\text{id\_estudio}}, \text{nombre\_estudio}, \text{tipo\_categoria}, \text{tipo\_tubo}, \text{ayuno\_horas}, \text{valor\_resultado})$$

#### A) Anomalías de la tabla desnormalizada:
1. **Anomalía de Inserción:** No se puede dar de alta a un nuevo derechohabiente en el sistema a menos que ya tenga una orden médica y se le haya asignado un estudio específico, porque `folio_orden` e `id_estudio` forman parte de la clave primaria y no pueden ser nulos (regla de integridad de entidad).
2. **Anomalía de Borrado:** Si un paciente cancela su única orden médica, al borrar la tupla se borra también su registro como derechohabiente y su catálogo de teléfonos.
3. **Anomalía de Modificación:** Si el médico emisor cambia de nombre o adscripción, hay que actualizar decenas de filas correspondientes a cada estudio que prescribió en cada orden médica; si una fila no se actualiza, la base de datos queda inconsistente.

#### B) Proceso de Normalización Paso a Paso:

##### Paso 1: De No-1FN a 1FN
* **Problema:** El atributo `telefono` es multivaluado (un paciente puede tener varios números).
* **Solución 1FN:** Se extrae el atributo multivaluado a una relación separada con la clave del derechohabiente:
  * $R_{\text{tel}} = (\underline{\text{nss}}, \underline{\text{telefono}})$
  * $R_{\text{resto}} = (\underline{\text{folio\_orden}}, \underline{\text{id\_estudio}}, \text{nss}, \text{nombre\_paciente}, \text{unidad\_medica}, \text{fecha\_orden}, \text{medico\_emisor}, \text{nombre\_estudio}, \text{tipo\_categoria}, \text{tipo\_tubo}, \text{ayuno\_horas}, \text{valor\_resultado})$

##### Paso 2: De 1FN a 2FN (Eliminación de dependencias parciales)
* **Problema en $R_{\text{resto}}$:** La clave primaria es compuesta: $\{\text{folio\_orden}, \text{id\_estudio}\}$.
  Existen dependencias parciales donde atributos no primos dependen de solo una parte de la clave:
  * $\{\text{folio\_orden}\} \rightarrow \{\text{nss}, \text{nombre\_paciente}, \text{unidad\_medica}, \text{fecha\_orden}, \text{medico\_emisor}\}$ (depende solo de `folio_orden`, no de `id_estudio`).
  * $\{\text{id\_estudio}\} \rightarrow \{\text{nombre\_estudio}, \text{tipo\_categoria}, \text{tipo\_tubo}, \text{ayuno\_horas}\}$ (depende solo de `id_estudio`).
  * Únicamente $\text{valor\_resultado}$ depende de la clave completa $\{\text{folio\_orden}, \text{id\_estudio}\}$.
* **Solución 2FN:** Se descompone en tres relaciones:
  1. $R_{\text{orden}} = (\underline{\text{folio\_orden}}, \text{nss}, \text{nombre\_paciente}, \text{unidad\_medica}, \text{fecha\_orden}, \text{medico\_emisor})$
  2. $R_{\text{estudio}} = (\underline{\text{id\_estudio}}, \text{nombre\_estudio}, \text{tipo\_categoria}, \text{tipo\_tubo}, \text{ayuno\_horas})$
  3. $R_{\text{resultado\_puente}} = (\underline{\text{folio\_orden}}, \underline{\text{id\_estudio}}, \text{valor\_resultado})$

##### Paso 3: De 2FN a 3FN (Eliminación de dependencias transitivas)
* **Problema en $R_{\text{orden}}$:**
  $\text{folio\_orden} \rightarrow \text{nss}$ y $\text{nss} \rightarrow \{\text{nombre\_paciente}, \text{unidad\_medica}\}$.
  Por tanto, $\text{nombre\_paciente}$ y $\text{unidad\_medica}$ dependen **transitivamente** de $\text{folio\_orden}$ a través de $\text{nss}$.
* **Solución 3FN:** Se descompone $R_{\text{orden}}$:
  1. $R_{\text{paciente}} = (\underline{\text{nss}}, \text{nombre\_paciente}, \text{unidad\_medica})$
  2. $R_{\text{orden\_p}} = (\underline{\text{folio\_orden}}, \text{fecha\_orden}, \text{medico\_emisor}, \text{nss})$
* **Problema en $R_{\text{estudio}}$:**
  $\text{id\_estudio} \rightarrow \text{tipo\_categoria}$, y los atributos $\text{tipo\_tubo}, \text{ayuno\_horas}$ aplican únicamente si $\text{tipo\_categoria} = \text{'Sangre'}$.
  Se descomponen en supertipo y subtipo disjunto:
  1. $R_{\text{estudio\_gen}} = (\underline{\text{id\_estudio}}, \text{nombre\_estudio}, \text{tipo\_categoria})$
  2. $R_{\text{sangre}} = (\underline{\text{id\_estudio}}, \text{tipo\_tubo}, \text{ayuno\_horas})$

---

### 3. Comprobación de Reunión Sin Pérdida y Preservación de Dependencias

#### A) Teorema de Reunión Sin Pérdida (Lossless Join)
Una descomposición de una relación $R$ en $R_1$ y $R_2$ con dependencias $F$ es una reunión sin pérdida con respecto a $F$ si y solo si el atributo común entre ambas relaciones es una superclave de al menos una de ellas:
$$(R_1 \cap R_2) \rightarrow R_1 \quad \text{o} \quad (R_1 \cap R_2) \rightarrow R_2$$

* **Demostración en la descomposición de $R_{\text{orden}}$:**
  * $R_1 = R_{\text{paciente}} = (\text{nss}, \text{nombre\_paciente}, \text{unidad\_medica})$
  * $R_2 = R_{\text{orden\_p}} = (\text{folio\_orden}, \text{fecha\_orden}, \text{medico\_emisor}, \text{nss})$
  * Atributo común: $R_1 \cap R_2 = \{\text{nss}\}$.
  * Verificamos el cierre: $\{\text{nss}\}^+_{F} = \{\text{nss}, \text{nombre\_paciente}, \text{unidad\_medica}\} = R_1$.
  * Como $\{\text{nss}\}$ es clave de $R_1$, se cumple $(R_1 \cap R_2) \rightarrow R_1$.
  * **$\therefore$ La reunión es estrictamente SIN PÉRDIDA (Lossless Join).**

* **Demostración en la descomposición de $R_{\text{estudio}}$:**
  * $R_1 = R_{\text{estudio\_gen}} = (\text{id\_estudio}, \text{nombre\_estudio}, \text{tipo\_categoria})$
  * $R_2 = R_{\text{sangre}} = (\text{id\_estudio}, \text{tipo\_tubo}, \text{ayuno\_horas})$
  * Atributo común: $R_1 \cap R_2 = \{\text{id\_estudio}\}$.
  * $\{\text{id\_estudio}\}^+_{F} = R_1$ y también $\{\text{id\_estudio}\}^+_{F} = R_2$.
  * Como $\{\text{id\_estudio}\}$ es clave de ambas, la reunión es **SIN PÉRDIDA**.

#### B) Teorema de Preservación de Dependencias
Una descomposición $D = \{R_1, R_2, \dots, R_m\}$ preserva las dependencias si la unión de las proyecciones de $F$ sobre cada relación es equivalente a $F$:
$$(F_1 \cup F_2 \cup \dots \cup F_m)^+ = F^+$$

* En nuestra descomposición:
  * $F_1 (\text{en } R_{\text{paciente}}): \text{nss} \rightarrow \{\text{nombre\_paciente}, \text{unidad\_medica}\}$
  * $F_2 (\text{en } R_{\text{orden\_p}}): \text{folio\_orden} \rightarrow \{\text{fecha\_orden}, \text{medico\_emisor}, \text{nss}\}$
  * $F_3 (\text{en } R_{\text{estudio\_gen}}): \text{id\_estudio} \rightarrow \{\text{nombre\_estudio}, \text{tipo\_categoria}\}$
  * $F_4 (\text{en } R_{\text{sangre}}): \text{id\_estudio} \rightarrow \{\text{tipo\_tubo}, \text{ayuno\_horas}\}$
  * $F_5 (\text{en } R_{\text{resultado}}): \{\text{folio\_orden}, \text{id\_estudio}\} \rightarrow \text{valor\_resultado}$
* Ninguna dependencia funcional se perdió; cada una se puede verificar dentro de una sola tabla mediante su clave primaria sin necesidad de realizar operaciones de `JOIN`.
* **$\therefore$ La descomposición PRESERVA EL 100% DE LAS DEPENDENCIAS FUNCIONALES.**

---

### 4. Implementación de la Migración SQL (`003-normalizacion.sql`)

La migración de prueba se documenta en el archivo `practica6-8/migraciones/003-normalizacion.sql`, donde se crea la tabla desnormalizada, se llena con datos reales de la base poblada, y luego se descompone y migra conservando los datos sin pérdida.
