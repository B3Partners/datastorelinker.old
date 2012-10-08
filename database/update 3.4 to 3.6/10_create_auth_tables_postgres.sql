-- create tables
create table organization (
	id serial,
	name varchar(255) not null,
	upload_path varchar(255) not null,
	primary key (id)
);

create table users (
	id serial,
	name varchar(255) not null,
	password varchar(255) not null,
	is_admin boolean not null DEFAULT false,
	primary key (id)
);

create table organization_users ( 
	organization_id integer NOT NULL default '0', 
	users_id integer UNIQUE NOT NULL, 
	PRIMARY KEY (organization_id, users_id),
	CONSTRAINT fk_users_id FOREIGN KEY (users_id) REFERENCES users (id), 
	CONSTRAINT fk_organization_id FOREIGN KEY (organization_id) REFERENCES organization (id) 
);

create table output_organization ( 
	output_id integer NOT NULL default '0', 
	organization_id integer NOT NULL, 
	PRIMARY KEY (output_id, organization_id),
	CONSTRAINT fk_output_id FOREIGN KEY (output_id) REFERENCES input_output (id), 
	CONSTRAINT fk_organization_id FOREIGN KEY (organization_id) REFERENCES organization (id) 
);

-- insert default beheerder // beheerder account
insert into organization(id, name, upload_path) values (1, 'Beheerders', '/');
insert into users(id, name, password, is_admin) values (1, 'beheerder', '1ZkPjF0ZNpQOXRr0TImwog%3D%3D', true);
insert into organization_users(organization_id, users_id) values (1, 1);

-- alter existing tables
alter table process add column organization_id integer;
alter table process add column user_id integer;

alter table input_output add column organization_id integer;
alter table input_output add column user_id integer;
alter table input_output add column template_output varchar(255);

alter table database_inout add column organization_id integer;
alter table database_inout add column user_id integer;

-- update all existing to beheerder organization and user
update process set organization_id = 1, user_id = 1;
update input_output set organization_id = 1, user_id = 1;
update input_output set template_output = 'NO_TABLE';
update database_inout set organization_id = 1, user_id = 1;