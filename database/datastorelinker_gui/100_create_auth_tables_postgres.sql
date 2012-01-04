-- create tables
create table organization (
	id integer not null,
	name varchar(255) not null,
	upload_path varchar(255) not null,
	primary key (id)
);

create table users(
	id integer not null,
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

-- insert default beheerder // beheerder account
insert into organization(id, name, upload_path) values (1, 'Beheerders', '/');
insert into users(id, name, password, is_admin) values (1, 'beheerder', '1ZkPjF0ZNpQOXRr0TImwog%3D%3D', true);
insert into organization_users(organization_id, users_id) values (1, 1);