-- ================================================================
-- TOPIC 04 | Provider Dimension
-- ================================================================
{{
    config(
        materialized='table',
        tags=['providers']
    )
}}

with providers as (
    select * from {{ ref('stg_providers') }}
),

provider_claims as (
    select
        provider_id,
        count(claim_id)         as total_claims_received,
        sum(billed_amount)      as total_billed,
        sum(paid_amount)        as total_paid,
        avg(billed_amount)      as avg_claim_amount,
        count(case when is_denied then 1 end) as denied_claims
    from {{ ref('fct_claims') }}
    group by provider_id
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['p.provider_id']) }} as provider_sk,
        p.provider_id,
        p.npi,
        p.provider_name,
        p.provider_type,
        p.specialty,
        p.state,
        p.zip_code,
        p.network_status,
        p.is_in_network,
        p.is_hospital,
        p.contract_start_date,

        coalesce(pc.total_claims_received, 0) as total_claims,
        coalesce(pc.total_billed, 0)          as total_billed,
        coalesce(pc.total_paid, 0)            as total_paid,
        coalesce(pc.avg_claim_amount, 0)      as avg_claim_amount,
        coalesce(pc.denied_claims, 0)         as denied_claims,

        round(
            coalesce(pc.denied_claims, 0) * 100.0
            / nullif(coalesce(pc.total_claims_received, 0), 0)
        , 2)                                  as denial_rate_pct

    from providers p
    left join provider_claims pc on p.provider_id = pc.provider_id
)

select * from final
