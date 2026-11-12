$ErrorActionPreference = "Stop"

# Variables de entorno requeridas (sin credenciales fijas en el repositorio):
#   PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD
foreach ($v in @("PGHOST", "PGDATABASE", "PGUSER", "PGPASSWORD")) {
    if (-not (Test-Path "Env:$v") -or [string]::IsNullOrWhiteSpace((Get-Item "Env:$v").Value)) {
        throw "Falta la variable de entorno requerida: $v"
    }
}
if (-not $env:PGPORT) { $env:PGPORT = "5433" }

$p4Dir = Split-Path -Parent $PSScriptRoot
Push-Location $p4Dir
try {
    if (Get-Command psql -ErrorAction SilentlyContinue) {
        psql -h $env:PGHOST -p $env:PGPORT -U $env:PGUSER -d $env:PGDATABASE -v ON_ERROR_STOP=1 -f "poblar/cargar.sql"
    } else {
        # Fallback vía contenedor Docker si psql no está en Windows
        $container = if ($env:PGCONTAINER) { $env:PGCONTAINER } else { "postgres_laboratorio" }
        docker cp "$p4Dir\datos" "${container}:/tmp/datos" | Out-Null
        docker cp "$p4Dir\poblar\cargar.sql" "${container}:/tmp/cargar.sql" | Out-Null
        docker exec -e PGPASSWORD="$env:PGPASSWORD" $container sh -c "cd /tmp && psql -U $env:PGUSER -d $env:PGDATABASE -v ON_ERROR_STOP=1 -f cargar.sql"
    }
} finally {
    Pop-Location
}
