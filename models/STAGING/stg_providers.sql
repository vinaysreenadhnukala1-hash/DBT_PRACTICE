with source as (
    select * from {{ ref('raw_providers') }}
),

renamed as (
    select
        provider_id,
        npi,
        provider_name,
        upper(provider_type)                       as provider_type,
        specialty,
        tax_id,
        state,
        zip_code,
        upper(network_status)                      as network_status,
        try_cast(nullif(trim(contract_start_date), '') as date) as contract_start_date,
        try_cast(nullif(trim(contract_end_date), '') as date)   as contract_end_date,
        cast(created_at as timestamp)              as created_at,

        case when upper(network_status) = 'IN_NETWORK' then true else false end as is_in_network,
        case when upper(provider_type)  = 'HOSPITAL'   then true else false end as is_hospital

    from source
)

select * from renamed
