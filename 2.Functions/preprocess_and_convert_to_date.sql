CREATE OR REPLACE FUNCTION preprocess_and_convert_to_date(p_date_str IN VARCHAR2) RETURN DATE IS
    v_cleaned_date_str VARCHAR2(30);
    v_converted_date DATE;
BEGIN
    v_cleaned_date_str := TRIM(p_date_str); -- Enlever les espaces
    v_cleaned_date_str := REPLACE(v_cleaned_date_str, '/', '-');
    BEGIN
        v_converted_date := TO_DATE(v_cleaned_date_str, 'DD-MON-YYYY');
        RETURN v_converted_date;
    EXCEPTION
        WHEN OTHERS THEN
            NULL; 
    END;
    BEGIN
        v_converted_date := TO_DATE(v_cleaned_date_str, 'DD-MMM-YYYY');
        RETURN v_converted_date;
    EXCEPTION
        WHEN OTHERS THEN
            NULL; 
    END;

    BEGIN
        v_converted_date := TO_DATE(v_cleaned_date_str, 'DD-MM-YYYY');
        RETURN v_converted_date;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;  
    END;
    BEGIN
        v_converted_date := TO_DATE(v_cleaned_date_str, 'DD-M-YYYY');
        RETURN v_converted_date;
    EXCEPTION
        WHEN OTHERS THEN
            NULL; 
    END;
  BEGIN
        v_converted_date := TO_DATE(v_cleaned_date_str, 'DD/MM/YYYY');
        RETURN v_converted_date;
    EXCEPTION
        WHEN OTHERS THEN
            NULL; 
    END;
    BEGIN
        v_converted_date := TO_DATE(v_cleaned_date_str, 'DD-MM-YYYY');
        RETURN v_converted_date;
    EXCEPTION
        WHEN OTHERS THEN
            NULL; 
    END;
    RAISE_APPLICATION_ERROR(-20001, 'Invalid date format: ' || p_date_str);
END;
