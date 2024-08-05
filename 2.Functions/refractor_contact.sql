CREATE OR REPLACE FUNCTION refractor_contact(p_contact_id IN VARCHAR2) 
RETURN VARCHAR2 IS
    valid_contact VARCHAR2(20);
BEGIN
    IF p_contact_id IS NULL THEN 
        RETURN '';
    ELSIF LENGTH(p_contact_id) = 7 THEN
        valid_contact = SUBSTR(p_contact_id, 1, 3)  '-'  SUBSTR(p_contact_id, 4, 4);
        RETURN valid_contact;
    ELSIF LENGTH(p_contact_id) = 8 THEN
        valid_contact = SUBSTR(p_contact_id, 1, 4)  '-'  SUBSTR(p_contact_id, 5, 4);
        RETURN valid_contact;
    ELSE  
        RAISE_APPLICATION_ERROR(-20001, 'Le numéro n`est pas valide  '  p_contact_id);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Aucun enregistrement trouvé pour l`ID de contact  '  p_contact_id);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erreur  '  SQLERRM);
END;
