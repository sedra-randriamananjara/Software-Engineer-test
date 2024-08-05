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

    -- Si aucun des critères ci-dessus n'est rempli
    RETURN 'Unknown Status';
END;