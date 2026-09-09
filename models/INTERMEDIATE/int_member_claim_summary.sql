with enriched as (
    select * from {{ ref('int_claims_enriched') }}
),

member_summary as (
    select
        member_id,
        member_name,
        plan_id,
        plan_name,
        member_state,
        member_gender,

        -- Claim counts
        count(claim_id)                                      as total_claims,
        count(case when is_paid    then 1 end)               as paid_claims,
        count(case when is_denied  then 1 end)               as denied_claims,
        count(case when is_inpatient then 1 end)             as inpatient_claims,

        -- Financial aggregates
        sum(billed_amount)                                   as total_billed,
        sum(allowed_amount)                                  as total_allowed,
        sum(paid_amount)                                     as total_paid,
        sum(member_responsibility)                           as total_member_responsibility,
        sum(discount_amount)                                 as total_discounts,

        -- Averages
        avg(billed_amount)                                   as avg_claim_billed,
        avg(paid_amount)                                     as avg_claim_paid,

        -- Deny rate
        round(
            count(case when is_denied then 1 end) * 100.0
            / nullif(count(claim_id), 0)
        , 2)                                                 as denial_rate_pct,

        -- Date range
        min(service_date)                                    as first_service_date,
        max(service_date)                                    as last_service_date

    from enriched
    group by
        member_id, member_name, plan_id, plan_name,
        member_state, member_gender
)

select * from member_summary
