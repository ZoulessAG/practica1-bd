# Reporte de Trabajo Individual - Prácticas 6, 7 y 8
## Bases de Datos (ISC / IIA - ESCOM IPN)
**Alumno:** Joel Sanchez Palma  
**Usuario de GitHub:** `alcatel04`  
**Proyecto Propio:** Sistema de Citas Médicas y Laboratorio Clínico (*CitasMed*)  

---

## 1. Consultas Propias en Álgebra Relacional

### Consulta Individual 1: División Relacional (÷)
* **Pregunta clínica:** ¿Qué pacientes han tenido órdenes que abarcan la totalidad de las pruebas coprológicas del catálogo?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{nss\_paciente},\, \text{id\_estudio}}(\text{orden\_medica} \bowtie \text{orden\_estudio}) \div \pi_{\text{id\_estudio}}(\text{prueba\_fecal})$$

### Consulta Individual 2: Reunión Externa Completa (⟗)
* **Pregunta clínica:** Relación bilateral entre órdenes médicas y citas, auditando inconsistencias en ambos extremos.
* **Expresión en Álgebra Relacional:**
  $$\text{orden\_medica} \mathbin{⟗}_{\text{folio\_orden}} \text{cita}$$

### Consulta Individual 3: Intersección con Proyección (π ∘ ∩)
* **Pregunta clínica:** Identificadores de pacientes que acudieron a citas en dos meses operativos distintos.

---

## 2. Explicación de la Descomposición Relacional (Parte 1)
*[Descomposición de la jerarquía de subtipos de estudio para evitar anomalías de nulos bajo la Pauta 3]*

---
**Firma:** Joel Sanchez Palma (`alcatel04`)
