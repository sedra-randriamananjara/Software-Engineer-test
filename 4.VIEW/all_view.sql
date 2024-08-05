-- MCBDATAM.INVOICE_REFERENCE_FULL source

CREATE OR REPLACE  VIEW INVOICE_REFERENCE_FULL (INVOICE_ID, INVOICE_REFERENCE, INVOICE_DATE, INVOICE_STATUS, INVOICE_HOLD_REASON, INVOICE_AMOUNT, INVOICE_DESCRIPTION, ORDER_LINE_ID, ORDER_DESCRIPTION, ORDER_LINE_AMOUNT, ORDER_STATUS, ORDER_LINE_REF, ORDER_DESCRIPTION_MERE, ORDER_DATE, ORDER_STATUS_MERE, ORDER_TOTAL_AMOUNT, ORDER_REF, SUPPLIER_ID) AS 
  SELECT 
inv.INVOICE_ID,inv.INVOICE_REFERENCE,inv.INVOICE_DATE,inv.INVOICE_STATUS,inv.INVOICE_HOLD_REASON,inv.INVOICE_AMOUNT,inv.INVOICE_DESCRIPTION,inv.ORDER_LINE_ID,
xig.ORDER_DESCRIPTION ,
xig.order_line_amount ,
xig.ORDER_STATUS ,
xig.ORDER_LINE_REF ,
ors.order_description AS order_description_mere,
ors.order_date,
ORS.ORDER_STATUS AS ORDER_STATUS_mere,
ors.order_total_amount,
ors.order_ref,
ORS.SUPPLIER_ID 
FROM XXBCM_INVOICES inv 
	LEFT JOIN XXBCM_ORDER_LINE xig    ON xig.ORDER_LINE_ID = inv.ORDER_LINE_ID
	LEFT JOIN XXBCM_ORDERs ORS ON xig.ORDER_ID = ors.ORDER_ID;


-- MCBDATAM.V_XXBCM_INVOICES source

CREATE OR REPLACE  VIEW V_XXBCM_INVOICES (INVOICE_ID, INVOICE_REFERENCE, INVOICE_DATE, INVOICE_STATUS, INVOICE_HOLD_REASON, INVOICE_AMOUNT, INVOICE_DESCRIPTION, ORDER_LINE_ID, ORDER_LINE_REF, ORDER_REF, ORDER_ID) AS 
  SELECT xi.INVOICE_ID,xi.INVOICE_REFERENCE,xi.INVOICE_DATE,xi.INVOICE_STATUS,xi.INVOICE_HOLD_REASON,xi.INVOICE_AMOUNT,xi.INVOICE_DESCRIPTION,xi.ORDER_LINE_ID ,
      		xol.order_line_ref,
      		xo.order_ref,
      		xo.order_id
      		FROM XXBCM_INVOICES xi,
      		XXBCM_ORDER_LINE xol,
      		XXBCM_ORDERS xo 
      		WHERE xi.order_line_id = xol.order_line_id (+)
      		AND xol.order_id= xo.order_id(+)
      		
      	;
-- MCBDATAM.V_XXBCM_INVOICES_GRP_ORDER source

CREATE OR REPLACE  VIEW V_XXBCM_INVOICES_GRP_ORDER (ORDER_REF, INVOICE_AMOUNT, INVOICE_REFERENCE, INVOICE_REFERENCES_CONCAT) AS 
  SELECT 
       v.order_ref,
       sum(nvl(invoice_amount,0)) AS invoice_amount,
       SUBSTR(min(v.invoice_reference),1,9) AS invoice_reference,
       LISTAGG( v.INVOICE_REFERENCE, '|') WITHIN GROUP (ORDER BY INVOICE_DATE) AS INVOICE_REFERENCES_concat
       FROM v_XXBCM_INVOICES v
       GROUP BY order_ref 
;


-- MCBDATAM.XXBCM_INVOICES_GRP source

CREATE OR REPLACE  VIEW XXBCM_INVOICES_GRP (ORDER_LINE_ID, INVOICE_REFERENCES) AS 
  SELECT 
  ORDER_LINE_ID, 
  LISTAGG(INVOICE_REFERENCE, '|') WITHIN GROUP (ORDER BY INVOICE_REFERENCE) AS invoice_references
FROM 
  XXBCM_INVOICES
GROUP BY 
  ORDER_LINE_ID;
  
  
-- MCBDATAM.VIEW_GLOBAL source

CREATE OR REPLACE  VIEW VIEW_GLOBAL (ORDER_REFERENCE, ORDER_DATE, ORDER_DATE_DATE, ORDER_DESCRIPTION, ORDER_TOTAL_AMOUNT, ORDER_TOTAL_AMOUNT_NBR, ORDER_STATUS, SUPPLIER_NAME, INVOICE_REFERENCE, INVOICE_AMOUNT, ACTION, SUPPLIER_ID, INVOICE_REFERENCES_CONCAT) AS 
  SELECT 
      	TO_NUMBER(REGEXP_SUBSTR(xo.order_ref, '\d+')) AS order_reference,
      	TO_CHAR(xo.order_date, 'MON-YYYY') AS ORDER_date,
      	xo.order_date AS order_date_date,
      	ORDER_description,
      	 TO_CHAR(order_total_amount, 'FM999,999,999.00')
        AS 	order_total_amount,
        order_total_amount AS order_total_amount_nbr,
      	order_status,
      	INITCAP(xs.supplier_name) AS supplier_name,
      	vgo.invoice_reference,
         TO_CHAR(vgo.invoice_amount, 'FM999,999,999.00') AS invoice_amount,
         get_invoice_status_action(xo.order_id) AS ACTION ,
         xs.supplier_id,
         INVOICE_REFERENCES_concat
      	FROM 
      	XXBCM_ORDERS xo,
      	XXBCM_SUPPLIERS xs ,
      	v_XXBCM_INVOICES_grp_order vgo
      	WHERE 
      		xo.supplier_id=xs.supplier_id(+)
      		AND xo.order_ref= vgo.order_ref (+)
      	ORDER BY xo.order_date desc
      	;


-- MCBDATAM.VIEW_GLOBAL_GRP_SUPP source

CREATE OR REPLACE  VIEW VIEW_GLOBAL_GRP_SUPP (SUPPLIER_ID, ORDER_TOTAL_AMOUNT, TOTAL_ORDER) AS 
  SELECT supplier_id ,
sum(order_total_amount_nbr) AS order_total_amount ,
count(order_reference) AS total_order
FROM  VIEW_GLOBAL  v 
WHERE	v.order_date_date BETWEEN TO_DATE('01-JAN-2022', 'DD-MON-YYYY') AND TO_DATE('31-AUG-2022', 'DD-MON-YYYY')
GROUP BY supplier_id

;



-- MCBDATAM.SECOND_HIGHER_ORDER_AMOUNT source

CREATE OR REPLACE  VIEW SECOND_HIGHER_ORDER_AMOUNT (ORDER_REFERENCE, ORDER_DATE, SUPPLIER_NAME, ORDER_TOTAL_AMOUNT, ORDER_STATUS, INVOICE_REFERENCES) AS 
  SELECT ORDER_REFERENCE ,
       TO_CHAR(order_date_date, 'Month DD, YYYY') AS order_date ,
       SUPPLIER_NAME ,
       ORDER_TOTAL_AMOUNT ,
       ORDER_STATUS ,
       INVOICE_REFERENCEs_concat AS INVOICE_REFERENCEs
FROM (
    SELECT 
       vg.*,
        RANK() OVER (ORDER BY order_total_amount DESC) AS rnk -- Pas de conversion nécessaire ici
    FROM VIEW_GLOBAL vg 
)
WHERE rnk = 2;


CREATE OR REPLACE VIEW v_supplier_final AS 
      SELECT
	SUPPLIER_NAME,
	SUPP_CONTACT_NAME,
	refractor_contact(SUPP_CONTACT_1) AS SUPP_CONTACT_1,
	refractor_contact(SUPP_CONTACT_2) AS SUPP_CONTACT_2,
	              vog.total_order                    AS total_orders,
	             vog.order_total_amount                     AS order_total_amount                                  
FROM
	XXBCM_SUPPLIERS xs,
	VIEW_GLOBAL_grp_supp vog
WHERE xs.supplier_id = vog.supplier_id (+);
      



