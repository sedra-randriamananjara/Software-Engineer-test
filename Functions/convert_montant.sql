CREATE OR REPLACE FUNCTION MCBDATAM.convert_montant(p_montant IN VARCHAR2) RETURN NUMBER IS
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
