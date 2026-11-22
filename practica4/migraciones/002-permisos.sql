-- ==============================================================================
-- Práctica 4 - Ejercicio 1.6: Roles, usuarios y principio de mínimo privilegio
-- Las contraseñas se inyectan mediante variables de psql (-v app_pass=... etc.)
-- tomadas de variables de entorno; nunca se guardan en el repositorio.
-- ==============================================================================

BEGIN;

-- 1. Creación de los 3 roles funcionales (sin login directo)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_app') THEN
        CREATE ROLE rol_app NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_consulta') THEN
        CREATE ROLE rol_consulta NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_admin_bd') THEN
        CREATE ROLE rol_admin_bd NOLOGIN;
    END IF;
END $$;

-- 2. Privilegios de rol_app: lectura y escritura solo en tablas operativas
GRANT USAGE ON SCHEMA public TO rol_app;
GRANT SELECT, INSERT, UPDATE ON
    paciente, paciente_telefono, orden_medica, cita, orden_estudio, resultado
    TO rol_app;
GRANT SELECT, INSERT ON estudio, prueba_sangre, prueba_orina, prueba_fecal TO rol_app;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO rol_app;

-- 3. Privilegios de rol_consulta: únicamente lectura
GRANT USAGE ON SCHEMA public TO rol_consulta;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO rol_consulta;

-- 4. Privilegios de rol_admin_bd: administración completa sobre la base de datos
GRANT ALL PRIVILEGES ON SCHEMA public TO rol_admin_bd;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rol_admin_bd;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_admin_bd;

COMMIT;

-- 5. Creación/actualización de usuarios de conexión (fuera de bloque DO para usar variables psql)
DROP USER IF EXISTS usr_app;
CREATE USER usr_app WITH PASSWORD :'app_pass';
GRANT rol_app TO usr_app;

DROP USER IF EXISTS usr_consulta;
CREATE USER usr_consulta WITH PASSWORD :'consulta_pass';
GRANT rol_consulta TO usr_consulta;

DROP USER IF EXISTS usr_admin;
CREATE USER usr_admin WITH PASSWORD :'admin_pass';
GRANT rol_admin_bd TO usr_admin;
