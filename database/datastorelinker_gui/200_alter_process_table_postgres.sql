-- add username and remarks columns to show in process overview
alter table process add column user_name varchar(255);
alter table process add column remarks varchar(255);