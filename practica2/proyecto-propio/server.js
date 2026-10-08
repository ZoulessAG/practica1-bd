const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de la conexión a PostgreSQL (Docker)
const pool = new Pool({
    user: 'admin_lab',
    host: 'localhost',
    database: 'laboratorio_db',
    password: 'password123',
    port: 5433,
});

// Middlewares
app.use(express.json());
// Servir la carpeta landing como directorio estático principal
app.use(express.static(path.join(__dirname, 'landing')));

// Ruta Raíz: Sirve el archivo index.html dentro de landing/
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'landing', 'index.html'));
});

// GET: Consultar expediente y orden médica de un paciente por su NSS (Para la búsqueda del Portal Paciente)
app.get('/api/pacientes/:nss', async (req, res) => {
    const { nss } = req.params;
    try {
        const query = `
            SELECT 
                p.nss, 
                p.nombre, 
                p.esta_vigente, 
                p.unidad_medica, 
                p.nucleo_familiar, 
                p.telefono,
                o.id_orden,
                o.fecha_cita_doctor
            FROM Paciente p
            LEFT JOIN OrdenMedica o ON p.nss = o.nss_paciente
            WHERE p.nss = $1;
        `;
        const result = await pool.query(query, [nss]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Paciente no encontrado' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error("Error al buscar paciente:", err);
        res.status(500).json({ error: 'Error en el servidor' });
    }
});

// GET: Consultar citas reales desde PostgreSQL (Para el Panel de Administración)
app.get('/api/citas', async (req, res) => {
    try {
        const query = `
            SELECT
                c.id_cita,
                p.nss,
                p.nombre,
                c.fecha_programada,
                o.fecha_cita_doctor,
                c.asistio,
                EXTRACT(DAY FROM (o.fecha_cita_doctor::timestamp - c.fecha_programada::timestamp))::INTEGER AS dias_anticipacion
            FROM CitaLaboratorio c
                     JOIN Paciente p ON c.nss_paciente = p.nss
                     JOIN OrdenMedica o ON c.id_orden = o.id_orden
            ORDER BY c.id_cita ASC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error("Error al consultar PostgreSQL:", err);
        res.status(500).json({ error: 'Error en el servidor de base de datos' });
    }
});

// POST: Registrar una nueva cita de laboratorio asociada a la orden médica del paciente
app.post('/api/citas', async (req, res) => {
    const { nss, fecha_programada } = req.body;
    try {
        // Buscar la orden médica asociada al paciente
        const ordenQuery = await pool.query('SELECT id_orden FROM OrdenMedica WHERE nss_paciente = $1 LIMIT 1', [nss]);
        if (ordenQuery.rows.length === 0) {
            return res.status(404).json({ error: 'No se encontró una orden médica para este NSS' });
        }
        const idOrden = ordenQuery.rows[0].id_orden;

        // Insertar la cita en CitaLaboratorio
        const insertQuery = `
            INSERT INTO CitaLaboratorio (nss_paciente, id_orden, fecha_programada, asistio)
            VALUES ($1, $2, $3, false)
                RETURNING id_cita;
        `;
        const result = await pool.query(insertQuery, [nss, idOrden, fecha_programada]);
        res.status(201).json({ message: 'Cita registrada correctamente', id_cita: result.rows[0].id_cita });
    } catch (err) {
        console.error("Error al registrar la cita:", err);
        res.status(500).json({ error: 'Error al registrar la cita' });
    }
});

// DELETE: Eliminar una cita por id_cita
app.delete('/api/citas/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // Eliminar dependencias primero en cita_estudio
        await pool.query('DELETE FROM cita_estudio WHERE id_cita = $1', [id]);
        // Eliminar el registro principal en citalaboratorio
        await pool.query('DELETE FROM citalaboratorio WHERE id_cita = $1', [id]);
        res.json({ message: 'Cita eliminada correctamente' });
    } catch (err) {
        console.error("Error al eliminar cita:", err);
        res.status(500).json({ error: 'Error al eliminar registro' });
    }
});

// Iniciar Servidor
app.listen(PORT, () => {
    console.log(`Servidor local corriendo en http://localhost:${PORT}`);
});