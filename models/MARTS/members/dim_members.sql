-- ================================================================
-- TOPIC 04 | Dimension Tables
-- Model   : dim_members
-- Concepts: SCD Type 1 dimension, age calculation, bucketing
-- ================================================================
{{
    config(
        materialized='table',
        tags=['members']
    )
}}

with members as (
    select * from {{ ref('stg_members') }}
),

plans as (
    select * from {{ ref('stg_plans') }}
),

member_stats as (
    select * from {{ ref('int_member_claim_summary') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['m.member_id']) }} as member_sk,
        m.member_id,
        m.full_name,
        m.first_name,
        m.last_name,
        m.date_of_birth,
        m.gender,
        m.plan_id,
        m.enrollment_date,
        m.termination_date,
        m.state,
        m.zip_code,
        m.is_active,
        p.plan_name,
        p.plan_type,
        p.deductible_individual,
        p.premium_individual,

        -- TOPIC 05: Age calculation & bucketing (window function prep)
        datediff('year', m.date_of_birth, current_date)    as age,

        case
            when datediff('year', m.date_of_birth, current_date) < 18 then 'Under 18'
            when datediff('year', m.date_of_birth, current_date) < 35 then '18-34'
            when datediff('year', m.date_of_birth, current_date) < 50 then '35-49'
            when datediff('year', m.date_of_birth, current_date) < 65 then '50-64'
            else '65+'
        end                                                  as age_band,

        -- Tenure in months
        datediff('month', m.enrollment_date,
            coalesce(m.termination_date, current_date))     as tenure_months,

        -- Stats from intermediate
        coalesce(ms.total_claims, 0)                        as total_claims,
        coalesce(ms.total_paid, 0)                          as total_paid,
        coalesce(ms.denial_rate_pct, 0)                     as denial_rate_pct

    from members m
    left join plans p         on m.plan_id    = p.plan_id
    left join member_stats ms on m.member_id  = ms.member_id
)

select * from final
