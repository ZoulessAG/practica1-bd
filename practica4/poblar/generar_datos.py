"""Genera datos sintéticos reproducibles para Práctica 4 (Ej. 1.3 y 1.4).
Cumple todas las restricciones de esquema.sql y 001-dominios.sql (>=200 filas por tabla principal).
"""
import csv
import datetime
import pathlib
import random

random.seed(20261112)

OUT_DIR = pathlib.Path(__file__).resolve().parent.parent / "datos"
OUT_DIR.mkdir(parents=True, exist_ok=True)

NOMBRES = [
    "Carlos", "Mariana", "Juan", "Alondra", "Kevin", "Joel", "Sofía", "Diego",
    "Valeria", "Mateo", "Camila", "Sebastián", "Lucía", "Andrés", "Fernanda", "Luis"
]
APELLIDOS = [
    "Sánchez", "Ruiz", "Pérez", "López", "Aguilar", "García", "Vega", "Treviño",
    "Quintanar", "Palma", "Mendoza", "Ramírez", "Torres", "Flores", "Cruz", "Morales"
]
UNIDADES = [
    "HGZ No. 24 Insurgentes", "UMF No. 10 Chuviscar", "UMF No. 20 Vallejo",
    "HGZ No. 1 Gabriel Mancera", "UMF No. 41 Magdalena", "HGR No. 2 Villa Coapa"
]
MEDICOS = [
    "Dr. Roberto Gómez (Ced. 12345678)",
    "Dra. Elena Martínez (Ced. 23456789)",
    "Dr. Alejandro Navarro (Ced. 34567890)",
    "Dra. Patricia Morales (Ced. 45678901)",
    "Dr. Héctor Castillo (Ced. 56789012)"
]
ESTATUS = ["PROGRAMADA", "CONFIRMADA", "ASISTIO", "CANCELADA", "NO_ASISTIO"]


def write_csv(filename: str, headers: list[str], rows: list[list]):
    path = OUT_DIR / filename
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(headers)
        w.writerows(rows)
    print(f"  {filename}: {len(rows)} filas")


def main():
    # 1. Pacientes: 120 titulares + 100 beneficiarios = 220
    pacientes = []
    titulares_nss = []
    base_nss = 11000000000
    for i in range(1, 221):
        nss = str(base_nss + i)
        nombre = f"{random.choice(NOMBRES)} {random.choice(APELLIDOS)} {random.choice(APELLIDOS)}"
        vigencia = "true" if i % 15 != 0 else "false"
        unidad = random.choice(UNIDADES)
        if i <= 120:
            nss_titular = ""
            titulares_nss.append(nss)
        else:
            nss_titular = titulares_nss[(i - 121) % len(titulares_nss)]
        pacientes.append([nss, nombre, vigencia, unidad, nss_titular])
    write_csv("paciente.csv", ["nss", "nombre", "estatus_vigencia", "unidad_medica_adscripcion", "nss_titular"], pacientes)

    # 2. Teléfonos: 250 registros únicos (nss, telefono)
    telefonos = []
    seen_tel = set()
    for i in range(1, 251):
        nss = pacientes[(i - 1) % len(pacientes)][0]
        tel = f"55{10000000 + i * 37}"
        if (nss, tel) not in seen_tel:
            seen_tel.add((nss, tel))
            telefonos.append([nss, tel])
    write_csv("paciente_telefono.csv", ["nss", "telefono"], telefonos)

    # 3. Órdenes médicas (220) y Citas (220) cumpliendo anticipación de 15-30 días y horario 06-20h
    ordenes = []
    citas = []
    start_agendamiento = datetime.date(2026, 9, 1)
    for i in range(1, 221):
        folio = f"ORD-2026-{i:04d}"
        nss = pacientes[i - 1][0]
        medico = random.choice(MEDICOS)
        f_agend = start_agendamiento + datetime.timedelta(days=(i % 40))
        # Laboratorio entre 2 y 10 días después de agendamiento; consulta médica 15-30 días después de laboratorio
        f_lab_date = f_agend + datetime.timedelta(days=2 + (i % 8))
        anticipacion = 15 + (i % 16)  # 15..30 días
        f_medico = f_lab_date + datetime.timedelta(days=anticipacion)
        hora_lab = 6 + (i % 14)  # 06:00..19:00
        min_lab = (i * 15) % 60
        ts_agend = f"{f_agend.isoformat()} 09:00:00-06"
        ts_lab = f"{f_lab_date.isoformat()} {hora_lab:02d}:{min_lab:02d}:00-06"
        est = ESTATUS[i % len(ESTATUS)]
        ordenes.append([folio, f_medico.isoformat(), medico, nss])
        citas.append([i, ts_agend, ts_lab, est, folio])
    write_csv("orden_medica.csv", ["folio_orden", "fecha_cita_medico", "medico_emisor", "nss_paciente"], ordenes)
    write_csv("cita.csv", ["id_cita", "fecha_hora_agendamiento", "fecha_hora_laboratorio", "estatus_asistencia", "folio_orden"], citas)

    # 4. Estudios (15) y subtipos (6 sangre, 5 orina, 4 fecal)
    estudios_def = [
        (1, "Química Sanguínea 6 Elementos", "Ayuno estricto de 8 a 12 horas.", "sangre", ("Tubo con gel separador", "Rojo / Oro", 8)),
        (2, "Biometría Hemática Completa", "No requiere ayuno estricto.", "sangre", ("Tubo EDTA K2", "Lila", 0)),
        (3, "Perfil Lipídico Completo", "Ayuno de 12 horas; evitar alcohol 24h.", "sangre", ("Tubo seco con gel", "Amarillo", 12)),
        (4, "Hemoglobina Glucosilada (HbA1c)", "No requiere ayuno.", "sangre", ("Tubo EDTA", "Lila", 0)),
        (5, "Pruebas de Función Hepática", "Ayuno de 8 horas.", "sangre", ("Tubo con gel separador", "Rojo", 8)),
        (6, "Electrolitos Séricos (Na, K, Cl)", "Ayuno de 8 horas.", "sangre", ("Tubo heparina litio", "Verde", 8)),
        (7, "Examen General de Orina (EGO)", "Primer chorro de la primera orina de la mañana.", "orina", ("Frasco estéril boca ancha", "30 ml")),
        (8, "Urocultivo con Antibiograma", "Aseo previo; chorro medio.", "orina", ("Frasco estéril sellado", "20 ml")),
        (9, "Depuración de Creatinina 24h", "Recolectar toda la orina de 24 horas.", "orina", ("Garrafón recolector 3L", "500 ml")),
        (10, "Microalbuminuria en Orina", "Primera orina de la mañana.", "orina", ("Frasco estéril 100 ml", "15 ml")),
        (11, "Prueba de Embarazo en Orina", "Primera orina matutina.", "orina", ("Frasco limpio", "10 ml")),
        (12, "Coproparasitoscópico Seriado (3 muestras)", "Recolectar en días consecutivos.", "fecal", ("Frasco estéril con conservador", True)),
        (13, "Coprocultivo", "Muestra reciente sin contaminación de orina.", "fecal", ("Frasco con medio Cary-Blair", True)),
        (14, "Sangre Oculta en Heces", "Dieta sin carnes rojas 48h previas.", "fecal", ("Frasco recolector con espátula", False)),
        (15, "Rotavirus en Heces", "Muestra diarreica fresca.", "fecal", ("Frasco estéril hermético", False)),
    ]
    estudios, sangre, orina, fecal = [], [], [], []
    for eid, nom, ind, tipo, extra in estudios_def:
        estudios.append([eid, nom, ind])
        if tipo == "sangre":
            sangre.append([eid, extra[0], extra[1], extra[2]])
        elif tipo == "orina":
            orina.append([eid, extra[0], extra[1]])
        else:
            fecal.append([eid, extra[0], "true" if extra[1] else "false"])
    write_csv("estudio.csv", ["id_estudio", "nombre_estudio", "indicaciones_previas"], estudios)
    write_csv("prueba_sangre.csv", ["id_estudio", "tipo_tubo", "color_tapon", "ayuno_horas"], sangre)
    write_csv("prueba_orina.csv", ["id_estudio", "tipo_frasco", "volumen_minimo"], orina)
    write_csv("prueba_fecal.csv", ["id_estudio", "tipo_frasco", "requiere_medio_transporte"], fecal)

    # 5. orden_estudio (440 filas: 2 por orden) y resultado (220 filas: 1 por cita)
    orden_estudio = []
    resultados = []
    valores = [
        ("94.2", "mg/dL", "70.0 - 100.0"),
        ("14.3", "g/dL", "12.0 - 16.0"),
        ("185", "mg/dL", "< 200.0"),
        ("5.6", "%", "4.0 - 5.6"),
        ("Negativo", "cualitativo", "Negativo"),
    ]
    for i, ord_row in enumerate(ordenes, start=1):
        folio = ord_row[0]
        e1 = ((i - 1) % 15) + 1
        e2 = (i % 15) + 1
        orden_estudio.append([folio, e1])
        orden_estudio.append([folio, e2])
        val, uni, ref = valores[i % len(valores)]
        ts_emision = f"{(datetime.date(2026, 9, 15) + datetime.timedelta(days=i % 45)).isoformat()} 14:30:00-06"
        resultados.append([i, val, uni, ref, ts_emision, "Validado por químico responsable.", i, e1])

    write_csv("orden_estudio.csv", ["folio_orden", "id_estudio"], orden_estudio)
    write_csv("resultado.csv", ["id_resultado", "valor_obtenido", "unidad_medida", "rango_referencia", "fecha_hora_emision", "observaciones", "id_cita", "id_estudio"], resultados)


if __name__ == "__main__":
    main()
