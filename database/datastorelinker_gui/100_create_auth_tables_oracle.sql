-- create tables
create table organization (
        id number(10,0) not null,
        name varchar2(255 char) not null,
        upload_path varchar2(255 char) not null,
        primary key (id)
    );

create table users (
        id number(10,0) not null,
        is_admin number(1,0) not null,
        name varchar2(255 char) not null,
        password varchar2(255 char) not null,
        primary key (id)
    );

create table organization_users (
        organization_id number(10,0),
        users_id number(10,0) not null,
        primary key (users_id)
    );

 create table output_organization (
        organization_id number(10,0) not null,
        output_id number(19,0) not null
    );

alter table organization_users add constraint FKDABFEBFCA0C96776 foreign key (organization_id) references organization;
alter table organization_users add constraint FKDABFEBFC8BF8659E foreign key (users_id) references users;
alter table output_organization add constraint FK7301A7B1A0C96776 foreign key (organization_id) references organization;
alter table output_organization add constraint FK7301A7B11CCF9206 foreign key (output_id) references input_output;
	
-- sequences
create sequence organization_id_seq;
create sequence users_id_seq;
create sequence organization_users_id_seq;
create sequence output_organization_id_seq;

-- insert default beheerder // beheerder account
insert into organization(id, name, upload_path) values (1, 'Beheerders', '/');
insert into users(id, name, password, is_admin) values (1, 'beheerder', '1ZkPjF0ZNpQOXRr0TImwog%3D%3D', 1);
insert into organization_users(organization_id, users_id) values (1, 1);

-- alter existing tables
alter table process add (organization_id number(10,0));
alter table process add (user_id number(10,0));

alter table input_output add (organization_id number(10,0));
alter table input_output add (user_id number(10,0));
alter table input_output add (template_output varchar2(255 char));

alter table database_inout add (organization_id number(10,0));
alter table database_inout add (user_id number(10,0));

-- update all existing to beheerder organization and user
update process set organization_id = 1, user_id = 1;
update input_output set organization_id = 1, user_id = 1;
update input_output set template_output = 'NO_TABLE';
update database_inout set organization_id = 1, user_id = 1;