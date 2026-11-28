# Reporte de Trabajo Individual - Prácticas 6, 7 y 8
## Bases de Datos (ISC / IIA - ESCOM IPN)
**Alumno:** Kevin Edú Vega Treviño  
**Usuario de GitHub:** `ElSlowee`  
**Proyecto Propio:** Sistema de Citas Médicas y Laboratorio Clínico (*CitasMed*)  

---

## 1. Consultas Propias en Álgebra Relacional

### Consulta Individual 1: Reunión Externa Izquierda (⟕)
* **Pregunta clínica:** ¿Cuáles son todos los pacientes y su fecha de última orden médica, conservando pacientes recién registrados sin órdenes?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{nss},\, \text{nombre},\, \text{fecha\_cita\_medico}}(\text{paciente} \mathbin{⟕} \text{orden\_medica})$$

### Consulta Individual 2: División Relacional (÷)
* **Pregunta clínica:** ¿Qué órdenes médicas prescriben todos los estudios de química sanguínea con ayuno estricto de 8 horas?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{folio\_orden},\, \text{id\_estudio}}(\text{orden\_estudio}) \div \pi_{\text{id\_estudio}}(\sigma_{\text{ayuno\_horas} = 8}(\text{prueba\_sangre}))$$

### Consulta Individual 3: Agregación con Función Promedio (γ)
* **Pregunta clínica:** Promedio de anticipación de citas clínicas por clínica de adscripción del paciente.

---

## 2. Explicación de la Descomposición Relacional (Parte 1)
*[Descomposición de la relación 1:1 entre orden médica y cita, garantizando conservación de dependencias]*

---
**Firma:** Kevin Edú Vega Treviño (`ElSlowee`)
