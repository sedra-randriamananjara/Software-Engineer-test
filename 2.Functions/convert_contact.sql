CREATE OR REPLACE FUNCTION convert_Contact(p_contact IN VARCHAR2) RETURN VARCHAR2 IS
    v_formatted_contact VARCHAR2(4000);
BEGIN
    -- Replace characters 's', 'l', and 'o' with '5', '1', and '0' respectively
    v_formatted_contact := REPLACE(p_contact, 's', '5');
    v_formatted_contact := REPLACE(v_formatted_contact, 'l', '1');
    v_formatted_contact := REPLACE(v_formatted_contact, 'o', '0');
    v_formatted_contact := REPLACE(v_formatted_contact, 'I', '1');
	v_formatted_contact := REPLACE(v_formatted_contact, 'S', '5');

    -- Return the formatted contact number
    RETURN nvl(v_formatted_contact,0);
END;
