with source as (
    -- ref() is how dbt tracks lineage between models and seeds
    select * from {{ ref('raw_members') }}
),

renamed as (
    select
        member_id,
        first_name,
        last_name,
        first_name || ' ' || last_name             as full_name,
        cast(date_of_birth   as date)              as date_of_birth,
        gender,
        plan_id,
        cast(enrollment_date  as date)             as enrollment_date,
        cast(termination_date as date)             as termination_date,
        state,
        zip_code,
        cast(created_at as timestamp)              as created_at,

        -- Derived boolean: active if no termination date
        termination_date is null                   as is_active

    from source
)

select * from renamed
