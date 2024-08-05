CREATE TABLE XXBCM_ORDERS 
   (	ORDER_ID NUMBER constraint XXBCM_ORDERS_pk PRIMARY KEY, 
	ORDER_REF VARCHAR2(50), 
	ORDER_DESCRIPTION VARCHAR2(2000), 
	ORDER_STATUS VARCHAR2(6), 
	ORDER_TOTAL_AMOUNT NUMBER(10,2), 
	SUPPLIER_ID NUMBER, 
	ORDER_Date date,
	 CHECK (order_status IN ('Open', 'Closed')) ENABLE,
	 CONSTRAINT FK_SUPPLIER FOREIGN KEY (SUPPLIER_ID)
	  REFERENCES XXBCM_SUPPLIERS (SUPPLIER_ID) ENABLE
   );
   
 CREATE TABLE XXBCM_ORDER_LINE 
   (	ORDER_LINE_ID NUMBER constraint XXBCM_ORDER_LINE_pk	 PRIMARY KEY, 
	ORDER_ID NUMBER, 
	ORDER_DESCRIPTION VARCHAR2(2000), 
	ORDER_LINE_AMOUNT NUMBER(10,2), 
	ORDER_STATUS VARCHAR2(100), 
	ORDER_LINE_REF VARCHAR2(100), 
  CHECK (order_status IN ('Received', 'Cancelled')) ENABLE, 
	 CONSTRAINT FK_ORDER FOREIGN KEY (ORDER_ID)
	  REFERENCES MCBDATAM.XXBCM_ORDERS (ORDER_ID) ENABLE
   )
 
CREATE SEQUENCE SEQ_orders
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER increment_orders_id_trigger
BEFORE INSERT ON XXBCM_orders
FOR EACH ROW
BEGIN
    :NEW.order_id := SEQ_orders.NEXTVAL;
	END;
	

	
CREATE SEQUENCE SEQ_orders_line
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER orders_line_id_trigger
BEFORE INSERT ON XXBCM_ORDER_LINE
FOR EACH ROW
BEGIN
    :NEW.order_line_id := SEQ_orders_line.NEXTVAL;
	END;
