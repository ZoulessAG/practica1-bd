# Reporte de Trabajo Individual - Prácticas 6, 7 y 8
## Bases de Datos (ISC / IIA - ESCOM IPN)
**Alumna:** Alondra Quintanar Sanchez  
**Usuario de GitHub:** `AlooXoX`  
**Proyecto Propio:** Sistema de Citas Médicas y Laboratorio Clínico (*CitasMed*)  

---

## 1. Consultas Propias en Álgebra Relacional

### Consulta Individual 1: Reunión Externa Derecha / Izquierda (⟕)
* **Pregunta clínica:** ¿Cuáles son los estudios del catálogo y sus indicaciones de preparación, preservando aquellos estudios que no han sido solicitados en ninguna orden médica?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{id\_estudio},\, \text{nombre\_estudio},\, \text{folio\_orden}}(\text{estudio} \mathbin{⟕} \text{orden\_estudio})$$
* **Sintaxis RelaX:**
  ```text
  pi id_estudio, nombre_estudio, folio_orden (estudio leftouterjoin orden_estudio)
  ```
* **Consulta SQL Equivalente:**
  ```sql
  SELECT e.id_estudio, e.nombre_estudio, oe.folio_orden
  FROM estudio e
  LEFT JOIN orden_estudio oe ON e.id_estudio = oe.id_estudio;
  ```

### Consulta Individual 2: Diferencia Relacional (-)
* **Pregunta clínica:** ¿Cuáles son los médicos emisores que nunca han emitido una orden que incluya pruebas coprológicas/fecales?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{medico\_emisor}}(\text{orden\_medica}) - \pi_{\text{medico\_emisor}}(\text{orden\_medica} \bowtie \text{orden\_estudio} \bowtie \text{prueba\_fecal})$$

### Consulta Individual 3: Agrupación y Selección (γ ∘ σ)
* **Pregunta clínica:** ¿Cuántos estudios de tipo orina tienen un volumen mínimo requerido mayor o igual a 20 ml?
* **Expresión en Álgebra Relacional:**
  $$\gamma_{\text{count}(\text{id\_estudio}) \rightarrow \text{total}}(\sigma_{\text{volumen\_minimo} \ge '20 ml'}(\text{prueba\_orina}))$$

---

## 2. Explicación de la Descomposición Relacional (Parte 1)
*[Descomposición de atributos de contacto y entidad multivaluada `paciente_telefono` para cumplimiento de 1FN y prevención de redundancia]*

---
**Firma:** Alondra Quintanar Sanchez (`AlooXoX`)
