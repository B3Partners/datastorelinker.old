
    create table database_inout (
        id number(19,0) not null,
        db_alias varchar2(255 char),
        col_x varchar2(255 char),
        col_y varchar2(255 char),
        database_name varchar2(255 char),
        host_name varchar2(255 char),
        name varchar2(255 char),
        password varchar2(255 char),
        port number(10,0),
        db_schema varchar2(255 char),
        srs varchar2(255 char),
        database_type varchar2(255 char) not null,
        inout_type varchar2(255 char) not null,
        url varchar2(255 char),
        username varchar2(255 char),
        primary key (id)
    );

    create table input_output (
        id number(19,0) not null,
        input_output_datatype varchar2(255 char) not null,
        file_name varchar2(255 char),
        name varchar2(255 char),
        srs varchar2(255 char),
        table_name varchar2(255 char),
        input_output_type varchar2(255 char) not null,
        database_id number(19,0),
        primary key (id)
    );

    create table mail (
        id number(19,0) not null,
        from_email_address varchar2(255 char),
        smtp_host varchar2(255 char) not null,
        subject varchar2(255 char),
        to_email_address varchar2(255 char) not null,
        primary key (id)
    );

    create table process (
        id number(19,0) not null,
        actions clob not null,
        drop_table number(1,0) not null,
        features_end number(10,0),
        features_start number(10,0),
        name varchar2(255 char),
        writer_type varchar2(255 char) not null,
        input_id number(19,0) not null,
        mail_id number(19,0) not null,
        output_id number(19,0) not null,
        process_status_id number(19,0) not null,
        schedule number(19,0),
        primary key (id)
    );

    create table process_status (
        id number(19,0) not null,
        executing_job_uuid varchar2(255 char),
        message clob,
        process_status_type varchar2(255 char) not null,
        primary key (id)
    );

    create table schedule (
        id number(19,0) not null,
        cron_expression varchar2(120 char) not null,
        from_date date,
        job_name varchar2(120 char) not null,
        schedule_type varchar2(255 char) not null,
        primary key (id)
    );

    alter table input_output 
        add constraint FK3D134716341B5076 
        foreign key (database_id) 
        references database_inout;

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
