const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

const pool = new Pool({
    user: process.env.DB_USER || 'admin_lab',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'laboratorio_db',
    password: process.env.DB_PASSWORD || 'password123',
    port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
});

app.use(express.json());

app.use(express.static(path.join(__dirname, '../../')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../../index.html'));
});

app.get('/api/status', async (req, res) => {
    try {
        const result = await pool.query('SELECT NOW() AS server_time, version() AS pg_version');
        res.json({
            status: 'online',
            db_connected: true,
            database: 'laboratorio_db',
            timestamp: result.rows[0].server_time,
            postgres_version: result.rows[0].pg_version
        });
    } catch (err) {
        console.error("Error verificando estado de BD:", err.message);
        res.status(500).json({
            status: 'degraded',
            db_connected: false,
            error: err.message
        });
    }
});

app.get('/api/pacientes', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Paciente ORDER BY nss ASC');
        res.json(result.rows);
    } catch (err) {
        console.error("Error consultando pacientes:", err.message);
        res.status(500).json({ error: 'Error en la base de datos', detalle: err.message });
    }
});

app.get('/api/pacientes/:nss', async (req, res) => {
    try {
        const { nss } = req.params;
        const result = await pool.query(`
            SELECT 
                p.nss, 
                p.nombre, 
                p.esta_vigente, 
                p.unidad_medica, 
                p.telefono,
                o.id_orden,
                o.fecha_cita_doctor
            FROM Paciente p
            LEFT JOIN OrdenMedica o ON p.nss = o.nss_paciente
            WHERE p.nss = $1
            ORDER BY o.fecha_cita_doctor DESC NULLS LAST
            LIMIT 1
        `, [nss]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Paciente no encontrado en la base de datos' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        console.error("Error consultando paciente:", err.message);
        res.status(500).json({ error: 'Error en el servidor de base de datos', detalle: err.message });
    }
});

app.post('/api/pacientes', async (req, res) => {
    try {
        const nssRaw = req.body.nss || req.body.nss_paciente;
        if (!nssRaw || String(nssRaw).trim() === '') {
            return res.status(400).json({ error: "El campo 'nss' es obligatorio y no puede ser nulo o vacío." });
        }

        const nss = String(nssRaw).trim();
        const { nombre, esta_vigente, estatus_vigencia, unidad_medica, unidad_medica_adscripcion, nucleo_familiar, nss_titular, telefono } = req.body;
        
        const vigenciaValor = (esta_vigente !== undefined) ? esta_vigente : estatus_vigencia;
        const esVigente = vigenciaValor !== false && vigenciaValor !== 'NO VIGENTE' && vigenciaValor !== 'false';
        const unidad = unidad_medica || unidad_medica_adscripcion || 'UMF 20';
        const nucleo = nucleo_familiar || nss_titular || null;

        const result = await pool.query(`
            INSERT INTO Paciente (nss, nombre, esta_vigente, unidad_medica, nucleo_familiar, telefono)
            VALUES ($1, $2, $3, $4, $5, $6)
            ON CONFLICT (nss) DO UPDATE SET
                nombre = EXCLUDED.nombre,
                esta_vigente = EXCLUDED.esta_vigente,
                unidad_medica = EXCLUDED.unidad_medica,
                nucleo_familiar = EXCLUDED.nucleo_familiar,
                telefono = EXCLUDED.telefono
            RETURNING *
        `, [
            nss, 
            nombre ? String(nombre).trim() : 'Paciente Sin Nombre', 
            esVigente, 
            String(unidad).trim(), 
            nucleo ? String(nucleo).trim() : null, 
            telefono ? String(telefono).trim() : null
        ]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error("Error registrando paciente:", err.message);
        res.status(500).json({ error: 'Error al registrar paciente en base de datos', detalle: err.message });
    }
});

app.get('/api/citas', async (req, res) => {
    try {
        const query = `
            SELECT 
                c.id_cita,
                p.nss,
                p.nombre,
                c.fecha_programada,
                o.fecha_cita_doctor,
                COALESCE(STRING_AGG(e.nombre, ', '), 'Sin estudios asignados') AS estudios,
                c.asistio,
                CASE WHEN c.asistio THEN 'ASISTIÓ' ELSE 'PENDIENTE' END AS estatus_asistencia
            FROM CitaLaboratorio c
            JOIN Paciente p ON c.nss_paciente = p.nss
            LEFT JOIN OrdenMedica o ON c.id_orden = o.id_orden
            LEFT JOIN Cita_Estudio ce ON c.id_cita = ce.id_cita
            LEFT JOIN Estudio e ON ce.id_estudio = e.id_estudio
            GROUP BY c.id_cita, p.nss, p.nombre, c.fecha_programada, o.fecha_cita_doctor, c.asistio
            ORDER BY c.fecha_programada DESC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error("Error consultando citas:", err.message);
        res.status(500).json({ error: 'Error en la base de datos', detalle: err.message });
    }
});

app.post('/api/citas', async (req, res) => {
    try {
        const { id_cita, nss_paciente, nss, id_orden, folio_orden, fecha_programada, fecha_hora_laboratorio, asistio, estatus_asistencia } = req.body;
        
        let targetNss = nss_paciente || nss;
        const targetOrden = id_orden || folio_orden;
        const targetFecha = fecha_programada || fecha_hora_laboratorio || new Date();
        const asistioBool = asistio === true || asistio === 'ASISTIÓ' || estatus_asistencia === 'ASISTIÓ';

        if (!targetNss && targetOrden && !isNaN(parseInt(targetOrden, 10))) {
            const ordenRes = await pool.query('SELECT nss_paciente FROM OrdenMedica WHERE id_orden = $1', [parseInt(targetOrden, 10)]);
            if (ordenRes.rows.length > 0) {
                targetNss = ordenRes.rows[0].nss_paciente;
            }
        }

        if (!targetNss || String(targetNss).trim() === '') {
            return res.status(400).json({ error: "El NSS del paciente es obligatorio para agendar una cita." });
        }

        if (!targetOrden || isNaN(parseInt(targetOrden, 10))) {
            return res.status(400).json({ error: "El folio o ID de la orden médica es obligatorio y debe ser numérico." });
        }

        let query;
        let params;

        if (id_cita && !isNaN(parseInt(id_cita, 10))) {
            query = `
                INSERT INTO CitaLaboratorio (id_cita, nss_paciente, id_orden, fecha_programada, asistio)
                VALUES ($1, $2, $3, $4, $5)
                RETURNING *
            `;
            params = [parseInt(id_cita, 10), String(targetNss).trim(), parseInt(targetOrden, 10), targetFecha, asistioBool];
        } else {
            query = `
                INSERT INTO CitaLaboratorio (nss_paciente, id_orden, fecha_programada, asistio)
                VALUES ($1, $2, $3, $4)
                RETURNING *
            `;
            params = [String(targetNss).trim(), parseInt(targetOrden, 10), targetFecha, asistioBool];
        }

        const result = await pool.query(query, params);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error("Error al crear cita:", err.message);
        res.status(500).json({ error: 'Error al registrar cita', detalle: err.message });
    }
});

app.delete('/api/citas/:id', async (req, res) => {
    const client = await pool.connect();
    try {
        const { id } = req.params;
        const idInt = parseInt(id, 10);
        if (isNaN(idInt)) {
            return res.status(400).json({ error: 'El ID de la cita debe ser numérico' });
        }

        await client.query('BEGIN');
        await client.query('DELETE FROM Cita_Estudio WHERE id_cita = $1', [idInt]);
        await client.query('DELETE FROM resultado WHERE id_cita = $1', [idInt]);
        const result = await client.query('DELETE FROM CitaLaboratorio WHERE id_cita = $1', [idInt]);
        await client.query('COMMIT');

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Cita no encontrada en la base de datos' });
        }

        res.json({ mensaje: 'Cita eliminada correctamente de PostgreSQL', id_cita: idInt });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error("Error al eliminar cita:", err.message);
        res.status(500).json({ error: 'Error al eliminar registro', detalle: err.message });
    } finally {
        client.release();
    }
});

app.post('/api/query', async (req, res) => {
    try {
        const { sql } = req.body;
        if (!sql || typeof sql !== 'string') {
            return res.status(400).json({ error: 'Se requiere una sentencia SQL válida' });
        }

        const trimmed = sql.trim().replace(/;+$/, '');
        if (trimmed.includes(';') || !/^SELECT\b/i.test(trimmed) || /\b(DROP|DELETE|UPDATE|INSERT|ALTER|TRUNCATE|CREATE)\b/i.test(trimmed)) {
            return res.status(403).json({
                error: 'Por seguridad en la consola interactiva sólo se permiten consultas SELECT simples de solo lectura.'
            });
        }

        const result = await pool.query(trimmed);
        res.json({
            fields: result.fields ? result.fields.map(f => f.name) : [],
            rows: result.rows,
            rowCount: result.rowCount
        });
    } catch (err) {
        console.error("Error en consulta SQL interactiva:", err.message);
        res.status(400).json({ error: err.message });
    }
});

app.get('/api/db-dump', async (req, res) => {
    try {
        const pacientes = await pool.query(`
            SELECT nss, nombre, CASE WHEN esta_vigente THEN 'VIGENTE' ELSE 'NO VIGENTE' END AS estatus_vigencia, 
                   telefono, unidad_medica AS unidad_medica_adscripcion, nucleo_familiar AS nss_titular 
            FROM Paciente
        `);
        const ordenes = await pool.query(`
            SELECT id_orden::text AS folio_orden, id_medico::text AS cedula_profesional, 
                   fecha_cita_doctor::text AS fecha_de_cita_con_su_medico, nss_paciente 
            FROM OrdenMedica
        `);
        const estudios = await pool.query(`
            SELECT id_estudio::text, nombre AS nombre_de_estudio, '8 horas de ayuno' AS indicaciones_previas 
            FROM Estudio
        `);
        const citas = await pool.query(`
            SELECT id_cita::text, fecha_agendamiento::text AS fecha_hora_agendamiento, 
                   fecha_programada::text AS fecha_hora_laboratorio, 
                   CASE WHEN asistio THEN 'ASISTIÓ' ELSE 'PENDIENTE' END AS estatus_asistencia, 
                   id_orden::text AS folio_orden 
            FROM CitaLaboratorio
        `);
        const resultados = await pool.query(`
            SELECT id_resultado::text, valor_obtenido, observaciones, unidad_de_medida, 
                   fecha_hora_de_emision::text, tipo_de_prueba, id_cita::text 
            FROM resultado
        `);

        res.json({
            paciente: pacientes.rows,
            orden_medica: ordenes.rows,
            estudio: estudios.rows,
            cita: citas.rows,
            resultado: resultados.rows
        });
    } catch (err) {
        console.error("Error en dump:", err.message);
        res.status(500).json({ error: 'Error extrayendo datos', detalle: err.message });
    }
});

app.listen(PORT, () => {
    console.log(`================================================`);
    console.log(` Servidor Local Corriendo en: http://localhost:${PORT}`);
    console.log(` Conectado a PostgreSQL (Docker) en puerto: 5433`);
    console.log(` Base de datos: laboratorio_db`);
    console.log(`================================================`);
});