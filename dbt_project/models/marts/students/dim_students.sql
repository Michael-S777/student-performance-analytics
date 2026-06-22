/*
    dim_students.sql
    ----------------
    Student dimension table with lifetime academic performance metrics.
    One row per student — ready for BI tools and dashboards.
*/

with enrolments as (

    select * from {{ ref('int_enrolments_enriched') }}

),

grades as (

    select * from {{ ref('int_grades_aggregated') }}

),

enrolments_with_grades as (

    select
        e.*,
        g.final_score,
        g.overall_grade,
        g.is_passing,
        g.assignment_score,
        g.midterm_score,
        g.final_exam_score

    from enrolments e
    left join grades g using (enrolment_id)

),

student_metrics as (

    select
        student_id,

        -- Enrolment counts
        count(enrolment_id)                                 as total_enrolments,
        count(case when is_completed  then 1 end)           as completed_courses,
        count(case when is_withdrawn  then 1 end)           as withdrawn_courses,
        count(case when is_active     then 1 end)           as active_courses,

        -- Grade metrics (completed courses only)
        round(avg(case when is_completed then final_score end), 2)
                                                            as avg_final_score,
        max(case when is_completed then final_score end)    as highest_score,
        min(case when is_completed then final_score end)    as lowest_score,
        count(case when is_completed and is_passing then 1 end)
                                                            as passed_courses,

        -- Total credits earned
        sum(case when is_completed and is_passing then credits else 0 end)
                                                            as credits_earned,

        -- Most recent activity
        max(enrolment_date)                                 as latest_enrolment_date

    from enrolments_with_grades
    group by 1

),

students as (

    select * from {{ ref('stg_students') }}

),

final as (

    select
        -- Keys
        s.student_id,

        -- Attributes
        s.full_name,
        s.email,
        s.date_of_birth,
        s.country,
        s.program,
        s.year_level,
        s.enrolment_date,
        s.is_active,

        -- Academic metrics
        coalesce(m.total_enrolments, 0)                     as total_enrolments,
        coalesce(m.completed_courses, 0)                    as completed_courses,
        coalesce(m.withdrawn_courses, 0)                    as withdrawn_courses,
        coalesce(m.active_courses, 0)                       as active_courses,
        coalesce(m.passed_courses, 0)                       as passed_courses,
        coalesce(m.credits_earned, 0)                       as credits_earned,
        m.avg_final_score,
        m.highest_score,
        m.lowest_score,
        m.latest_enrolment_date,

        -- Academic standing
        case
            when coalesce(m.avg_final_score, 0) >= 85 then 'High Distinction'
            when coalesce(m.avg_final_score, 0) >= 75 then 'Distinction'
            when coalesce(m.avg_final_score, 0) >= 65 then 'Credit'
            when coalesce(m.avg_final_score, 0) >= 50 then 'Pass'
            when m.avg_final_score is null              then 'No Grade Yet'
            else 'At Risk'
        end                                                 as academic_standing,

        -- At-risk flag (avg score below pass threshold)
        case
            when coalesce(m.avg_final_score, 100) < 55 then true
            else false
        end                                                 as is_at_risk

    from students s
    left join student_metrics m using (student_id)

)

select * from final
