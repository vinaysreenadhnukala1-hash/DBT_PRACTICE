with source as (
    select * from {{ ref('raw_claims') }}
),

renamed as (
    select
        claim_id,
        member_id,
        provider_id,
        upper(claim_type)                                         as claim_type,
        cast(service_date   as date)                             as service_date,
        cast(admission_date as date)                             as admission_date,
        cast(discharge_date as date)                             as discharge_date,
        diagnosis_code,
        procedure_code,

        cast(coalesce(billed_amount,        0) as decimal(18,2)) as billed_amount,
        cast(coalesce(allowed_amount,       0) as decimal(18,2)) as allowed_amount,
        cast(coalesce(paid_amount,          0) as decimal(18,2)) as paid_amount,
        cast(coalesce(member_responsibility,0) as decimal(18,2)) as member_responsibility,

        upper(claim_status)                                       as claim_status,
        cast(processed_date as date)                             as processed_date,
        cast(created_at as timestamp)                            as created_at,

        -- Derived flags
        case when upper(claim_status) = 'PAID'      then true else false end as is_paid,
        case when upper(claim_status) = 'DENIED'    then true else false end as is_denied,
        case when upper(claim_type)   = 'INPATIENT' then true else false end as is_inpatient

    from source
)

select * from renamed
