
    create table database_inout (
        id int8 not null,
        db_alias varchar(255),
        col_x varchar(255),
        col_y varchar(255),
        database_name varchar(255),
        host_name varchar(255),
        name varchar(255),
        organization_id int4,
        password varchar(255),
        port int4,
        db_schema varchar(255),
        srs varchar(255),
        database_type varchar(255) not null,
        inout_type varchar(255) not null,
        url varchar(255),
        user_id int4,
        username varchar(255),
        webservice_db bool not null,
        primary key (id)
    );

    create table input_output (
        id int8 not null,
        input_output_datatype varchar(255) not null,
        file_name varchar(255),
        name varchar(255),
        organization_id int4,
        srs varchar(255),
        table_name varchar(255),
        template_output varchar(255),
        input_output_type varchar(255) not null,
        user_id int4,
        database_id int8,
        primary key (id)
    );

    create table mail (
        id int8 not null,
        from_email_address varchar(255),
        smtp_host varchar(255) not null,
        subject varchar(255),
        to_email_address varchar(255) not null,
        primary key (id)
    );

    create table organization (
        id int4 not null,
        name varchar(255) not null,
        upload_path varchar(255) not null,
        primary key (id)
    );

    create table organization_users (
        organization_id int4,
        users_id int4 not null,
        primary key (users_id),
        unique (users_id)
    );

    create table output_organization (
        organization_id int4 not null,
        output_id int8 not null
    );

    create table process (
        id int8 not null,
        actions text not null,
        append_table bool not null,
        drop_table bool not null,
        features_end int4,
        features_start int4,
        name varchar(255),
        organization_id int4,
        remarks varchar(255),
        user_id int4,
        user_name varchar(255),
        writer_type varchar(255) not null,
        input_id int8 not null,
        mail_id int8 not null,
        output_id int8 not null,
        process_status_id int8 not null,
        schedule int8,
        primary key (id)
    );

    create table process_status (
        id int8 not null,
        executing_job_uuid varchar(255),
        message text,
        process_status_type varchar(255) not null,
        primary key (id)
    );

    create table schedule (
        id int8 not null,
        cron_expression varchar(120) not null,
        from_date date,
        job_name varchar(120) not null,
        schedule_type varchar(255) not null,
        primary key (id)
    );

    create table users (
        id int4 not null,
        is_admin bool not null,
        name varchar(255) not null,
        password varchar(255) not null,
        primary key (id)
    );

    alter table input_output 
        add constraint FK3D134716341B5076 
        foreign key (database_id) 
        references database_inout;

    alter table organization_users 
        add constraint FKDABFEBFCA0C96776 
        foreign key (organization_id) 
        references organization;

    alter table organization_users 
        add constraint FKDABFEBFC8BF8659E 
        foreign key (users_id) 
        references users;

    alter table output_organization 
        add constraint FK7301A7B1A0C96776 
        foreign key (organization_id) 
        references organization;

    alter table output_organization 
        add constraint FK7301A7B11CCF9206 
        foreign key (output_id) 
        references input_output;

    alter table process 
        add constraint FKED8D1E6F4594B9CA 
        foreign key (schedule) 
        references schedule;

    alter table process 
        add constraint FKED8D1E6F1CCF9206 
        foreign key (output_id) 
        references input_output;

    alter table process 
        add constraint FKED8D1E6F5B1356DD 
        foreign key (process_status_id) 
        references process_status;

    alter table process 
        add constraint FKED8D1E6F80DCC4F6 
        foreign key (mail_id) 
        references mail;

    alter table process 
        add constraint FKED8D1E6FB72FF29D 
        foreign key (input_id) 
        references input_output;

    create sequence hibernate_sequence;
