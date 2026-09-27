# Tabla de Correspondencia entre Modelo EER y Esquema Publicado

| Entidad / Concepto en Modelo EER | Tabla(s) en Esquema Publicado (Repo) | Información ganada / perdida al pasar de un modelo a otro |
| :--- | :--- | :--- |
| **`EVENTO_SISMICO`** | `Fact_Sismos` (Tabla de Hechos) | **Ganado en EER:** Expresión clara de llaves candidatas y reglas de integridad relacional.<br>**Perdido en EER:** Pre-agregaciones analíticas y métricas denormalizadas de rendimiento. |
| **`UBICACION_GEOGRAFICA`** | `Dim_Ubicacion` | **Ganado en EER:** Normalización de jerarquías territoriales (Estado -> Municipio).<br>**Perdido en EER:** Atributos planos redundantes diseñados para velocidad de agrupamiento (`GROUP BY`). |
| **`ESTACION_SISMICA`** | `Dim_Estacion` | **Ganado en EER:** Relación explícita N:M con eventos a través de lecturas operativas.<br>**Perdido en EER:** Control de dimensiones de cambio lento (SCD Type 2). |
| **`REGISTRO_ESTACION`** (Entidad Débil) | Atributos colapsados en `Fact_Sismos` | **Ganado en EER:** Registro individualizado de señales por estación.<br>**Perdido en EER:** En el almacén se consolidó un único registro por evento para optimizar espacio. |