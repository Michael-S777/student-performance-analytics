# 🎓 Student Performance Analytics Pipeline

> **End-to-end data transformation pipeline** built with **dbt Core**, **DuckDB**, and **Python** — modelling student enrolments, course data, and assessment grades through a layered architecture into business-ready tables for academic reporting and at-risk student identification.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Data Model](#-data-model)
- [Getting Started](#-getting-started)
- [Running the Project](#-running-the-project)
- [Testing](#-testing)
- [CI/CD](#-cicd)
- [Key Design Decisions](#-key-design-decisions)

---

## 🔍 Overview

This project simulates a real-world analytics engineering workflow for a **university education platform**. Raw student, course, enrolment, and assessment data flows through three modelling layers:

```
Raw (seeds) → Staging → Intermediate → Marts (dim/fct)
```

The final mart tables — `dim_students` and `fct_enrolments` — are ready to plug into any BI tool and support use cases such as:

- Tracking student academic standing and progression
- Identifying at-risk students before they withdraw
- Analysing course completion rates and grade distributions
- Reporting credits earned by program and year level

---

## 🛠 Tech Stack

| Tool | Purpose |
|------|---------|
| [dbt Core 1.8](https://docs.getdbt.com/) | Data transformation framework |
| [DuckDB](https://duckdb.org/) | In-process OLAP database (no server needed) |
| [Python 3.11](https://python.org/) | Runtime & analysis scripts |
| [SQLFluff](https://sqlfluff.com/) | SQL linting & auto-formatting |
| [GitHub Actions](https://github.com/features/actions) | CI/CD pipeline |
| [VS Code](https://code.visualstudio.com/) | IDE with dbt Power User extension |

---

## 📁 Project Structure

```
student_performance_analytics/
├── .github/
│   └── workflows/
│       └── dbt_ci.yml              # CI: build, test, lint on every push
├── .vscode/
│   ├── settings.json               # Editor config for dbt + Python
│   └── extensions.json             # Recommended extensions
├── dbt_project/
│   ├── models/
│   │   ├── staging/                # Clean + type raw source data
│   │   │   ├── _staging_sources.yml
│   │   │   ├── stg_students.sql
│   │   │   ├── stg_courses.sql
│   │   │   ├── stg_enrolments.sql
│   │   │   └── stg_grades.sql
│   │   ├── intermediate/           # Join & enrich staged models
│   │   │   ├── _intermediate.yml
│   │   │   ├── int_enrolments_enriched.sql
│   │   │   └── int_grades_aggregated.sql
│   │   └── marts/                  # Business-facing dimension & fact tables
│   │       ├── _marts.yml
│   │       ├── students/
│   │       │   └── dim_students.sql
│   │       └── courses/
│   │           └── fct_enrolments.sql
│   ├── seeds/                      # Static CSV source data
│   │   ├── raw_students.csv
│   │   ├── raw_courses.csv
│   │   ├── raw_enrolments.csv
│   │   └── raw_grades.csv
│   ├── snapshots/                  # SCD Type 2 — student history tracking
│   │   └── students_snapshot.sql
│   ├── analyses/                   # Ad-hoc SQL analysis queries
│   │   └── at_risk_students_by_program.sql
│   ├── tests/generic/
│   │   └── is_positive.sql         # Custom generic test
│   ├── macros/
│   │   └── utils.sql               # Reusable SQL macros
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── packages.yml
├── .gitignore
├── .pre-commit-config.yaml
├── .sqlfluff
└── requirements.txt
```

---

## 🗺 Data Model

### Lineage

```
raw_students ────────────────────────────────────────────────┐
                                                              ↓
raw_enrolments ──→ stg_enrolments ──→ int_enrolments_enriched ──→ dim_students
raw_courses ─────→ stg_courses ──────↗                        ↘
raw_grades ──────→ stg_grades ───────→ int_grades_aggregated ──→ fct_enrolments
```

### Key Models

| Model | Layer | Materialisation | Description |
|-------|-------|-----------------|-------------|
| `stg_students` | Staging | View | Cleaned student records |
| `stg_courses` | Staging | View | Cleaned course catalogue |
| `stg_enrolments` | Staging | View | Cleaned enrolment records with status flags |
| `stg_grades` | Staging | View | Cleaned grades with weighted scores |
| `int_enrolments_enriched` | Intermediate | View | Enrolments joined with student & course context |
| `int_grades_aggregated` | Intermediate | View | Grades rolled up to one final score per enrolment |
| `dim_students` | Mart | Table | Student dimension with performance metrics & standing |
| `fct_enrolments` | Mart | Table | Enrolments fact table for BI reporting |

### Academic Standing Classification

| Standing | Average Final Score |
|----------|-------------------|
| `High Distinction` | ≥ 85 |
| `Distinction` | 75 – 84 |
| `Credit` | 65 – 74 |
| `Pass` | 50 – 64 |
| `At Risk` | < 50 |
| `No Grade Yet` | No completed courses |

---

## 🚀 Getting Started

### Prerequisites

- Python 3.11+
- Git

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/student-performance-analytics.git
cd student-performance-analytics
```

### 2. Create a virtual environment

```bash
python -m venv .venv
source .venv/bin/activate      # macOS / Linux
.venv\Scripts\activate         # Windows
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Set up dbt profile

```bash
mkdir -p ~/.dbt
cp dbt_project/profiles.yml ~/.dbt/profiles.yml
```

### 5. Install dbt packages

```bash
cd dbt_project
dbt deps
```

---

## ▶ Running the Project

All commands are run from inside the `dbt_project/` directory.

```bash
# Load all seed data into DuckDB
dbt seed

# Run all models
dbt run

# Run a specific layer only
dbt run --select staging
dbt run --select marts

# Run tests
dbt test

# Full refresh (rebuild all tables from scratch)
dbt run --full-refresh

# Generate & serve documentation locally
dbt docs generate
dbt docs serve
```

---

## 🧪 Testing

| Type | Example |
|------|---------|
| **Schema tests** | `unique`, `not_null`, `accepted_values`, `relationships` |
| **Custom generic tests** | `is_positive` — ensures scores are never negative |
| **Referential integrity** | Every enrolment links to a valid student and course |
| **Accepted values** | Grade letters constrained to `HD`, `D`, `C`, `P`, `F` |

```bash
dbt test                          # run all tests
dbt test --select staging         # test one layer
dbt test --select dim_students    # test one model
```

---

## ⚙️ CI/CD

GitHub Actions runs automatically on every push and pull request:

1. **`dbt seed`** — load raw CSV data
2. **`dbt run`** — build all models
3. **`dbt test`** — run all schema & data quality tests
4. **`dbt docs generate`** — build documentation site
5. **SQLFluff lint** — enforce SQL style consistency

---

## 💡 Key Design Decisions

- **DuckDB** — zero-infrastructure, file-based OLAP database. No server, no cloud account needed — perfect for local development and CI.
- **Four seed tables** — students, courses, enrolments, and grades keep the domain realistic and demonstrate multi-source joins.
- **Weighted scoring in staging** — `weighted_score` is calculated once in `stg_grades` and then aggregated in the intermediate layer, keeping logic DRY.
- **At-risk flag** — `is_at_risk` on `dim_students` demonstrates a practical, real-world use case for education institutions.
- **SCD Type 2 snapshot** — tracks student program and year level changes over time, showing enterprise data warehousing patterns.

---

## 📄 Licence

MIT — free to use, fork, and adapt for your own portfolio.
