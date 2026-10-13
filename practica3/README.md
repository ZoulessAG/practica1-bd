# Práctica 3: Transformación del Modelo Entidad-Relación Extendido al Modelo Relacional

## Instituto Politécnico Nacional - Escuela Superior de Cómputo (ESCOM)
* **Unidad de aprendizaje:** Bases de Datos (Plan 2020)
* **Gestor de Base de Datos utilizado:** PostgreSQL 15 en contenedor Docker (`postgres:15-alpine`)
* **Nombre del contenedor:** `postgres_laboratorio`
* **Base de datos propia creada:** `citas_medicas_p3`
* **Proyecto Propio:** Sistema de Citas Médicas y Laboratorio Clínico
* **Proyecto Asignado:** [Seismic Data Visualization System](https://github.com/gabrielhuav/Seismic-Data-Visualization-System)

---

## Integrantes del Equipo y Registro de Issues (Ejercicio 8)

| Integrante | Usuario de GitHub | Propuesta Seleccionada (Issue Práctica 2) | Enlace al Issue |
| :--- | :--- | :--- | :--- |
| **Aguilar Garcia Ian Andrew** | `ZoulessAG` | [Propuesta] Sistema de alertas tempranas y cálculo de réplicas en tiempo real *(Área IA)* | [#2](https://github.com/ZoulessAG/practica1-bd/issues/2) |
| **Vega Treviño Kevin Edu** | `Elslowee` | [Propuesta] Intersección Espacial con Infraestructura Crítica | [#14](https://github.com/ZoulessAG/practica1-bd/issues/14) |
| **Quintanar Sanchez Alondra** | `AlooXoX` | [Propuesta] Identificación y Visualización de Enjambres Sísmicos | [#8](https://github.com/ZoulessAG/practica1-bd/issues/8) |
| **Sanchez Palma Joel** | `alcatel04` | [Propuesta] Zonificación de Impacto Real mediante Isosistas (Polígonos Espaciales) | [#7](https://github.com/ZoulessAG/practica1-bd/issues/7) |

---

## Estructura del Entregable (`practica3/`)

```text
practica3/
├── README.md
├── evidencias/
│   ├── ejecucion-esquema-sin-errores.png
│   ├── listado-tablas-creadas.png
│   └── rechazo-restricciones.png
├── proyecto-propio/
│   ├── inventario-eer.pdf
│   ├── transformacion.pdf
│   ├── diccionario-de-datos.pdf
│   ├── diagrama-relacional.png
│   └── sql/
│       ├── esquema.sql
│       └── pruebas-de-restricciones.sql
└── proyecto-asignado/
    ├── analisis-del-esquema.pdf
    ├── comparacion-eer-relacional.pdf
    └── cambios/
        ├── cambio-ZoulessAG.sql
        ├── cambio-ZoulessAG.pdf
        ├── cambio-Elslowee.sql
        ├── cambio-Elslowee.pdf
        ├── cambio-AlooXoX.sql
        ├── cambio-AlooXoX.pdf
        ├── cambio-alcatel04.sql
        └── cambio-alcatel04.pdf
```

---

## Declaración de Integridad Académica y Uso de IA Generativa
En apego a la rúbrica de la práctica, se declara que para el desarrollo de esta práctica se emplearon herramientas de Inteligencia Artificial Generativa como apoyo para la formulación inicial de scripts DDL, diseño de casos de prueba de restricciones y redacción técnica de matrices comparativas. Todo el código resultante fue verificado, ejecutado y validado en el sistema gestor PostgreSQL por los integrantes del equipo.

---

## Bibliografía (Formato APA 7.ª edición)
* Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7th ed.). Pearson.
* Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7th ed.). McGraw-Hill Education.
* PostgreSQL Global Development Group. (2023). *PostgreSQL 15.0 Documentation: Data Definition*. PostgreSQL Documentation. https://www.postgresql.org/docs/15/ddl.html
