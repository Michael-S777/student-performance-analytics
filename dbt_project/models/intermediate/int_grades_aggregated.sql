/*
    int_grades_aggregated.sql
    -------------------------
    Aggregates all assessment grades per enrolment into a single
    final_score and overall letter grade.  This powers the
    performance columns in both mart models.
*/

with grades as (

    select * from {{ ref('stg_grades') }}

),

aggregated as (

    select
        enrolment_id,

        -- Weighted final score (sum of all weighted_score contributions)
        round(sum(weighted_score), 2)                   as final_score,

        -- Individual assessment scores
        max(case when assessment_type = 'assignment'   then score end)
                                                        as assignment_score,
        max(case when assessment_type = 'midterm_exam' then score end)
                                                        as midterm_score,
        max(case when assessment_type = 'final_exam'   then score end)
                                                        as final_exam_score,

        -- Assessment counts
        count(grade_id)                                 as total_assessments,

        -- Overall letter grade based on weighted final score
        case
            when round(sum(weighted_score), 2) >= 85 then 'HD'
            when round(sum(weighted_score), 2) >= 75 then 'D'
            when round(sum(weighted_score), 2) >= 65 then 'C'
            when round(sum(weighted_score), 2) >= 50 then 'P'
            else 'F'
        end                                             as overall_grade,

        -- Pass/fail flag
        case
            when round(sum(weighted_score), 2) >= 50 then true
            else false
        end                                             as is_passing

    from grades
    group by 1

)

select * from aggregated
