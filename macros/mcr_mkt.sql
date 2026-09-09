{% macro mcr_mkt(c_mktsegment) %}
    case when {{c_mktsegment}} in ('HOUSEHOLD','FURNITURE') then 'CT_1' 
         when {{c_mktsegment}} in ('BUILDING','AUTOMOBILE','MACHINERY') then 'CT_2' 
         else 'CT_3' end 
{% endmacro %}