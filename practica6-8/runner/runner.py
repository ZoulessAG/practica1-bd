#!/usr/bin/env python3
import os
import subprocess
import glob

QUERIES_META = {
    "01-seleccion.sql": {
        "num": "01",
        "title": "Selección Simple (σ)",
        "question": "¿Cuáles son los derechohabientes con vigencia de derechos activa en el sistema?",
        "algebra": "σ_{estatus_vigencia = true}(paciente)"
    },
    "02-proyeccion.sql": {
        "num": "02",
        "title": "Proyección Simple (π)",
        "question": "¿Cuáles son las unidades médicas de adscripción registradas en el catálogo de pacientes?",
        "algebra": "π_{unidad_medica_adscripcion}(paciente)"
    },
    "03-seleccion-proyeccion.sql": {
        "num": "03",
        "title": "Composición de Selección y Proyección (π ∘ σ)",
        "question": "¿Cuáles son las pruebas de sangre que requieren 8 o más horas de ayuno estricto?",
        "algebra": "π_{id_estudio, tipo_tubo, color_tapon}(σ_{ayuno_horas >= 8}(prueba_sangre))"
    },
    "04-union.sql": {
        "num": "04",
        "title": "Unión de Conjuntos con Compatibilidad (∪)",
        "question": "¿Cuáles son todos los identificadores de derechohabientes que fungen como titulares o como beneficiarios?",
        "algebra": "π_{nss}(σ_{nss_titular is null}(paciente)) ∪ π_{nss_titular}(σ_{nss_titular is not null}(paciente))"
    },
    "05-diferencia.sql": {
        "num": "05",
        "title": "Diferencia de Conjuntos (-)",
        "question": "¿Qué derechohabientes registrados no tienen ningún número telefónico de contacto?",
        "algebra": "π_{nss}(paciente) - π_{nss}(paciente_telefono)"
    },
    "06-interseccion.sql": {
        "num": "06",
        "title": "Intersección de Conjuntos (∩)",
        "question": "¿Qué estudios clínicos fueron prescritos simultáneamente en las órdenes ORD-2026-0001 y ORD-2026-0003?",
        "algebra": "π_{id_estudio}(σ_{folio='ORD-2026-0001'}(orden_estudio)) ∩ π_{id_estudio}(σ_{folio='ORD-2026-0003'}(orden_estudio))"
    },
    "07-producto-cartesiano.sql": {
        "num": "07",
        "title": "Producto Cartesiano (×)",
        "question": "¿Cuál es la combinación completa entre el catálogo de estudios de orina y los frascos de pruebas fecales?",
        "algebra": "π_{nombre_estudio}(estudio ⋈ prueba_orina) × π_{tipo_frasco}(prueba_fecal)"
    },
    "08-reunion-natural.sql": {
        "num": "08",
        "title": "Reunión Natural / Equi-Join (⋈)",
        "question": "¿Cuál es el nombre del paciente y el médico emisor de cada orden médica expedida?",
        "algebra": "π_{nss, nombre, folio_orden, medico_emisor}(paciente ⋈_{nss=nss_paciente} orden_medica)"
    },
    "09-reunion-theta.sql": {
        "num": "09",
        "title": "Reunión Theta con Desigualdad (⋈_θ)",
        "question": "¿Qué pares de estudios sanguíneos tienen horas de ayuno distintas, comparando el mayor contra el menor?",
        "algebra": "ρ_{A}(prueba_sangre) ⋈_{A.ayuno_horas > B.ayuno_horas} ρ_{B}(prueba_sangre)"
    },
    "10-reunion-externa.sql": {
        "num": "10",
        "title": "Reunión Externa Izquierda (⟕)",
        "question": "¿Cuáles son todos los pacientes y sus teléfonos, preservando a los pacientes sin teléfono registrado?",
        "algebra": "π_{nss, nombre, telefono}(paciente ⟕_{paciente.nss = paciente_telefono.nss} paciente_telefono)"
    },
    "11-agregacion.sql": {
        "num": "11",
        "title": "Agrupación y Agregación (γ)",
        "question": "¿Cuántas citas clínicas existen agrupadas por estatus de asistencia?",
        "algebra": "γ_{estatus_asistencia; count(id_cita) -> total_citas}(cita)"
    },
    "12-agrupacion.sql": {
        "num": "12",
        "title": "Agrupación Multitabla con Conteo (γ)",
        "question": "¿Cuántos estudios de laboratorio en total ha prescrito cada médico emisor?",
        "algebra": "γ_{medico_emisor; count(id_estudio) -> total_estudios}(orden_medica ⋈ orden_estudio)"
    },
    "13-division.sql": {
        "num": "13",
        "title": "División Relacional (÷)",
        "question": "¿Qué órdenes médicas prescriben TODOS los estudios de orina del catálogo institucional?",
        "algebra": "π_{folio_orden, id_estudio}(orden_estudio) ÷ π_{id_estudio}(prueba_orina)"
    }
}

def main():
    pghost = os.getenv("PGHOST", "localhost")
    pgport = os.getenv("PGPORT", "5432")
    pguser = os.getenv("PGUSER", "admin_lab")
    pgpass = os.getenv("PGPASSWORD", "laboratorio_secret_pass")
    pgdb   = os.getenv("PGDATABASE", "citas_medicas_p4")

    env = os.environ.copy()
    env["PGPASSWORD"] = pgpass

    consultas_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "consultas")
    sql_files = sorted(glob.glob(os.path.join(consultas_dir, "*.sql")))

    print("========================================================================")
    print(" EJECUCIÓN AUTOMATIZADA DE CONSULTAS DE ÁLGEBRA RELACIONAL (PARTE 2)")
    print("========================================================================")

    for sql_path in sql_files:
        fname = os.path.basename(sql_path)
        meta = QUERIES_META.get(fname, {
            "num": fname[:2],
            "title": fname,
            "question": "Consulta SQL",
            "algebra": "Expresión Relacional"
        })

        print(f"\n------------------------------------------------------------------------")
        print(f" [CONSULTA {meta['num']}] {meta['title']}")
        print(f"------------------------------------------------------------------------")
        print(f" • PREGUNTA:  {meta['question']}")
        print(f" • ÁLGEBRA:   {meta['algebra']}")
        print(f" • RESULTADO EN POSTGRESQL:")

        cmd = [
            "psql",
            "-h", pghost,
            "-p", str(pgport),
            "-U", pguser,
            "-d", pgdb,
            "-f", sql_path
        ]

        try:
            res = subprocess.run(cmd, env=env, capture_output=True, text=True, check=True)
            # Limitar salida si tiene muchas filas para claridad
            lines = res.stdout.strip().splitlines()
            if len(lines) > 25:
                print("\n".join(lines[:20]))
                print(f"   ... [{len(lines) - 20} filas adicionales omitidas en consola] ...")
            else:
                print(res.stdout.strip())
        except subprocess.CalledProcessError as e:
            print(f"ERROR al ejecutar {fname}:")
            print(e.stderr)

    print("\n------------------------------------------------------------------------")
    print(" [OK] Todas las 13 consultas fueron ejecutadas contra el gestor.")
    print("------------------------------------------------------------------------")

if __name__ == "__main__":
    main()
