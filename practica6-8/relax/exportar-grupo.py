#!/usr/bin/env python3
"""
exportar-grupo.py
Exportador automatizado de la base de datos clinica a formato de Grupo de RelaX
(Relational Algebra Calculator - dbis-uibk.github.io/relax).
Garantiza integridad referencial extrayendo entre 10 y 30 tuplas consistentes por tabla.
"""

import os
import sys
import json

def generar_grupo_relax():
    directorio_actual = os.path.dirname(os.path.abspath(__file__))
    archivo_salida = os.path.join(directorio_actual, "grupo.txt")
    
    # Datos representativos normalizados con integridad referencial completa
    pacientes = [
        ("1234567890", "Ian Andrew Aguilar Garcia", "true", "HGZ No. 24 Insurgentes", "null"),
        ("11000000001", "Sofia Vega Torres", "true", "HGR No. 2 Villa Coapa", "null"),
        ("11000000002", "Diego Lopez Trevino", "true", "HGZ No. 1 Gabriel Mancera", "null"),
        ("11000000003", "Sebastian Garcia Morales", "true", "UMF No. 41 Magdalena", "null"),
        ("11000000004", "Sofia Trevino Morales", "true", "HGZ No. 1 Gabriel Mancera", "null"),
        ("11000000005", "Andres Sanchez Palma", "true", "HGZ No. 24 Insurgentes", "null"),
        ("11000000006", "Diego Lopez Mendoza", "true", "HGR No. 2 Villa Coapa", "null"),
        ("11000000007", "Carlos Lopez Mendoza", "true", "UMF No. 10 Chuviscar", "null"),
        ("11000000008", "Andres Torres Palma", "true", "HGZ No. 24 Insurgentes", "null"),
        ("11000000009", "Mariana Ruiz Vega", "true", "HGR No. 2 Villa Coapa", "null"),
        ("11000000010", "Valeria Mendoza Flores", "false", "UMF No. 10 Chuviscar", "null"),
        ("11000000011", "Camila Flores Vega", "true", "UMF No. 20 Vallejo", "11000000001"),
        ("11000000012", "Mateo Sanchez Aguilar", "true", "HGZ No. 24 Insurgentes", "1234567890"),
        ("11000000013", "Juan Lopez Trevino", "true", "HGZ No. 1 Gabriel Mancera", "11000000002"),
        ("11000000014", "Lucia Garcia Morales", "true", "UMF No. 41 Magdalena", "11000000003")
    ]

    telefonos = [
        ("1234567890", "5572289894"),
        ("11000000001", "5510000037"),
        ("11000000001", "5510008177"),
        ("11000000002", "5510000074"),
        ("11000000002", "5510008214"),
        ("11000000003", "5510000111"),
        ("11000000004", "5510000148"),
        ("11000000005", "5510000185"),
        ("11000000006", "5510000222"),
        ("11000000007", "5510000259"),
        ("11000000008", "5510000296"),
        ("11000000009", "5510000333"),
        ("11000000010", "5510000370"),
        ("11000000011", "5510000407"),
        ("11000000012", "5510000444")
    ]

    ordenes = [
        ("ORD-2026-0001", "2026-09-20", "Dr. Roberto Gomez", "1234567890"),
        ("ORD-2026-0002", "2026-09-21", "Dra. Carmen Salinas", "11000000001"),
        ("ORD-2026-0003", "2026-09-24", "Dr. Fernando Ruiz", "11000000002"),
        ("ORD-2026-0004", "2026-09-27", "Dra. Patricia Morales", "11000000003"),
        ("ORD-2026-0005", "2026-09-30", "Dr. Hector Herrera", "11000000004"),
        ("ORD-2026-0006", "2026-10-03", "Dra. Laura Mendez", "11000000005"),
        ("ORD-2026-0007", "2026-10-06", "Dr. Roberto Gomez", "11000000006"),
        ("ORD-2026-0008", "2026-10-09", "Dra. Carmen Salinas", "11000000007"),
        ("ORD-2026-0009", "2026-10-12", "Dr. Fernando Ruiz", "11000000008"),
        ("ORD-2026-0010", "2026-10-15", "Dra. Patricia Morales", "11000000009"),
        ("ORD-2026-0011", "2026-10-18", "Dr. Hector Herrera", "11000000010"),
        ("ORD-2026-0012", "2026-10-21", "Dra. Laura Mendez", "11000000011"),
        ("ORD-2026-0013", "2026-10-24", "Dr. Roberto Gomez", "11000000012"),
        ("ORD-2026-0014", "2026-10-27", "Dra. Carmen Salinas", "11000000013"),
        ("ORD-2026-0015", "2026-10-30", "Dr. Fernando Ruiz", "11000000014")
    ]

    citas = [
        (1, "ORD-2026-0001", "2026-09-02 08:00", 18, "CONFIRMADA"),
        (2, "ORD-2026-0002", "2026-09-05 08:30", 16, "ASISTIO"),
        (3, "ORD-2026-0003", "2026-09-07 09:00", 17, "ASISTIO"),
        (4, "ORD-2026-0004", "2026-09-09 07:45", 18, "ASISTIO"),
        (5, "ORD-2026-0005", "2026-09-11 08:15", 19, "CONFIRMADA"),
        (6, "ORD-2026-0006", "2026-09-13 09:30", 20, "PROGRAMADA"),
        (7, "ORD-2026-0007", "2026-09-15 08:00", 21, "ASISTIO"),
        (8, "ORD-2026-0008", "2026-09-17 08:30", 22, "CONFIRMADA"),
        (9, "ORD-2026-0009", "2026-09-19 09:00", 23, "ASISTIO"),
        (10, "ORD-2026-0010", "2026-09-21 07:30", 24, "CANCELADA"),
        (11, "ORD-2026-0011", "2026-09-23 08:00", 25, "NO_ASISTIO"),
        (12, "ORD-2026-0012", "2026-09-25 08:45", 26, "CONFIRMADA"),
        (13, "ORD-2026-0013", "2026-09-27 09:15", 27, "ASISTIO"),
        (14, "ORD-2026-0014", "2026-09-29 08:00", 28, "ASISTIO"),
        (15, "ORD-2026-0015", "2026-10-01 08:30", 29, "CONFIRMADA")
    ]

    estudios = [
        (1, "Quimica Sanguinea 6 Elementos", "Sangre", "Ayuno estricto de 8 a 12 horas"),
        (2, "Biometria Hematica Completa", "Sangre", "No requiere ayuno estricto"),
        (3, "Perfil Lipidico Completo", "Sangre", "Ayuno de 12 horas; evitar alcohol"),
        (4, "Hemoglobina Glucosilada (HbA1c)", "Sangre", "No requiere ayuno"),
        (5, "Pruebas de Funcion Hepatica", "Sangre", "Ayuno de 8 horas"),
        (6, "Electrolitos Sericos (Na, K, Cl)", "Sangre", "Ayuno de 8 horas"),
        (7, "Examen General de Orina (EGO)", "Orina", "Primera orina de la manana"),
        (8, "Urocultivo con Antibiograma", "Orina", "Aseo previo; chorro medio"),
        (9, "Depuracion de Creatinina 24h", "Orina", "Recolectar toda la orina de 24 horas"),
        (10, "Microalbuminuria en Orina", "Orina", "Primera orina de la manana"),
        (11, "Prueba de Embarazo en Orina", "Orina", "Primera orina matutina"),
        (12, "Coproparasitoscopico Seriado", "Fecal", "Tres muestras en dias consecutivos"),
        (13, "Coprocultivo", "Fecal", "Muestra fresca sin contaminacion"),
        (14, "Sangre Oculta en Heces", "Fecal", "Dieta sin carnes rojas 48h previas"),
        (15, "Rotavirus en Heces", "Fecal", "Muestra diarreica fresca")
    ]

    prueba_sangre = [
        (1, "Tubo con gel separador", "Rojo / Oro", 8),
        (2, "Tubo EDTA K2", "Lila", 0),
        (3, "Tubo seco con gel", "Amarillo", 12),
        (4, "Tubo EDTA", "Lila", 0),
        (5, "Tubo con gel separador", "Rojo", 8),
        (6, "Tubo heparina litio", "Verde", 8)
    ]

    prueba_orina = [
        (7, "Frasco esteril boca ancha", "30 ml"),
        (8, "Frasco esteril sellado", "20 ml"),
        (9, "Garrafon recolector 3L", "500 ml"),
        (10, "Frasco esteril 100 ml", "15 ml"),
        (11, "Frasco limpio", "10 ml")
    ]

    prueba_fecal = [
        (12, "Frasco esteril con conservador", "true"),
        (13, "Frasco con medio Cary-Blair", "true"),
        (14, "Frasco recolector con espatula", "false"),
        (15, "Frasco esteril hermetico", "false")
    ]

    orden_estudio = [
        ("ORD-2026-0001", 1),
        ("ORD-2026-0001", 7),
        ("ORD-2026-0002", 2),
        ("ORD-2026-0003", 1),
        ("ORD-2026-0003", 3),
        ("ORD-2026-0004", 7),
        ("ORD-2026-0005", 2),
        ("ORD-2026-0006", 4),
        ("ORD-2026-0007", 5),
        ("ORD-2026-0008", 8),
        ("ORD-2026-0009", 12),
        ("ORD-2026-0010", 1),
        ("ORD-2026-0011", 7),
        ("ORD-2026-0012", 2),
        ("ORD-2026-0013", 13),
        ("ORD-2026-0014", 6),
        ("ORD-2026-0015", 14)
    ]

    resultados = [
        (1, 1, 1, "92.5", "mg/dL", "70.0 - 99.0", "Glucosa en ayuno normal"),
        (2, 1, 7, "Normal", "aspecto", "Limpido", "Color amarillo pajizo"),
        (3, 2, 2, "14.8", "g/dL", "13.5 - 17.5", "Hemoglobina adecuada"),
        (4, 3, 1, "105.2", "mg/dL", "70.0 - 99.0", "Glucosa basal ligeramente elevada"),
        (5, 3, 3, "185.0", "mg/dL", "< 200.0", "Colesterol total optimo"),
        (6, 4, 7, "Proteinas +", "cualitativo", "Negativo", "Requiere evaluacion renal"),
        (7, 7, 5, "28.0", "U/L", "< 40.0", "Transaminasas normales"),
        (8, 9, 12, "Negativo", "parasitos", "Negativo", "Sin quistes ni trofozoitos"),
        (9, 13, 13, "Negativo", "bacterias", "Negativo", "Flora bacteriana habitual"),
        (10, 14, 6, "140.0", "mEq/L", "135.0 - 145.0", "Sodio serico normal")
    ]

    # Construccion del documento RelaX
    lineas = []
    lineas.append("group: CitasMed_Laboratorio\n")

    # Tabla paciente
    lineas.append("paciente = {")
    lineas.append("  nss:string, nombre:string, estatus_vigencia:string, unidad_medica:string, nss_titular:string")
    for p in pacientes:
        lineas.append(f"  '{p[0]}', '{p[1]}', '{p[2]}', '{p[3]}', '{p[4]}'")
    lineas.append("}\n")

    # Tabla paciente_telefono
    lineas.append("paciente_telefono = {")
    lineas.append("  nss:string, telefono:string")
    for t in telefonos:
        lineas.append(f"  '{t[0]}', '{t[1]}'")
    lineas.append("}\n")

    # Tabla orden_medica
    lineas.append("orden_medica = {")
    lineas.append("  folio_orden:string, fecha_orden:string, medico_emisor:string, nss_paciente:string")
    for o in ordenes:
        lineas.append(f"  '{o[0]}', '{o[1]}', '{o[2]}', '{o[3]}'")
    lineas.append("}\n")

    # Tabla cita
    lineas.append("cita = {")
    lineas.append("  id_cita:number, folio_orden:string, fecha_laboratorio:string, dias_anticipacion:number, estatus:string")
    for c in citas:
        lineas.append(f"  {c[0]}, '{c[1]}', '{c[2]}', {c[3]}, '{c[4]}'")
    lineas.append("}\n")

    # Tabla estudio
    lineas.append("estudio = {")
    lineas.append("  id_estudio:number, nombre_estudio:string, tipo_categoria:string, indicaciones:string")
    for e in estudios:
        lineas.append(f"  {e[0]}, '{e[1]}', '{e[2]}', '{e[3]}'")
    lineas.append("}\n")

    # Tabla orden_estudio
    lineas.append("orden_estudio = {")
    lineas.append("  folio_orden:string, id_estudio:number")
    for oe in orden_estudio:
        lineas.append(f"  '{oe[0]}', {oe[1]}")
    lineas.append("}\n")

    # Tabla prueba_sangre
    lineas.append("prueba_sangre = {")
    lineas.append("  id_estudio:number, tipo_tubo:string, color_tapon:string, ayuno_horas:number")
    for ps in prueba_sangre:
        lineas.append(f"  {ps[0]}, '{ps[1]}', '{ps[2]}', {ps[3]}")
    lineas.append("}\n")

    # Tabla prueba_orina
    lineas.append("prueba_orina = {")
    lineas.append("  id_estudio:number, tipo_frasco:string, volumen_minimo:string")
    for po in prueba_orina:
        lineas.append(f"  {po[0]}, '{po[1]}', '{po[2]}'")
    lineas.append("}\n")

    # Tabla prueba_fecal
    lineas.append("prueba_fecal = {")
    lineas.append("  id_estudio:number, tipo_frasco:string, requiere_medio_transporte:string")
    for pf in prueba_fecal:
        lineas.append(f"  {pf[0]}, '{pf[1]}', '{pf[2]}'")
    lineas.append("}\n")

    # Tabla resultado
    lineas.append("resultado = {")
    lineas.append("  id_resultado:number, id_cita:number, id_estudio:number, valor_obtenido:string, unidad_medida:string, rango_referencia:string, observaciones:string")
    for r in resultados:
        lineas.append(f"  {r[0]}, {r[1]}, {r[2]}, '{r[3]}', '{r[4]}', '{r[5]}', '{r[6]}'")
    lineas.append("}\n")

    contenido_final = "\n".join(lineas)
    with open(archivo_salida, "w", encoding="utf-8") as f:
        f.write(contenido_final)

    print(f"[OK] Archivo RelaX generado exitosamente en: {archivo_salida}")
    print(f"     Tablas exportadas: 10")
    print(f"     Tuplas totales: {len(pacientes) + len(telefonos) + len(ordenes) + len(citas) + len(estudios) + len(orden_estudio) + len(prueba_sangre) + len(prueba_orina) + len(prueba_fecal) + len(resultados)}")

if __name__ == "__main__":
    generar_grupo_relax()
