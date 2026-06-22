/*
    stg_enrolments.sql
    ------------------
    Cleans and standardises raw enrolment records.
    - Casts data types
    - Derives helpful boolean flags
    - Handles nullable completion_date
*/

with source as (

    select * from {{ source('raw', 'raw_enrolments') }}

),

renamed as (

    select
        -- IDs
        enrolment_id::integer                           as enrolment_id,
        student_id::integer                             as student_id,
        course_id::integer                              as course_id,

        -- Dates
        enrolment_date::date                            as enrolment_date,
        try_cast(completion_date as date)               as completion_date,

        -- Status
        lower(trim(status))                             as status,

        -- Flags
        case when lower(trim(status)) = 'completed' then true else false end
                                                        as is_completed,
        case when lower(trim(status)) = 'withdrawn'  then true else false end
                                                        as is_withdrawn,
        case when lower(trim(status)) = 'active'     then true else false end
                                                        as is_active,

        -- Audit
        current_timestamp                               as _loaded_at

    from source

)

select * from renamed
