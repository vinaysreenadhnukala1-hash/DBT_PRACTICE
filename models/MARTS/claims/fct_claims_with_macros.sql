-- ================================================================
-- TOPIC 06 | Using Macros in Models
-- Model   : fct_claims_with_macros
-- Concepts: calling custom macros, cleaner SQL via macros
-- ================================================================
{{
    config(
        materialized='table',
        tags=['claims']
    )
}}
-- This model is tagged with 'claims'.
-- Run models with this tag only via:
--   dbt run --select tag:claims
-- Tags help organize models by domain, team, or purpose.

with base as (
    select * from {{ ref('int_claims_enriched') }}
)

select
    claim_id,
    member_id,
    provider_id,
    service_date,
    diagnosis_code,
    billed_amount,
    allowed_amount,
    paid_amount,
    claim_status,
    provider_specialty,

    -- MACRO USAGE: classify_diagnosis
    {{ classify_diagnosis('diagnosis_code') }}      as clinical_category,

    -- MACRO USAGE: calc_discount_pct
    {{ calc_discount_pct('billed_amount', 'allowed_amount') }} as discount_pct,

    -- MACRO USAGE: safe_divide
    {{ safe_divide('paid_amount', 'billed_amount') }} as payment_ratio,

    -- MACRO USAGE: date_label
    {{ date_label('extract(year from service_date)', 'extract(month from service_date)') }} as service_month_label

from base
