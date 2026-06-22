/*
    stg_students.sql
    ----------------
    Cleans and standardises raw student records.
    - Casts data types
    - Derives full_name and age
    - Normalises the is_active boolean
*/

with source as (

    select * from {{ source('raw', 'raw_students') }}

),

renamed as (

    select
        -- IDs
        student_id::integer                             as student_id,

        -- Name
        first_name,
        last_name,
        first_name || ' ' || last_name                  as full_name,

        -- Contact
        lower(trim(email))                              as email,

        -- Demographics
        date_of_birth::date                             as date_of_birth,
        country,

        -- Academic
        trim(program)                                   as program,
        year_level::integer                             as year_level,
        enrolment_date::date                            as enrolment_date,

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
