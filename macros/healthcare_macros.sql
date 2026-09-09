-- ================================================================
-- TOPIC 06 | Macros - Reusable SQL Logic
-- File    : macros/healthcare_macros.sql
-- Concepts: macro definition, arguments, caller usage
-- ================================================================

-- Macro 1: Classify a diagnosis code into clinical category
{% macro classify_diagnosis(diagnosis_col) %}
    case
        when {{ diagnosis_col }} like 'I%'  then 'Cardiovascular'
        when {{ diagnosis_col }} like 'F%'  then 'Behavioral Health'
        when {{ diagnosis_col }} like 'J%'  then 'Respiratory'
        when {{ diagnosis_col }} like 'M%'  then 'Musculoskeletal'
        when {{ diagnosis_col }} like 'Z00%' then 'Preventive'
        when {{ diagnosis_col }} like 'Z%'  then 'Wellness / Factors'
        else 'Other'
    end
{% endmacro %}


-- Macro 2: Standard financial ratio
{% macro calc_discount_pct(billed_col, allowed_col) %}
    round(
        case
            when {{ billed_col }} > 0
            then (1 - {{ allowed_col }} / {{ billed_col }}) * 100
            else 0
        end
    , 2)
{% endmacro %}


-- Macro 3: Generic cents-to-dollars formatter (useful in DuckDB)
{% macro safe_divide_new(numerator, denominator, default_value=0) %}
    case
        when {{ denominator }} = 0 or {{ denominator }} is null
        then {{ default_value }}
        else {{ numerator }} / {{ denominator }}
    end
{% endmacro %}


-- Macro 4: Date spine helper - generate date range label
{% macro date_label(year_col, month_col) %}
    cast({{ year_col }} as varchar) || '-' ||
    lpad(cast({{ month_col }} as varchar), 2, '0')
{% endmacro %}
