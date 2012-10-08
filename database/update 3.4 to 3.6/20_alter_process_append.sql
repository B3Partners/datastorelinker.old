-- $Id: 01_update_append_table.sql 22150 2011-12-20 19:24:51Z Matthijs $
-- Oracle
alter table process ADD (append_table NUMBER(1,0));
update process set append_table = 0;

-- PostgreSQL
ALTER TABLE process ADD COLUMN append_table boolean;
update process set append_table = false;
