-- ================================================================
-- TOPIC 05 | Window Functions
-- Model   : fct_claims_monthly
-- Concepts: ROW_NUMBER, RANK, LAG/LEAD, running totals, partitions
-- ================================================================
{{
    config(
        materialized='table',
        tags=['finance', 'reporting']
    )
}}

with claims as (
    select * from {{ ref('fct_claims') }}
),

monthly_agg as (
    select
        service_year,
        service_month,
        plan_type,
        member_state,

        count(claim_id)         as claim_count,
        sum(billed_amount)      as total_billed,
        sum(allowed_amount)     as total_allowed,
        sum(paid_amount)        as total_paid,
        sum(discount_amount)    as total_discounts,
        avg(paid_amount)        as avg_paid_per_claim,
        count(case when is_denied then 1 end) as denied_claims

    from claims
    group by service_year, service_month, plan_type, member_state
),

with_window_funcs as (
    select
        *,

        -- RANK: rank months by total paid within each state+plan_type
        rank() over (
            partition by member_state, plan_type
            order by total_paid desc
        )                                           as paid_rank_in_state,

        -- ROW_NUMBER: unique sequential row per partition
        row_number() over (
            partition by service_year
            order by service_month
        )                                           as month_seq_in_year,

        -- LAG: previous month paid (month-over-month comparison)
        lag(total_paid, 1) over (
            partition by plan_type, member_state
            order by service_year, service_month
        )                                           as prev_month_paid,

        -- LEAD: next month's paid (lookahead)
        lead(total_paid, 1) over (
            partition by plan_type, member_state
            order by service_year, service_month
        )                                           as next_month_paid,

        -- Running total (cumulative sum)
        sum(total_paid) over (
            partition by service_year, plan_type
            order by service_month
            rows between unbounded preceding and current row
        )                                           as running_total_paid_ytd,

        -- 3-month rolling average
        avg(total_paid) over (
            partition by plan_type, member_state
            order by service_year, service_month
            rows between 2 preceding and current row
        )                                           as rolling_3m_avg_paid

    from monthly_agg
),

final as (
    select
        *,
        -- MoM change derived from LAG
        round(
            (total_paid - prev_month_paid) * 100.0
            / nullif(prev_month_paid, 0)
        , 2)                                        as mom_paid_change_pct
    from with_window_funcs
)

select * from final
