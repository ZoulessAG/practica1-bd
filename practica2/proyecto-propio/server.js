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

// GET: Consultar citas reales desde PostgreSQL
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