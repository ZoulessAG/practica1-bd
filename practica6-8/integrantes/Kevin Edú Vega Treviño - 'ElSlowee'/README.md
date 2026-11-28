# Reporte de Trabajo Individual - Prácticas 6, 7 y 8
## Bases de Datos (ISC / IIA - ESCOM IPN)
**Alumno:** Kevin Edú Vega Treviño  
**Usuario de GitHub:** `ElSlowee`  
**Proyecto Propio:** Sistema de Citas Médicas y Laboratorio Clínico (*CitasMed*)  

---

## 1. Consultas Propias en Álgebra Relacional

### Consulta Individual 1: Selección Booleana Compuesta (σ)
* **Pregunta clínica:** ¿Cuáles citas fueron programadas con 5 o más días de anticipación y su estatus actual es 'CONFIRMADA'?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{id}\textunderscore\text{cita}, \text{folio}\textunderscore\text{orden}, \text{fecha}\textunderscore\text{laboratorio}, \text{dias}\textunderscore\text{anticipacion}}(\sigma_{\text{dias}\textunderscore\text{anticipacion} \ge 5 \land \text{estatus} = \text{'CONFIRMADA'}}(\text{cita}))$$
* **Sintaxis RelaX:**
  ```text
  pi id_cita, folio_orden, fecha_laboratorio, dias_anticipacion (sigma dias_anticipacion >= 5 and estatus = 'CONFIRMADA' (cita))
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-kevin-01.png`]*

### Consulta Individual 2: Unión de Recipientes Compatibles (∪)
* **Pregunta clínica:** ¿Cuáles son todos los tipos de recipientes y frascos recolectores requeridos entre pruebas de orina y fecales?
* **Expresión en Álgebra Relacional:**
  $$\pi_{\text{tipo}\textunderscore\text{frasco}}(\text{prueba}\textunderscore\text{orina}) \cup \pi_{\text{tipo}\textunderscore\text{frasco}}(\text{prueba}\textunderscore\text{fecal})$$
* **Sintaxis RelaX:**
  ```text
  (pi tipo_frasco (prueba_orina)) union (pi tipo_frasco (prueba_fecal))
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-kevin-02.png`]*

### Consulta Individual 3: Agrupación Multitabla con Conteo de Resultados (γ)
* **Pregunta clínica:** ¿Cuántos resultados emitidos tiene registrados cada estudio clínico en el laboratorio?
* **Expresión en Álgebra Relacional:**
  $$\gamma_{\text{nombre}\textunderscore\text{estudio}; \text{count}(\text{id}\textunderscore\text{resultado}) \rightarrow \text{total}\textunderscore\text{resultados}}(\text{estudio} \bowtie \text{resultado})$$
* **Sintaxis RelaX:**
  ```text
  gamma nombre_estudio; count(id_resultado)->total_resultados (estudio join resultado)
  ```
* **Captura de RelaX (Árbol y Resultado):**
  *[Pendiente de captura: guardar en `../../evidencias/relax/individual-kevin-03.png`]*

---

## 2. Explicación de la Descomposición Relacional (Parte 1)
*[Descomposición de la relación 1:1 entre orden médica y cita, garantizando conservación de dependencias]*

---
**Firma:** Kevin Edú Vega Treviño (`ElSlowee`)
