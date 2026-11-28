# Practices 6, 7 & 8: Functional Dependencies, Normalization and Relational Algebra

Run the entire system and query validation suite with a single command:

```bash
docker compose up --build
```

---

## 1. Expected Output

When executing `docker compose up --build`, the system performs the following sequence without any manual intervention:

1. **Database Service (`citasmed-p68-db`)**:
   - Launches PostgreSQL 15 on port `5433` (container port `5432`).
   - Automatically initializes the database schema (`init-db/01-esquema.sql`), creating all clinical domain tables, custom check constraints, and trigger functions.
   - Populates the database with real domain seed data (`init-db/02-datos.sql`), loading patients, telephones, medical orders, laboratory appointments, and test results.
   - Executes migration `03-normalizacion.sql` (`init-db/03-normalizacion.sql`), setting up the unnormalized intentional table `recepcion_desnormalizada` and decomposing it into 3FN/BCNF tables (`norm_paciente`, `norm_estudio`, `norm_orden_medica`, `norm_resultado`) while preserving data.
   - Passes the healthcheck verification (`pg_isready`).

2. **Automated Runner Service (`citasmed-p68-runner`)**:
   - Waits for the database to become healthy.
   - Sequentially executes all 13 relational algebra queries located in `consultas/` against live PostgreSQL.
   - For every query, prints to the console:
     - Query index and classification title.
     - Natural language clinical domain question.
     - Formal Relational Algebra mathematical expression.
     - Formatted tabular output returned by PostgreSQL.
   - Executes `relax/exportar-grupo.py` to regenerate the official RelaX group file (`relax/grupo.txt`).
   - Finishes with exit code `0`.

---

## 2. Directory Structure

```text
practica6-8/
├── compose.yaml                # Multi-container orchestration (PostgreSQL + Runner)
├── .env.example                # Sample environment variables (safe test credentials)
├── .env                        # Local active environment configuration
├── README.md                   # This documentation (English)
├── normalizacion.md            # Part 1: Functional dependencies, closures, and 3FN/BCNF proof
├── algebra.md                  # Part 2: 13 formal relational algebra queries + Sismos queries
├── almacen-y-formas-normales.md# Exercise 1.4: Dimensional warehouse analysis (Sismos OLAP)
├── init-db/                    # Container autonomous initialization SQL scripts
│   ├── 01-esquema.sql          # Base clinical schema
│   ├── 02-datos.sql            # Seed dataset insertion
│   └── 03-normalizacion.sql    # 3FN/BCNF normalization migration
├── consultas/                  # 13 standalone SQL query files
│   ├── 01-seleccion.sql
│   ├── 02-proyeccion.sql
│   ├── 03-seleccion-proyeccion.sql
│   ├── 04-union.sql
│   ├── 05-diferencia.sql
│   ├── 06-interseccion.sql
│   ├── 07-producto-cartesiano.sql
│   ├── 08-reunion-natural.sql
│   ├── 09-reunion-theta.sql
│   ├── 10-reunion-externa.sql
│   ├── 11-agregacion.sql
│   ├── 12-agrupacion.sql
│   └── 13-division.sql
├── relax/
│   ├── exportar-grupo.py       # Deterministic Python exporter to RelaX group syntax
│   └── grupo.txt               # Exported dataset (117 tuples across 10 relations)
├── runner/
│   ├── Dockerfile              # Runner Alpine image definition
│   ├── runner.sh               # Runner entrypoint script
│   └── runner.py               # Formatted execution script
└── integrantes/                # Individual contributions per team member
    ├── Ian Andrew Aguilar Garcia - 'ZoulessAG'/README.md
    ├── Kevin Edú Vega Treviño - 'ElSlowee'/README.md
    ├── Alondra Quintanar Sanchez - 'AlooXoX'/README.md
    └── Joel Sanchez Palma - 'alcatel04'/README.md
```

---

## 3. Relational Algebra Query Coverage

| # | Operator | Clinical Purpose | Demonstrated Property |
|---|---|---|---|
| **01** | Selection (σ) | Active entitlement patients | Boolean filter on atomic attribute |
| **02** | Projection (π) | Distinct medical units | Vertical filter and duplicate elimination |
| **03** | Composition (π ∘ σ) | Blood tests with ≥ 8h fasting | Predicate pushdown before projection |
| **04** | Union (∪) | All patient NSS (holders + beneficiaries) | Union compatibility across disjoint subsets |
| **05** | Difference (−) | Patients without contact phone | Set subtraction identifying orphans |
| **06** | Intersection (∩) | Tests co-prescribed in multiple orders | Attribute type compatibility and intersection |
| **07** | Cartesian (×) | Urine tests × fecal containers | Combinatorial cross product demonstration |
| **08** | Natural Join (⋈) | Patient name and issuing physician | Foreign key correspondence (unmatched discarded) |
| **09** | Theta Join (⋈_θ) | Blood tests compared by fasting hours | Inequality join condition (A > B) |
| **10** | Left Outer Join (⟕) | Complete patient list with phones | Tuple preservation with null augmentation |
| **11** | Aggregation (γ) | Appointments grouped by status | Group summary count |
| **12** | Aggregation (γ) | Total tests prescribed per doctor | Multi-table join aggregation |
| **13** | Division (÷) | Orders prescribing ALL urine tests | Universal quantification (∀) |

---

## 4. Test Credentials and Configuration

Test credentials are automatically loaded from `.env` (or defaulted as specified in `.env.example`). No real secrets or production credentials are used:

* **PostgreSQL Host:** `db` (inside Docker network) / `localhost` (from host machine)
* **PostgreSQL Port:** `5432` (internal) / `5433` (host mapping)
* **Database Name:** `citas_medicas_p4`
* **User:** `admin_lab`
* **Password:** `laboratorio_secret_pass`

---

## 5. Verification and Clean-Machine Execution Block

* **Verification Date:** 2026-11-28
* **Verified By (Peer Reviewer):** Kevin Edú Vega Treviño (`ElSlowee`) / Ian Andrew Aguilar Garcia (`ZoulessAG`)
* **Target Git Branch:** `practica6-8`
* **Target Commit:** *(See git log for final commit hash)*
* **Verification Result:** PASSED. All 13 SQL queries executed without error, returning identical tuples to the relational algebra specifications; RelaX group syntax loaded and parsed without warnings in `dbis-uibk.github.io/relax`.

---

## 6. Generative AI Tool Declaration

In compliance with official course guidelines, generative AI tools (Google DeepMind Antigravity / Gemini 2.5) were utilized as assistive technology for:
- Formatting relational algebra LaTeX math symbols and ASCII syntactic parse trees.
- Validating formal mathematical proofs of attribute closures ($X^+$) and canonical covers ($F_c$).
- Structuring multi-stage Docker Compose orchestration and runner automation scripts.

All domain modeling rules, functional dependency derivations, SQL schema constraints, and business logic originate directly from the team's engineering design for the *CitasMed* clinical laboratory system.