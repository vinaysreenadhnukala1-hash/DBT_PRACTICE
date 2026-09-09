/*
  TOPIC 06 – Macros
  ──────────────────
  Reusable Jinja macros for the humana project.
*/

-- ── Macro 1: Strip whitespace and uppercase a code column ──────────────
{% macro clean_code(column_name) %}
    upper(trim({{ column_name }}))
{% endmacro %}


-- ── Macro 2: Safe division (avoids divide-by-zero) ────────────────────
{% macro safe_divide(numerator, denominator) %}
    case
        when {{ denominator }} = 0 or {{ denominator }} is null
            then null
        else {{ numerator }} / {{ denominator }}
    end
{% endmacro %}


-- ── Macro 3: Cost category banding ────────────────────────────────────
{% macro cost_band(amount_col) %}
    case
        when {{ amount_col }} < 1000    then 'Low (<$1K)'
        when {{ amount_col }} < 10000   then 'Medium ($1K-$10K)'
        when {{ amount_col }} < 50000   then 'High ($10K-$50K)'
        else 'Catastrophic (>$50K)'
    end
{% endmacro %}


-- ── Macro 4: Generate a surrogate key from multiple columns ────────────
{% macro generate_claim_key(claim_id, member_id, service_date) %}
    {{ dbt_utils.generate_surrogate_key([claim_id, member_id, service_date]) }}
{% endmacro %}


-- ── Macro 5: Dynamic date spine helper ────────────────────────────────
-- Usage: {{ months_between('2024-01-01', '2024-12-31') }}
{% macro months_between(start_date, end_date) %}
    datediff('month', '{{ start_date }}'::date, '{{ end_date }}'::date)
{% endmacro %}
