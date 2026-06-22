{% macro safe_divide(numerator, denominator) %}
    case
        when {{ denominator }} = 0 or {{ denominator }} is null
        then null
        else {{ numerator }} / {{ denominator }}
    end
{% endmacro %}


{% macro grade_label(score_column) %}
    case
        when {{ score_column }} >= 85 then 'HD'
        when {{ score_column }} >= 75 then 'D'
        when {{ score_column }} >= 65 then 'C'
        when {{ score_column }} >= 50 then 'P'
        else 'F'
    end
{% endmacro %}


{% macro current_timestamp_utc() %}
    current_timestamp
{% endmacro %}
