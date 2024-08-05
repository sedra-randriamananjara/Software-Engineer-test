	ALTER SESSION SET NLS_DATE_LANGUAGE = 'ENGLISH';

-------order
INSERT
	INTO
	XXBCM_ORDERS
( ORDER_REF,
	order_date,
	ORDER_DESCRIPTION,
	ORDER_STATUS,
	ORDER_TOTAL_AMOUNT,
	SUPPLIER_ID)
SELECT
	ORDER_REF,
	preprocess_and_convert_to_date(order_date),
	ORDER_DESCRIPTION,
	ORDER_STATUS,
	convert_montant(ORDER_TOTAL_AMOUNT),
	(
	SELECT
		SUPPLIER_ID
	FROM
		XXBCM_SUPPLIERS xs
	WHERE
		xs.supplier_name = ord.supplier_name)
FROM
	XXBCM_ORDER_MGT ord
WHERE
	LENGTH (ORDER_REF)= 5
;
-------order_line

INSERT INTO XXBCM_ORDER_LINE
( ORDER_LINE_REF,ORDER_ID, ORDER_DESCRIPTION, ORDER_STATUS, ORDER_LINE_AMOUNT)
SELECT
    ord.order_ref,
	(
	SELECT
		order_id
	FROM
		XXBCM_ORDERS  xs
	WHERE
		xs.ORDER_REF= SUBSTR(ord.order_ref,1,5) ),
	ORDER_DESCRIPTION,
	ORDER_STATUS,
	convert_montant(ORDER_LINE_AMOUNT)
FROM
	XXBCM_ORDER_MGT ord
WHERE
	LENGTH (ORDER_REF) > 5
;