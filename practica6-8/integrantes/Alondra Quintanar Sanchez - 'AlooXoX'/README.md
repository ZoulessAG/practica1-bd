# Reporte de Trabajo Individual - Prácticas 6, 7 y 8
## Bases de Datos (ISC / IIA - ESCOM IPN)
**Alumna:** Alondra Quintanar Sanchez  
**Usuario de GitHub:** `AlooXoX`  
**Proyecto Propio:** Sistema de Citas Médicas y Laboratorio Clínico (*CitasMed*)  

---

## 1. Consultas Propias en Álgebra Relacional

### Consulta Individual 1: Reunión con Filtro de Categoría (⋈ ∘ σ)
* **Pregunta clínica:** ¿Qué pacientes tienen estudios asignados que pertenecen a la categoría 'Orina'?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{nss}\textunderscore\text{paciente}, \text{folio}\textunderscore\text{orden}, \text{nombre}\textunderscore\text{estudio}}(\text{orden}\textunderscore\text{medica} \bowtie (\text{orden}\textunderscore\text{estudio} \bowtie \sigma_{\text{tipo}\textunderscore\text{categoria} = \text{'Orina'}}(\text{estudio})))$$
* **Sintaxis RelaX:**
  ```text
  pi nss_paciente, folio_orden, nombre_estudio (orden_medica join (orden_estudio join (sigma tipo_categoria = 'Orina' (estudio))))
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-alondra-01.png`]*

### Consulta Individual 2: Diferencia Relacional (-)
* **Pregunta clínica:** ¿Qué estudios clínicos del catálogo general no han sido prescritos en ninguna orden médica?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{id}\textunderscore\text{estudio}}(\text{estudio}) - \pi_{\text{id}\textunderscore\text{estudio}}(\text{orden}\textunderscore\text{estudio})$$
* **Sintaxis RelaX:**
  ```text
  (pi id_estudio (estudio)) - (pi id_estudio (orden_estudio))
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-alondra-02.png`]*

### Consulta Individual 3: Agrupación con Conteo por Clínica (γ)
* **Pregunta clínica:** ¿Cuántos derechohabientes tiene registrados cada unidad médica de adscripción?
* **Expresión en Álgebra Relacional:**
  $$\gamma_{\text{unidad}\textunderscore\text{medica}; \text{count}(\text{nss}) \rightarrow \text{total}\textunderscore\text{derechohabientes}}(\text{paciente})$$
* **Sintaxis RelaX:**
  ```text
  gamma unidad_medica; count(nss)->total_derechohabientes (paciente)
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-alondra-03.png`]*

---

## 2. Explicación de la Descomposición Relacional (Parte 1)
*[Descomposición de atributos de contacto y entidad multivaluada `paciente_telefono` para cumplimiento de 1FN y prevención de redundancia]*

---
**Firma:** Alondra Quintanar Sanchez (`AlooXoX`)
