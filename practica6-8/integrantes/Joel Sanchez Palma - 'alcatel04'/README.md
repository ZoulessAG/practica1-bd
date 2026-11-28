# Reporte de Trabajo Individual - Prácticas 6, 7 y 8
## Bases de Datos (ISC / IIA - ESCOM IPN)
**Alumno:** Joel Sanchez Palma  
**Usuario de GitHub:** `alcatel04`  
**Proyecto Propio:** Sistema de Citas Médicas y Laboratorio Clínico (*CitasMed*)  

---

## 1. Consultas Propias en Álgebra Relacional

### Consulta Individual 1: Reunión de Catálogo y Especificación (⋈ ∘ σ)
* **Pregunta clínica:** ¿Cuáles son los estudios de sangre que usan tubo con gel separador y cuál es su tapón?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{id}\textunderscore\text{estudio}, \text{nombre}\textunderscore\text{estudio}, \text{color}\textunderscore\text{tapon}}(\text{estudio} \bowtie \sigma_{\text{tipo}\textunderscore\text{tubo} = \text{'Tubo con gel separador'}}(\text{prueba}\textunderscore\text{sangre}))$$
* **Sintaxis RelaX:**
  ```text
  pi id_estudio, nombre_estudio, color_tapon (estudio join (sigma tipo_tubo = 'Tubo con gel separador' (prueba_sangre)))
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-joel-01.png`]*

### Consulta Individual 2: Reunión Externa Izquierda (⟕)
* **Pregunta clínica:** ¿Cuáles son todas las órdenes médicas registradas, preservando aquellas que aún no tienen una cita de laboratorio agendada?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{folio}\textunderscore\text{orden}, \text{fecha}\textunderscore\text{orden}, \text{medico}\textunderscore\text{emisor}, \text{id}\textunderscore\text{cita}, \text{estatus}}(\text{orden}\textunderscore\text{medica} \mathbin{⟕} \text{cita})$$
* **Sintaxis RelaX:**
  ```text
  pi folio_orden, fecha_orden, medico_emisor, id_cita, estatus (orden_medica left outer join cita)
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-joel-02.png`]*

### Consulta Individual 3: Agrupación de Catálogo por Categoría (γ)
* **Pregunta clínica:** ¿Cuántos estudios existen en el catálogo general agrupados por su tipo de categoría clínica?
* **Expresión en Álgebra Relacional:**
  $$\gamma_{\text{tipo}\textunderscore\text{categoria}; \text{count}(\text{id}\textunderscore\text{estudio}) \rightarrow \text{total}\textunderscore\text{estudios}}(\text{estudio})$$
* **Sintaxis RelaX:**
  ```text
  gamma tipo_categoria; count(id_estudio)->total_estudios (estudio)
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-joel-03.png`]*

---

## 2. Explicación de la Descomposición Relacional (Parte 1)
*[Descomposición de la jerarquía de subtipos de estudio para evitar anomalías de nulos bajo la Pauta 3]*

---
**Firma:** Joel Sanchez Palma (`alcatel04`)
