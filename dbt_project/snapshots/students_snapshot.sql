/*
    students_snapshot.sql
    ---------------------
    Tracks historical changes to student records (SCD Type 2).
    Captures when a student changes their program, year level,
    or active status over time.
*/

{% snapshot students_snapshot %}

    {{
        config(
            target_schema='snapshots',
            unique_key='student_id',
            strategy='check',
            check_cols=['program', 'year_level', 'is_active'],
        )
    }}

    select * from {{ ref('stg_students') }}

{% endsnapshot %}
