-- ================================================================
-- TOPIC 10 | Incremental Models
-- Model   : fct_claims_incremental
-- Concepts: materialized=incremental, is_incremental(), filters
--           Use when: large tables, append-only or upsert pattern
-- ================================================================
{{
    config(
        materialized='incremental',
        unique_key='claim_id',
        on_schema_change='append_new_columns',
        tags=['claims', 'incremental']
    )
}}

with source as (
    select * from {{ ref('int_claims_enriched') }}

    -- is_incremental() is TRUE only on subsequent runs (not first run)
    {% if is_incremental() %}
        -- Only process new/changed records since last run
        where service_date > (
            select max(service_date) from {{ this }}
        )
    {% endif %}
)

select
    claim_id,
    member_id,
    provider_id,
    plan_id,
    claim_type,
    claim_status,
    service_date,
    processed_date,
    diagnosis_code,
    procedure_code,
    billed_amount,
    allowed_amount,
    paid_amount,
    member_responsibility,
    discount_amount,
    discount_pct,
    is_paid,
    is_denied,
    is_inpatient,
    is_in_network,
    provider_specialty,
    plan_type,
    member_state,
    service_year,
    service_quarter,
    service_month,
    length_of_stay_days,
    current_timestamp as dbt_loaded_at

from source
