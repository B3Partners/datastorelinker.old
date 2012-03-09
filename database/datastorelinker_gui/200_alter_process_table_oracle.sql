-- add username and remarks columns to show in process overview
alter table process add (user_name varchar2(255 char));
alter table process add (remarks varchar2(255 char));