CREATE OR REPLACE FUNCTION convert_Contact(p_contact IN VARCHAR2) RETURN VARCHAR2 IS
    v_formatted_contact VARCHAR2(4000);
BEGIN
    v_formatted_contact := REPLACE(p_contact, 's', '5');
    v_formatted_contact := REPLACE(v_formatted_contact, 'l', '1');
    v_formatted_contact := REPLACE(v_formatted_contact, 'o', '0');
    v_formatted_contact := REPLACE(v_formatted_contact, 'I', '1');
	v_formatted_contact := REPLACE(v_formatted_contact, 'S', '5');

    RETURN nvl(v_formatted_contact,0);
END;

CREATE OR REPLACE FUNCTION convert_montant(p_montant IN VARCHAR2) RETURN NUMBER IS
    v_montant VARCHAR2(4000);
    v_result NUMBER;
BEGIN
    v_montant := REPLACE(p_montant, 'S', '5');
    v_montant := REPLACE(v_montant, 'I', '1');
    v_montant := REPLACE(v_montant, 'l', '1');
    v_montant := REPLACE(v_montant, 'o', '0');
    v_montant := REPLACE(v_montant, ',', '');

    BEGIN
        v_result := TO_NUMBER(nvl(v_montant,0));
    EXCEPTION
        WHEN VALUE_ERROR THEN
            v_result := NULL;
    END;

    RETURN v_result;
END;

CREATE OR REPLACE FUNCTION get_invoice_status_action(p_order_id IN NUMBER) RETURN VARCHAR2 IS
    v_status_count NUMBER;
   v_status_count2 NUMBER;
BEGIN
	  SELECT COUNT(*)
    INTO v_status_count
    FROM v_XXBCM_INVOICES
    WHERE order_id = p_order_id
      AND invoice_status = 'Pending';
     IF v_status_count > 0 THEN
        RETURN 'To follow up';
    END IF;
 
    SELECT COUNT(*)
    INTO v_status_count
    FROM v_XXBCM_INVOICES
    WHERE order_id = p_order_id
      AND (invoice_status IS NULL OR invoice_status = '');

    IF v_status_count > 0 THEN
        RETURN 'To verify';
    END IF;
   
    SELECT COUNT(*)
    INTO v_status_count
    FROM v_XXBCM_INVOICES
    WHERE order_id = p_order_id ;
   
        SELECT COUNT(*)
    INTO v_status_count2
    FROM v_XXBCM_INVOICES
    WHERE order_id = p_order_id
    AND invoice_status <> 'Paid';
    IF (v_status_count2 = 0 AND v_status_count > 0) THEN
        RETURN 'OK';
    END IF;

    RETURN 'Unknown Status';
END;

CREATE OR REPLACE FUNCTION isemail(email IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
    RETURN REGEXP_LIKE(email,
        '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
        'IX');
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;

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

CREATE OR REPLACE FUNCTION refractor_contact(p_contact_id IN VARCHAR2) 
RETURN VARCHAR2 IS
    valid_contact VARCHAR2(20);
BEGIN
    IF p_contact_id IS NULL THEN 
        RETURN '';
    ELSIF LENGTH(p_contact_id) = 7 THEN
        valid_contact := SUBSTR(p_contact_id, 1, 3) || '-' || SUBSTR(p_contact_id, 4, 4);
        RETURN valid_contact;
    ELSIF LENGTH(p_contact_id) = 8 THEN
        valid_contact := SUBSTR(p_contact_id, 1, 4) || '-' || SUBSTR(p_contact_id, 5, 4);
        RETURN valid_contact;
    ELSE  
        RAISE_APPLICATION_ERROR(-20001, 'Le numéro n`est pas valide : ' || p_contact_id);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Aucun enregistrement trouvé pour l`ID de contact : ' || p_contact_id);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erreur : ' || SQLERRM);
END;