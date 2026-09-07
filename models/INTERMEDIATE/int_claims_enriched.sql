with claims as (
    select * from {{ ref('stg_claims') }}
),

members as (
    select * from {{ ref('stg_members') }}
),

providers as (
    select * from {{ ref('stg_providers') }}
),

plans as (
    select * from {{ ref('stg_plans') }}
),

enriched as (
    select
        -- Claim fields
        c.claim_id,
        c.member_id,
        c.provider_id,
        c.claim_type,
        c.service_date,
        c.admission_date,
        c.discharge_date,
        c.diagnosis_code,
        c.procedure_code,
        c.billed_amount,
        c.allowed_amount,
        c.paid_amount,
        c.member_responsibility,
        c.claim_status,
        c.processed_date,
        c.is_paid,
        c.is_denied,
        c.is_inpatient,

        -- Member fields
        m.full_name                                        as member_name,
        m.date_of_birth                                    as member_dob,
        m.gender                                           as member_gender,
        m.plan_id,
        m.state                                            as member_state,
        m.is_active                                        as member_is_active,

        -- Provider fields
        p.provider_name,
        p.provider_type,
        p.specialty                                        as provider_specialty,
        p.network_status,
        p.is_in_network,
        p.is_hospital,

        -- Plan fields
        pl.plan_name,
        pl.plan_type,
        pl.deductible_individual,
        pl.coinsurance_pct,

        -- Derived financial columns
        c.billed_amount - c.allowed_amount                 as discount_amount,
        c.allowed_amount - c.paid_amount                   as unpaid_allowed,
        round(
            case
                when c.billed_amount > 0
                then (c.allowed_amount / c.billed_amount) * 100
                else 0
            end, 2
        )                                                  as discount_pct,

        -- Inpatient: length of stay
        case
            when c.is_inpatient and c.discharge_date is not null
            then datediff('day', c.admission_date, c.discharge_date)
            else null
        end                                                as length_of_stay_days
        -- Date parts for reporting
        ,extract(year  from service_date)                    as service_year,
        extract(month from service_date)                    as service_month,
        extract(quarter from service_date)                  as service_quarter
    from claims c
    left join members  m  on c.member_id   = m.member_id
    left join providers p  on c.provider_id  = p.provider_id
    left join plans     pl on m.plan_id      = pl.plan_id
)

select * from enriched
