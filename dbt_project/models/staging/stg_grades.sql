/*
    stg_grades.sql
    --------------
    Cleans and standardises raw assessment grade records.
    - Casts data types
    - Calculates weighted_score (score × weight) for each assessment
    - Derives a letter_grade from the raw score
*/

with source as (

    select * from {{ source('raw', 'raw_grades') }}

),

renamed as (

    select
        -- IDs
        grade_id::integer                               as grade_id,
        enrolment_id::integer                           as enrolment_id,

        -- Assessment details
        lower(trim(assessment_type))                    as assessment_type,
        score::decimal(5,2)                             as score,
        max_score::decimal(5,2)                         as max_score,
        weight_pct::decimal(5,2)                        as weight_pct,

        -- Derived metrics
        round(
            (score::decimal / max_score::decimal) * weight_pct::decimal,
            2
        )                                               as weighted_score,

        -- Letter grade based on percentage score
        case
            when score >= 85 then 'HD'   -- High Distinction
            when score >= 75 then 'D'    -- Distinction
            when score >= 65 then 'C'    -- Credit
            when score >= 50 then 'P'    -- Pass
            else 'F'                     -- Fail
        end                                             as letter_grade,

        -- Dates
        submitted_at::timestamp                         as submitted_at,

        -- Audit
        current_timestamp                               as _loaded_at

    from source

)

select * from renamed
