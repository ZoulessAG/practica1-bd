# Ejercicio 1.3 y 1.4: Fuente de Datos y Script de Carga

## 1.3 Justificación de fuente de datos (datos sintéticos reproducibles)

### Búsqueda previa en fuentes abiertas
Se consultaron los portales públicos de datos abiertos antes de optar por generación sintética:
- **Portal de Datos Abiertos de México (`datos.gob.mx`):** términos `"laboratorio clínico"`, `"citas médicas"`, `"órdenes de laboratorio"` — únicamente existen directorios de unidades médicas y cifras agregadas por delegación, sin registros desagregados de órdenes médicas, horarios de toma de muestra ni resultados por paciente (por confidencialidad de datos clínicos bajo la LFPDPPP y NOM-004-SSA3-2012).
- **Datos Abiertos CDMX (`datos.cdmx.gob.mx`) e INEGI:** términos `"atenciones laboratorio"`, `"citas consulta externa"` — solo catálogos de establecimientos e indicadores estadísticos mensuales, sin esquema relacional de órdenes, estudios ni resultados.

**Conclusión:** No existe un conjunto público con registros individuales de pacientes, órdenes médicas, citas con anticipación de 15–30 días y resultados de laboratorio. Por ello, los datos de [datos/](./datos/) son **100% sintéticos**, generados de forma determinista (`seed = 20261112`) mediante [poblar/generar_datos.py](./poblar/generar_datos.py), con **≥ 220 renglones** en cada tabla principal y sin datos personales reales.

### Correspondencia de archivos generados

| Archivo CSV | Tabla destino | Registros | Campos principales |
| :--- | :--- | ---: | :--- |
| `datos/paciente.csv` | `paciente` | 220 | `nss`, `nombre`, `estatus_vigencia`, `unidad_medica_adscripcion`, `nss_titular` (120 titulares, 100 beneficiarios) |
| `datos/paciente_telefono.csv` | `paciente_telefono` | 250 | `nss`, `telefono` |
| `datos/orden_medica.csv` | `orden_medica` | 220 | `folio_orden`, `fecha_cita_medico`, `medico_emisor`, `nss_paciente` |
| `datos/cita.csv` | `cita` | 220 | `id_cita`, `fecha_hora_agendamiento`, `fecha_hora_laboratorio`, `estatus_asistencia`, `folio_orden` |
| `datos/estudio.csv` | `estudio` | 15 | `id_estudio`, `nombre_estudio`, `indicaciones_previas` |
| `datos/prueba_sangre.csv` | `prueba_sangre` | 6 | `id_estudio`, `tipo_tubo`, `color_tapon`, `ayuno_horas` |
| `datos/prueba_orina.csv` | `prueba_orina` | 5 | `id_estudio`, `tipo_frasco`, `volumen_minimo` |
| `datos/prueba_fecal.csv` | `prueba_fecal` | 4 | `id_estudio`, `tipo_frasco`, `requiere_medio_transporte` |
| `datos/orden_estudio.csv` | `orden_estudio` | 440 | `folio_orden`, `id_estudio` |
| `datos/resultado.csv` | `resultado` | 220 | `id_resultado`, `valor_obtenido`, `unidad_medida`, `rango_referencia`, `fecha_hora_emision`, `observaciones`, `id_cita`, `id_estudio` |

---

## 1.4 Script de carga automatizado (`poblar.sh` / `poblar.ps1` + `cargar.sql`)

- **Un solo comando (sin credenciales en el código):**
  - Linux/macOS/Git Bash: `PGHOST=localhost PGPORT=5433 PGDATABASE=citas_medicas_p4 PGUSER=admin_lab PGPASSWORD=... ./poblar/poblar.sh`
  - Windows PowerShell: `$env:PGHOST="localhost"; $env:PGPORT="5433"; $env:PGDATABASE="citas_medicas_p4"; $env:PGUSER="admin_lab"; $env:PGPASSWORD="..."; .\poblar\poblar.ps1`
- **Diseño:** Utiliza `\copy` hacia tablas temporales (`ON COMMIT DROP`) dentro de una sola transacción `BEGIN ... COMMIT`, inserta en orden topológico (`paciente` titulares → beneficiarios → `paciente_telefono` → `orden_medica` → `cita` → `estudio` y subtipos → `orden_estudio` → `resultado`) con `ON CONFLICT DO NOTHING` y reporta `leidos`, `insertados` y `omitidos`.

### Salida real de terminal — Primera ejecución (carga limpia)
```text
COPY 220   (1.012 ms)
COPY 250   (0.894 ms)
COPY 220   (0.908 ms)
COPY 220   (1.824 ms)
COPY 15    (0.614 ms)
COPY 6     (0.684 ms)
COPY 5     (0.539 ms)
COPY 4     (0.529 ms)
COPY 440   (1.032 ms)
COPY 220   (0.894 ms)
NOTICE:  Tabla paciente: leidos=220, insertados=220, omitidos=0
NOTICE:  Tabla paciente_telefono: leidos=250, insertados=250, omitidos=0
NOTICE:  Tabla orden_medica: leidos=220, insertados=220, omitidos=0
NOTICE:  Tabla cita: leidos=220, insertados=220, omitidos=0
NOTICE:  Tabla estudio: leidos=15, insertados=15, omitidos=0
NOTICE:  Tabla prueba_sangre: leidos=6, insertados=6, omitidos=0
NOTICE:  Tabla prueba_orina: leidos=5, insertados=5, omitidos=0
NOTICE:  Tabla prueba_fecal: leidos=4, insertados=4, omitidos=0
NOTICE:  Tabla orden_estudio: leidos=440, insertados=440, omitidos=0
NOTICE:  Tabla resultado: leidos=220, insertados=220, omitidos=0
DO (Time: 138.501 ms)
COMMIT (Time: 15.296 ms)
```

### Salida real de terminal — Segunda ejecución (prueba de idempotencia)
```text
NOTICE:  Tabla paciente: leidos=220, insertados=0, omitidos=220
NOTICE:  Tabla paciente_telefono: leidos=250, insertados=0, omitidos=250
NOTICE:  Tabla orden_medica: leidos=220, insertados=0, omitidos=220
NOTICE:  Tabla cita: leidos=220, insertados=0, omitidos=220
NOTICE:  Tabla estudio: leidos=15, insertados=0, omitidos=15
NOTICE:  Tabla prueba_sangre: leidos=6, insertados=0, omitidos=6
NOTICE:  Tabla prueba_orina: leidos=5, insertados=0, omitidos=5
NOTICE:  Tabla prueba_fecal: leidos=4, insertados=0, omitidos=4
NOTICE:  Tabla orden_estudio: leidos=440, insertados=0, omitidos=440
NOTICE:  Tabla resultado: leidos=220, insertados=0, omitidos=220
DO (Time: 60.702 ms)
COMMIT (Time: 11.062 ms)
```

### Incidencia detectada durante la carga inicial (zona horaria)
En el primer intento de carga masiva, el trigger `fn_validar_anticipacion_cita()` rechazó una cita con `anticipación actual: 14 días` aunque los datos tenían 15 días de diferencia, debido a que el contenedor corre en `UTC` y `NEW.fecha_hora_laboratorio::DATE` convertía `19:00:00-06` al día siguiente en UTC. Se corrigió el trigger usando `(NEW.fecha_hora_laboratorio AT TIME ZONE 'America/Mexico_City')::DATE`.
