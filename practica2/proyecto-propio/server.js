const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de conexión a PostgreSQL
// Por defecto se conecta a la base normalizada citas_medicas_p4 en el contenedor Docker
const pool = new Pool({
    user: process.env.DB_USER || 'admin_lab',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'citas_medicas_p4',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5433,
});

app.use(express.json());

// Servir la raíz del proyecto para acceder a index.html y assets
app.use(express.static(path.join(__dirname, '../../')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../../index.html'));
});

// ------------------------------------------------------------------------------
// 1. ESTADO DEL SISTEMA Y TELEMETRÍA
// ------------------------------------------------------------------------------
app.get('/api/status', async (req, res) => {
    const start = Date.now();
    try {
        const result = await pool.query('SELECT NOW() AS server_time, current_database() AS db_name, version() AS pg_version');
        const latencyMs = Date.now() - start;
        res.json({
            status: 'online',
            db_connected: true,
            database: result.rows[0].db_name,
            timestamp: result.rows[0].server_time,
            latency_ms: latencyMs,
            postgres_version: result.rows[0].pg_version,
            port: process.env.DB_PORT || 5433,
            host: process.env.DB_HOST || 'localhost'
        });
    } catch (err) {
        console.error("Error verificando estado de BD:", err.message);
        res.status(500).json({
            status: 'degraded',
            db_connected: false,
            error: err.message,
            latency_ms: Date.now() - start
        });
    }
});

// ------------------------------------------------------------------------------
// 2. ESTADÍSTICAS GLOBALES (KPIs)
// ------------------------------------------------------------------------------
app.get('/api/stats', async (req, res) => {
    try {
        const query = `
            SELECT 
                (SELECT COUNT(*) FROM paciente) AS total_pacientes,
                (SELECT COUNT(*) FROM paciente WHERE estatus_vigencia = TRUE) AS pacientes_vigentes,
                (SELECT COUNT(*) FROM cita) AS total_citas,
                (SELECT COUNT(*) FROM cita WHERE estatus_asistencia = 'PROGRAMADA') AS citas_programadas,
                (SELECT COUNT(*) FROM cita WHERE estatus_asistencia = 'CONFIRMADA') AS citas_confirmadas,
                (SELECT COUNT(*) FROM cita WHERE estatus_asistencia = 'ASISTIO') AS citas_asistidas,
                (SELECT COUNT(*) FROM estudio) AS total_estudios,
                (SELECT COUNT(*) FROM resultado) AS total_resultados,
                (SELECT COUNT(*) FROM orden_medica) AS total_ordenes;
        `;
        const result = await pool.query(query);
        res.json(result.rows[0]);
    } catch (err) {
        console.error("Error obteniendo estadísticas:", err.message);
        res.status(500).json({ error: 'Error al consultar estadísticas', detalle: err.message });
    }
});

// ------------------------------------------------------------------------------
// 3. PACIENTES
// ------------------------------------------------------------------------------
app.get('/api/pacientes', async (req, res) => {
    try {
        const query = `
            SELECT 
                p.nss, 
                p.nombre, 
                p.estatus_vigencia, 
                p.unidad_medica_adscripcion, 
                p.nss_titular,
                pt.nombre AS nombre_titular,
                COALESCE(
                    ARRAY_AGG(DISTINCT tel.telefono::text) FILTER (WHERE tel.telefono IS NOT NULL),
                    '{}'
                ) AS telefonos,
                COUNT(DISTINCT o.folio_orden) AS total_ordenes
            FROM paciente p
            LEFT JOIN paciente pt ON p.nss_titular = pt.nss
            LEFT JOIN paciente_telefono tel ON p.nss = tel.nss
            LEFT JOIN orden_medica o ON p.nss = o.nss_paciente
            GROUP BY p.nss, p.nombre, p.estatus_vigencia, p.unidad_medica_adscripcion, p.nss_titular, pt.nombre
            ORDER BY p.nss ASC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error("Error consultando pacientes:", err.message);
        res.status(500).json({ error: 'Error en la base de datos', detalle: err.message });
    }
});

app.get('/api/pacientes/:nss', async (req, res) => {
    try {
        const { nss } = req.params;
        const pacienteRes = await pool.query(`
            SELECT 
                p.nss, p.nombre, p.estatus_vigencia, p.unidad_medica_adscripcion, p.nss_titular,
                pt.nombre AS nombre_titular,
                COALESCE(ARRAY_AGG(DISTINCT tel.telefono::text) FILTER (WHERE tel.telefono IS NOT NULL), '{}') AS telefonos
            FROM paciente p
            LEFT JOIN paciente pt ON p.nss_titular = pt.nss
            LEFT JOIN paciente_telefono tel ON p.nss = tel.nss
            WHERE p.nss = $1
            GROUP BY p.nss, p.nombre, p.estatus_vigencia, p.unidad_medica_adscripcion, p.nss_titular, pt.nombre;
        `, [nss]);

        if (pacienteRes.rows.length === 0) {
            return res.status(404).json({ error: 'Paciente no encontrado' });
        }

        const ordenesRes = await pool.query(`
            SELECT o.folio_orden, o.fecha_cita_medico, o.medico_emisor, c.id_cita, c.fecha_hora_laboratorio, c.estatus_asistencia
            FROM orden_medica o
            LEFT JOIN cita c ON o.folio_orden = c.folio_orden
            WHERE o.nss_paciente = $1
            ORDER BY o.fecha_cita_medico DESC;
        `, [nss]);

        res.json({
            ...pacienteRes.rows[0],
            ordenes: ordenesRes.rows
        });
    } catch (err) {
        console.error("Error consultando paciente:", err.message);
        res.status(500).json({ error: 'Error consultando paciente', detalle: err.message });
    }
});

app.post('/api/pacientes', async (req, res) => {
    const client = await pool.connect();
    try {
        const { nss, nombre, estatus_vigencia, unidad_medica_adscripcion, nss_titular, telefono } = req.body;

        if (!nss || !/^[0-9]{10,11}$/.test(String(nss).trim())) {
            return res.status(400).json({ error: 'El NSS debe ser numérico de 10 u 11 dígitos (dom_nss).' });
        }
        if (!nombre || String(nombre).trim().length < 3) {
            return res.status(400).json({ error: 'El nombre debe tener al menos 3 caracteres.' });
        }
        if (!unidad_medica_adscripcion || String(unidad_medica_adscripcion).trim().length < 4) {
            return res.status(400).json({ error: 'La unidad médica debe tener al menos 4 caracteres.' });
        }

        const cleanNss = String(nss).trim();
        const cleanNombre = String(nombre).trim();
        const cleanUnidad = String(unidad_medica_adscripcion).trim();
        const cleanTitular = nss_titular && String(nss_titular).trim() !== '' ? String(nss_titular).trim() : null;
        const vigencia = estatus_vigencia !== false && estatus_vigencia !== 'false';

        await client.query('BEGIN');

        const insertPacienteQuery = `
            INSERT INTO paciente (nss, nombre, estatus_vigencia, unidad_medica_adscripcion, nss_titular)
            VALUES ($1, $2, $3, $4, $5)
            ON CONFLICT (nss) DO UPDATE SET
                nombre = EXCLUDED.nombre,
                estatus_vigencia = EXCLUDED.estatus_vigencia,
                unidad_medica_adscripcion = EXCLUDED.unidad_medica_adscripcion,
                nss_titular = EXCLUDED.nss_titular
            RETURNING *;
        `;
        const pacienteRes = await client.query(insertPacienteQuery, [cleanNss, cleanNombre, vigencia, cleanUnidad, cleanTitular]);

        if (telefono && String(telefono).trim() !== '') {
            const cleanTel = String(telefono).trim();
            if (/^[0-9]{8,15}$/.test(cleanTel)) {
                await client.query(`
                    INSERT INTO paciente_telefono (nss, telefono)
                    VALUES ($1, $2)
                    ON CONFLICT (nss, telefono) DO NOTHING;
                `, [cleanNss, cleanTel]);
            }
        }

        await client.query('COMMIT');
        res.status(201).json(pacienteRes.rows[0]);
    } catch (err) {
        await client.query('ROLLBACK');
        console.error("Error registrando paciente:", err.message);
        res.status(400).json({ error: 'Error al registrar paciente', detalle: err.message });
    } finally {
        client.release();
    }
});

// Eliminar paciente por NSS (Demostración de Integridad Referencial Práctica 5)
app.delete('/api/pacientes/:nss', async (req, res) => {
    const { nss } = req.params;
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        
        const check = await client.query('SELECT nombre FROM paciente WHERE nss = $1', [nss]);
        if (check.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ error: 'Paciente no encontrado.' });
        }

        // Si tiene órdenes médicas o citas, PostgreSQL activará ON DELETE RESTRICT
        // Si solo tiene teléfonos, se eliminarán en cascada por ON DELETE CASCADE
        await client.query('DELETE FROM paciente WHERE nss = $1', [nss]);
        await client.query('COMMIT');
        
        res.json({ 
            success: true, 
            message: `Paciente con NSS ${nss} (${check.rows[0].nombre}) eliminado exitosamente de la base de datos.` 
        });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error("Error al eliminar paciente:", err.message);
        if (err.code === '23503') { // foreign_key_violation
            return res.status(400).json({ 
                error: 'Restricción de Integridad Referencial (ON DELETE RESTRICT)', 
                detalle: 'No se puede eliminar al paciente porque tiene órdenes médicas o citas activas, o es titular de otros derechohabientes.' 
            });
        }
        res.status(500).json({ error: 'Error interno al eliminar paciente', detalle: err.message });
    } finally {
        client.release();
    }
});

// ------------------------------------------------------------------------------
// 4. CITAS DE LABORATORIO Y ÓRDENES MÉDICAS
// ------------------------------------------------------------------------------
app.get('/api/citas', async (req, res) => {
    try {
        const query = `
            SELECT 
                c.id_cita,
                c.folio_orden,
                c.fecha_hora_agendamiento,
                c.fecha_hora_laboratorio,
                c.estatus_asistencia,
                o.fecha_cita_medico,
                o.medico_emisor,
                o.nss_paciente,
                p.nombre AS nombre_paciente,
                p.unidad_medica_adscripcion,
                (o.fecha_cita_medico - (c.fecha_hora_laboratorio AT TIME ZONE 'America/Mexico_City')::DATE) AS dias_anticipacion,
                COALESCE(STRING_AGG(DISTINCT e.nombre_estudio, ', '), 'Sin estudios asignados') AS estudios,
                COUNT(DISTINCT r.id_resultado) AS resultados_emitidos
            FROM cita c
            JOIN orden_medica o ON c.folio_orden = o.folio_orden
            JOIN paciente p ON o.nss_paciente = p.nss
            LEFT JOIN orden_estudio oe ON o.folio_orden = oe.folio_orden
            LEFT JOIN estudio e ON oe.id_estudio = e.id_estudio
            LEFT JOIN resultado r ON c.id_cita = r.id_cita
            GROUP BY 
                c.id_cita, c.folio_orden, c.fecha_hora_agendamiento, c.fecha_hora_laboratorio,
                c.estatus_asistencia, o.fecha_cita_medico, o.medico_emisor, o.nss_paciente,
                p.nombre, p.unidad_medica_adscripcion
            ORDER BY c.fecha_hora_laboratorio DESC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error("Error consultando citas:", err.message);
        res.status(500).json({ error: 'Error en la base de datos', detalle: err.message });
    }
});

app.post('/api/citas', async (req, res) => {
    const client = await pool.connect();
    try {
        const {
            folio_orden,
            nss_paciente,
            fecha_cita_medico,
            medico_emisor,
            fecha_hora_laboratorio,
            estatus_asistencia,
            id_estudios // Array de IDs de estudios o ID único
        } = req.body;

        if (!folio_orden || !/^ORD-[0-9]{4}-[0-9]{3,6}$/.test(String(folio_orden).trim())) {
            return res.status(400).json({ error: 'Folio inválido. Debe seguir el formato ORD-AAAA-NNNN.' });
        }
        if (!nss_paciente || !/^[0-9]{10,11}$/.test(String(nss_paciente).trim())) {
            return res.status(400).json({ error: 'NSS de paciente inválido (10 a 11 dígitos).' });
        }
        if (!fecha_cita_medico || !fecha_hora_laboratorio) {
            return res.status(400).json({ error: 'Las fechas de consulta médica y laboratorio son obligatorias.' });
        }

        await client.query('BEGIN');

        // 1. Asegurar la orden médica
        const medico = medico_emisor && String(medico_emisor).trim().length >= 5 
            ? String(medico_emisor).trim() 
            : 'Dr. Médico Adscrito (Ced. 0000000)';

        await client.query(`
            INSERT INTO orden_medica (folio_orden, fecha_cita_medico, medico_emisor, nss_paciente)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT (folio_orden) DO UPDATE SET
                fecha_cita_medico = EXCLUDED.fecha_cita_medico,
                medico_emisor = EXCLUDED.medico_emisor,
                nss_paciente = EXCLUDED.nss_paciente;
        `, [folio_orden, fecha_cita_medico, medico, nss_paciente]);

        // 2. Insertar cita (activará trigger fn_validar_anticipacion_cita y check chk_fechas_coherentes)
        const estatus = estatus_asistencia || 'PROGRAMADA';
        const citaRes = await client.query(`
            INSERT INTO cita (fecha_hora_laboratorio, estatus_asistencia, folio_orden)
            VALUES ($1, $2, $3)
            RETURNING *;
        `, [fecha_hora_laboratorio, estatus, folio_orden]);

        // 3. Vincular estudios a la orden si se indicaron
        if (id_estudios) {
            const estudiosArr = Array.isArray(id_estudios) ? id_estudios : [id_estudios];
            for (const eid of estudiosArr) {
                if (!isNaN(parseInt(eid, 10))) {
                    await client.query(`
                        INSERT INTO orden_estudio (folio_orden, id_estudio)
                        VALUES ($1, $2)
                        ON CONFLICT (folio_orden, id_estudio) DO NOTHING;
                    `, [folio_orden, parseInt(eid, 10)]);
                }
            }
        }

        await client.query('COMMIT');
        res.status(201).json(citaRes.rows[0]);
    } catch (err) {
        await client.query('ROLLBACK');
        console.error("Error agendando cita:", err.message);
        // Retornar mensaje limpio del trigger o restricción de PostgreSQL
        res.status(400).json({ error: 'Error al agendar cita médica', detalle: err.message });
    } finally {
        client.release();
    }
});

app.patch('/api/citas/:id/estatus', async (req, res) => {
    try {
        const { id } = req.params;
        const { estatus_asistencia } = req.body;
        const validos = ['PROGRAMADA', 'CONFIRMADA', 'ASISTIO', 'CANCELADA', 'NO_ASISTIO'];

        if (!validos.includes(estatus_asistencia)) {
            return res.status(400).json({ error: `Estatus inválido. Valores permitidos: ${validos.join(', ')}` });
        }

        const result = await pool.query(`
            UPDATE cita
            SET estatus_asistencia = $1
            WHERE id_cita = $2
            RETURNING *;
        `, [estatus_asistencia, parseInt(id, 10)]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Cita no encontrada.' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error("Error actualizando estatus de cita:", err.message);
        res.status(400).json({ error: 'Error al actualizar cita', detalle: err.message });
    }
});

app.delete('/api/citas/:id', async (req, res) => {
    const client = await pool.connect();
    try {
        const { id } = req.params;
        const idInt = parseInt(id, 10);
        if (isNaN(idInt)) {
            return res.status(400).json({ error: 'ID de cita numérico obligatorio.' });
        }

        await client.query('BEGIN');
        await client.query('DELETE FROM resultado WHERE id_cita = $1', [idInt]);
        const result = await client.query('DELETE FROM cita WHERE id_cita = $1', [idInt]);
        await client.query('COMMIT');

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Cita no encontrada.' });
        }

        res.json({ mensaje: 'Cita eliminada de la base de datos.', id_cita: idInt });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error("Error eliminando cita:", err.message);
        res.status(500).json({ error: 'Error eliminando cita', detalle: err.message });
    } finally {
        client.release();
    }
});

// ------------------------------------------------------------------------------
// 5. CATÁLOGO DE ESTUDIOS
// ------------------------------------------------------------------------------
app.get('/api/estudios', async (req, res) => {
    try {
        const query = `
            SELECT 
                e.id_estudio,
                e.nombre_estudio,
                e.indicaciones_previas,
                CASE 
                    WHEN ps.id_estudio IS NOT NULL THEN 'Sangre'
                    WHEN po.id_estudio IS NOT NULL THEN 'Orina'
                    WHEN pf.id_estudio IS NOT NULL THEN 'Fecal'
                    ELSE 'General'
                END AS tipo_categoria,
                ps.tipo_tubo,
                ps.color_tapon,
                ps.ayuno_horas,
                po.tipo_frasco AS frasco_orina,
                po.volumen_minimo,
                pf.tipo_frasco AS frasco_fecal,
                pf.requiere_medio_transporte
            FROM estudio e
            LEFT JOIN prueba_sangre ps ON e.id_estudio = ps.id_estudio
            LEFT JOIN prueba_orina po ON e.id_estudio = po.id_estudio
            LEFT JOIN prueba_fecal pf ON e.id_estudio = pf.id_estudio
            ORDER BY e.id_estudio ASC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error("Error consultando estudios:", err.message);
        res.status(500).json({ error: 'Error consultando estudios', detalle: err.message });
    }
});

// ------------------------------------------------------------------------------
// 6. RESULTADOS CLÍNICOS
// ------------------------------------------------------------------------------
app.get('/api/resultados', async (req, res) => {
    try {
        const query = `
            SELECT 
                r.id_resultado,
                r.valor_obtenido,
                r.unidad_medida,
                r.rango_referencia,
                r.fecha_hora_emision,
                r.observaciones,
                r.id_cita,
                r.id_estudio,
                e.nombre_estudio,
                p.nss,
                p.nombre AS nombre_paciente
            FROM resultado r
            JOIN estudio e ON r.id_estudio = e.id_estudio
            JOIN cita c ON r.id_cita = c.id_cita
            JOIN orden_medica o ON c.folio_orden = o.folio_orden
            JOIN paciente p ON o.nss_paciente = p.nss
            ORDER BY r.fecha_hora_emision DESC
            LIMIT 100;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error("Error consultando resultados:", err.message);
        res.status(500).json({ error: 'Error consultando resultados', detalle: err.message });
    }
});

app.post('/api/resultados', async (req, res) => {
    try {
        const { id_cita, id_estudio, valor_obtenido, unidad_medida, rango_referencia, observaciones } = req.body;

        if (!id_cita || !id_estudio || !valor_obtenido) {
            return res.status(400).json({ error: 'ID de cita, ID de estudio y valor obtenido son obligatorios.' });
        }

        const query = `
            INSERT INTO resultado (valor_obtenido, unidad_medida, rango_referencia, observaciones, id_cita, id_estudio)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *;
        `;
        const result = await pool.query(query, [
            String(valor_obtenido).trim(),
            unidad_medida ? String(unidad_medida).trim() : null,
            rango_referencia ? String(rango_referencia).trim() : null,
            observaciones ? String(observaciones).trim() : 'Validado en laboratorio.',
            parseInt(id_cita, 10),
            parseInt(id_estudio, 10)
        ]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error("Error registrando resultado:", err.message);
        res.status(400).json({ error: 'Error al registrar resultado', detalle: err.message });
    }
});

// ------------------------------------------------------------------------------
// 7. CONSOLA SQL INTERACTIVA (Solo lectura SELECT)
// ------------------------------------------------------------------------------
app.post('/api/query', async (req, res) => {
    const start = Date.now();
    try {
        const { sql } = req.body;
        if (!sql || typeof sql !== 'string') {
            return res.status(400).json({ error: 'Se requiere una sentencia SQL válida.' });
        }

        const trimmed = sql.trim().replace(/;+$/, '');
        if (
            trimmed.includes(';') ||
            !/^SELECT\b/i.test(trimmed) ||
            /\b(DROP|DELETE|UPDATE|INSERT|ALTER|TRUNCATE|CREATE|GRANT|REVOKE)\b/i.test(trimmed)
        ) {
            return res.status(403).json({
                error: 'Por seguridad en la consola pública solo se permiten consultas SELECT de solo lectura.'
            });
        }

        const result = await pool.query(trimmed);
        const execTime = Date.now() - start;
        res.json({
            fields: result.fields ? result.fields.map(f => f.name) : [],
            rows: result.rows,
            rowCount: result.rowCount,
            execution_time_ms: execTime
        });
    } catch (err) {
        console.error("Error en consulta SQL interactiva:", err.message);
        res.status(400).json({ error: err.message });
    }
});

// ------------------------------------------------------------------------------
// 8. DUMP COMPLETO PARA DESCARGA
// ------------------------------------------------------------------------------
app.get('/api/db-dump', async (req, res) => {
    try {
        const [p, o, c, e, r] = await Promise.all([
            pool.query('SELECT * FROM paciente ORDER BY nss'),
            pool.query('SELECT * FROM orden_medica ORDER BY folio_orden'),
            pool.query('SELECT * FROM cita ORDER BY id_cita'),
            pool.query('SELECT * FROM estudio ORDER BY id_estudio'),
            pool.query('SELECT * FROM resultado ORDER BY id_resultado')
        ]);

        res.json({
            database: 'citas_medicas_p4',
            export_timestamp: new Date().toISOString(),
            pacientes: p.rows,
            ordenes: o.rows,
            citas: c.rows,
            estudios: e.rows,
            resultados: r.rows
        });
    } catch (err) {
        console.error("Error en dump:", err.message);
        res.status(500).json({ error: 'Error exportando base de datos', detalle: err.message });
    }
});

app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`  SISTEMA CLÍNICO - OBSERVATORIO EER / RELACIONAL   `);
    console.log(`====================================================`);
    console.log(`  Servidor HTTP:   http://localhost:${PORT}`);
    console.log(`  PostgreSQL Host: ${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 5433}`);
    console.log(`  Base de Datos:   ${process.env.DB_NAME || 'citas_medicas_p4'}`);
    console.log(`  Usuario:         ${process.env.DB_USER || 'admin_lab'}`);
    console.log(`====================================================`);
});
