/*
    int_enrolments_enriched.sql
    ---------------------------
    Joins enrolments with student and course context.
    Produces one enriched row per enrolment, used by both
    the dim_students and fct_enrolments mart models.
*/

with enrolments as (

    select * from {{ ref('stg_enrolments') }}

),

students as (

    select * from {{ ref('stg_students') }}

),

courses as (

    select * from {{ ref('stg_courses') }}

),

joined as (

    select
        -- Keys
        e.enrolment_id,
        e.student_id,
        e.course_id,

        -- Enrolment attributes
        e.enrolment_date,
        e.completion_date,
        e.status,
        e.is_completed,
        e.is_withdrawn,
        e.is_active,

        -- Student context
        s.full_name             as student_name,
        s.email                 as student_email,
        s.program               as student_program,
        s.year_level            as student_year_level,
        s.country               as student_country,
        s.is_active             as student_is_active,

        -- Course context
        c.course_code,
        c.course_name,
        c.department,
        c.credits,
        c.lecturer,
        c.semester,
        c.academic_year,

        -- Derived
        datediff(
            'day', e.enrolment_date, coalesce(e.completion_date, current_date)
        )                       as days_enrolled

    from enrolments e
    left join students s using (student_id)
    left join courses  c using (course_id)

)

select * from joined
