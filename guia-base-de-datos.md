# Guía Completa de Estudio: Fundamentos y Arquitectura de Sistemas de Bases de Datos

---

## Unidad 1: Aspectos Básicos y Conceptos Fundamentales

### 1.1 Definición de Base de Datos y SGBD

* **Base de Datos (BD):** Colección estructurada, organizada e integrada de datos interrelacionados que representan un aspecto del mundo real (denominado *Minimundo* o *Universo del Discurso*). Está diseñada para ser compartida por múltiples usuarios y aplicaciones de forma concurrente, garantizando la consistencia, integridad y seguridad.
* **Sistema Gestor de Bases de Datos (SGBD / DBMS):** Conjunto de programas informáticos especializados que permite a los usuarios definir, crear, mantener, consultar y controlar el acceso a la base de datos. Sirve como interfaz entre las aplicaciones del usuario y los datos físicos almacenados.

---

### 1.2 Características Principales de una Base de Datos

* **Naturaleza autodescriptiva:** Almacena no solo los datos, sino también la descripción de estos (metadatos) en el **Diccionario de Datos** o **Catálogo del Sistema**.
* **Aislamiento entre programas y datos (Independencia):** La estructura de los datos se define separadamente de los programas de aplicación que acceden a ellos.
* **Soporte de múltiples vistas de los datos:** Cada usuario o perfil puede visualizar únicamente la parte de la base de datos que le compete o para la cual tiene autorización.
* **Compartición de datos y procesamiento de transacciones multiusuario:** Permite el acceso simultáneo garantizando el control de concurrencia para evitar discrepancias.
* **Propiedades ACID en las Transacciones:**
    * **Atomicidad (*Atomicity*):** La transacción se ejecuta completamente o no se ejecuta en absoluto (*All-or-Nothing*).
    * **Consistencia (*Consistency*):** Una transacción lleva a la base de datos de un estado válido a otro estado válido, respetando todas las reglas e integridades.
    * **Aislamiento (*Isolation*):** La ejecución simultánea de transacciones produce el mismo estado que si se ejecutaran en secuencia.
    * **Durabilidad (*Durability*):** Una vez que una transacción realiza el *commit*, los cambios persisten de manera permanente, incluso ante fallos del sistema.

---

### 1.3 Archivos Tradicionales vs. Bases de Datos

| Criterio | Sistemas de Archivos Tradicionales | Sistemas de Bases de Datos (SGBD) |
| :--- | :--- | :--- |
| **Redundancia e Inconsistencia** | Alta redundancia (datos duplicados en múltiples archivos) lo que conduce a inconsistencia. | Redundancia controlada/mínima mediante la normalización y centralización. |
| **Dependencia de Datos** | Alta dependencia: la estructura de los datos está codificada dentro de los programas de aplicación. | Alta independencia de datos: el cambio en la estructura física no afecta las aplicaciones. |
| **Acceso a los Datos** | Complejo y rígido; requiere escribir código a medida para cada nueva consulta. | Flexible y estandarizado mediante lenguajes declarativos de consulta (ej. SQL). |
| **Control de Concurrencia** | Inexistente o primitivo; bloquea el archivo completo o provoca sobreescritura de datos. | Sofisticado; control mediante bloqueos a nivel de fila/tabla y manejo de transacciones. |
| **Seguridad e Integridad** | Difícil de aplicar; dispersa en cada código de aplicación. | Centralizada; se define en el catálogo del SGBD (restricciones de clave, dominio, etc.). |

---

### 1.4 Tipos de Usuarios de Bases de Datos

```mermaid
graph TD
    U[Usuarios de una BD] --> DBA[Administrador de BD - DBA]
    U --> D[Diseñadores de la BD]
    U --> DEV[Desarrolladores de Aplicación]
    U --> UF[Usuarios Finales]
    U --> US[Usuarios Sofisticados]

    UF --> Naive[Naive / Habituales]
    UF --> Esp[Esporádicos]