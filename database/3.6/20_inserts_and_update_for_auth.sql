-- insert default beheerder // beheerder account
insert into organization(id, name, upload_path) values (1, 'Beheerders', '/');
insert into users(id, name, password, is_admin) values (1, 'beheerder', '1ZkPjF0ZNpQOXRr0TImwog%3D%3D', true);
insert into organization_users(organization_id, users_id) values (1, 1);

-- update all existing to beheerder organization and user
update process set organization_id = 1, user_id = 1;
update input_output set organization_id = 1, user_id = 1;
update input_output set template_output = 'NO_TABLE';
update database_inout set organization_id = 1, user_id = 1;