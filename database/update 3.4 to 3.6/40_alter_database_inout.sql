-- $Id: 01_update_append_table.sql 22150 2011-12-20 19:24:51Z Matthijs $
-- Oracle
alter table database_inout ADD (webservice_db NUMBER(1,0));
update database_inout set webservice_db = 0;

-- PostgreSQL
ALTER TABLE database_inout ADD COLUMN webservice_db boolean;
update database_inout set webservice_db = false;
