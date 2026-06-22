/*
    fct_enrolments.sql
    ------------------
    Enrolments fact table with one row per enrolment.
    Combines enrolment status, grade outcomes, and student/course
    context for full BI reporting across students and courses.
*/

with enrolments as (

    select * from {{ ref('int_enrolments_enriched') }}

),

grades as (

    select * from {{ ref('int_grades_aggregated') }}

),

students as (

    select
        student_id,
        academic_standing,
        is_at_risk

    from {{ ref('dim_students') }}

),

final as (

    select
        -- Keys
        e.enrolment_id,
        e.student_id,
        e.course_id,

        -- Date dimensions
        e.enrolment_date,
        date_trunc('month', e.enrolment_date)::date         as enrolment_month,
        e.academic_year,
        e.semester,
        e.completion_date,
        e.days_enrolled,

        -- Enrolment attributes
        e.status,
        e.is_completed,
        e.is_withdrawn,
        e.is_active,

        -- Student context
        e.student_name,
        e.student_program,
        e.student_year_level,
        e.student_country,
        s.academic_standing,
        s.is_at_risk,

        -- Course context
        e.course_code,
        e.course_name,
        e.department,
        e.credits,
        e.lecturer,

        -- Grade outcomes
        g.final_score,
        g.overall_grade,
        g.is_passing,
        g.assignment_score,
        g.midterm_score,
        g.final_exam_score,

        -- Metrics
        case when e.is_completed and g.is_passing then e.credits else 0 end
                                                            as credits_earned

    from enrolments e
    left join grades  g using (enrolment_id)
    left join students s using (student_id)

)

select * from final
