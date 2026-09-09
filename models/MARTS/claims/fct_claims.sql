-- ================================================================
-- TOPIC 04 | Fact Tables (marts layer)
-- Model   : fct_claims
-- Concepts: materialized=table, surrogate keys, final grain
-- ================================================================
{{
    config(
        materialized='table',
        tags=['claims', 'finance']
    )
}}
-- This model is tagged with both 'claims' and 'finance'.
-- Use tags to run only groups of models, for example:
--   dbt run --select tag:claims
--   dbt run --select tag:finance
--   dbt run --select tag:claims+finance

with enriched as (
    select * from {{ ref('int_claims_enriched') }}
),

final as (
    select
        -- Surrogate key using dbt_utils
        {{ dbt_utils.generate_surrogate_key(['claim_id']) }} as claim_sk,

        -- Natural keys
        claim_id,
        member_id,
        provider_id,
        plan_id,

        -- Dimensions
        claim_type,
        claim_status,
        service_date,
        processed_date,
        diagnosis_code,
        procedure_code,
        provider_specialty,
        network_status,
        is_in_network,
        is_inpatient,
        is_paid,
        is_denied,
        member_state,
        plan_type,

        -- Measures
        billed_amount,
        allowed_amount,
        paid_amount,
        member_responsibility,
        discount_amount,
        discount_pct,
        length_of_stay_days,

        -- Date parts for reporting
        extract(year  from service_date)                    as service_year,
        extract(month from service_date)                    as service_month,
        extract(quarter from service_date)                  as service_quarter

    from enriched
)

select * from final
