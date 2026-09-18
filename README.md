# Práctica 1: Modelo Entidad Relación

**Instituto Politécnico Nacional**  
**Escuela Superior de Cómputo**  
*Unidad de aprendizaje:* Bases de Datos  
*Plan de estudios:* Ingeniería en Sistemas Computacionales (2020)

---

## Datos del Alumno / Equipo

| Nombre Completo | Boleta | Grupo | Carrera |
| :--- | :--- | :--- | :--- |
| Ian Andrew Aguilar Garcia | 2026630300 | 3CV2 | Ingeniería en Sistemas Computacionales |
| Kevin Edú Vega Treviño | 2026630108 | 3CV2 | Ingeniería en Sistemas Computacionales |
| Alondra Quintanar Sánchez | 2026630237 | 3CV2 | Ingeniería en Sistemas Computacionales |
| Sánchez Palma Joel | 2026630122 | 3CV2 | Ingeniería en Sistemas Computacionales |

---

## Descripción del Proyecto

> **Sistema de Gestión de Citas, Pacientes y Estudios en Laboratorio Clínico**
>
> Diseño e implementación de una base de datos relacional para optimizar el flujo operativo en el área de laboratorio de una unidad médica. El sistema centraliza la validación de derechohabientes mediante el Número de Seguridad Social (NSS), la programación controlada de tomas de muestra con base en reglas de anticipación médica, y la trazabilidad del historial de asistencia clínica.

---

### Alcance y Reglas del Negocio

* **Control y Validación de Pacientes:** Registro de datos personales y verificación de identidad, vigencia y unidad médica de adscripción mediante NSS.
* **Gestión y Agendamiento de Citas:** Programación de estudios clínicos cumpliendo la restricción temporal de 15 a 30 días de anticipación respecto a la consulta con el médico tratante.
* **Trazabilidad de Estudios y Órdenes Médicas:** Vinculación de estudios específicos solicitados por orden médica e integración al expediente clínico del paciente.
* **Eficiencia Operativa e Historial:** Registro de confirmación de asistencia y control de ausencias con un tiempo objetivo de atención máximo de 2 minutos por ventanilla.
---

## Índice de Entregables

1. **Ejercicio 1. Control de versiones con Git y GitHub**
   - [Investigación: Conceptos y flujos de trabajo](./docs/Ejercicio1_Investigacion.pdf)
   - [Evidencia: Captura del árbol de confirmaciones (`git log`)](evidencias/git/git-log-graph.png)
   - [Evidencia: Captura del Pull Request fusionado](evidencias/git/pull-request-merged.png)

2. **Ejercicio 2. El sistema gestor en un contenedor: Docker**
   - [Investigación: Contenedores, imágenes y volúmenes](./docs/Ejercicio2_Investigacion.pdf)
   - [Configuración del contenedor: `compose.yaml`](entorno/compose.yaml)
   - [Evidencia: Conexión al gestor PostgreSQL](evidencias/docker/conexion-postgres.png)
   - [Evidencia: Demostración de persistencia de datos](evidencias/docker/persistencia-volumen.png)

3. **Ejercicio 3. Investigación: ¿Qué es una base de datos?**
  - [Documento PDF: Unidad Temática I](./docs/investigacion-bases-de-datos.pdf)

4. **Ejercicio 4. Estado del arte: tres artículos científicos**
  - [Documento PDF: Fichas analíticas y comparativa](./docs/estado-del-arte.pdf)

5. **Ejercicio 5. Caso de estudio y modelo entidad-relación**
  - [Documento PDF: Planteamiento del problema, entrevista y requerimientos](docs/caso-de-estudio.pdf)
  - [Diagrama Entidad-Relación: Esquema conceptual (PNG)](modelo/diagrama-er.png)

---

## Instrucciones para levantar el entorno

1. Clonar el repositorio y acceder a la carpeta de configuración:
   ```bash
   git clone [https://github.com/ZoulessAG/practica1-bd.git](https://github.com/ZoulessAG/practica1-bd.git)
   cd practica1-bd/entorno