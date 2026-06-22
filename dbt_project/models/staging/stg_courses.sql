/*
    stg_courses.sql
    ---------------
    Cleans and standardises raw course catalogue records.
    - Casts data types
    - Trims whitespace from text fields
*/

with source as (

    select * from {{ source('raw', 'raw_courses') }}

),

renamed as (

    select
        -- IDs
        course_id::integer                              as course_id,
        trim(course_code)                               as course_code,

        -- Attributes
        trim(course_name)                               as course_name,
        trim(department)                                as department,
        credits::integer                                as credits,
        trim(lecturer)                                  as lecturer,
        max_capacity::integer                           as max_capacity,

        -- Semester context
        semester::integer                               as semester,
        year::integer                                   as academic_year,

        -- Status
        case
            when lower(is_active::varchar) in ('true', '1', 'yes') then true
            else false
        end                                             as is_active,

        -- Audit
        current_timestamp                               as _loaded_at

    from source

)

select * from renamed
