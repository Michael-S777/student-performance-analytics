/*
    at_risk_students_by_program.sql
    --------------------------------
    Ad-hoc analysis: identifies at-risk students grouped by program.
    Run with: dbt compile --select at_risk_students_by_program
*/

with students as (

    select * from {{ ref('dim_students') }}

),

at_risk as (

    select
        program,
        count(student_id)                               as total_students,
        count(case when is_at_risk then 1 end)          as at_risk_students,
        round(
            count(case when is_at_risk then 1 end) * 100.0
            / nullif(count(student_id), 0),
            1
        )                                               as at_risk_pct,
        round(avg(avg_final_score), 2)                  as avg_program_score,
        round(avg(credits_earned), 1)                   as avg_credits_earned

    from students
    where is_active = true
    group by 1
    order by at_risk_pct desc

)

select * from at_risk
