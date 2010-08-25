
    create table database_inout (
        id int8 not null,
        db_alias varchar(255),
        col_x varchar(255),
        col_y varchar(255),
        database_name varchar(255),
        host_name text,
        instance varchar(255),
        name varchar(255) not null,
        password varchar(255),
        port int4,
        db_schema varchar(255),
        srs varchar(255),
        url varchar(255),
        username varchar(255),
        type_id int4 not null,
        primary key (id)
    );

    create table database_type (
        id int4 not null,
        name varchar(255) not null,
        primary key (id)
    );

    create table file_inout (
        id int8 not null,
        directory varchar(255) not null,
        is_directory bool not null,
        name varchar(255) not null,
        primary key (id)
    );

    create table inout_datatype (
        id int4 not null,
        name varchar(255),
        primary key (id)
    );

    create table inout_type (
        id int4 not null,
        name varchar(255),
        primary key (id)
    );

    create table input_output (
        id int8 not null,
        name varchar(255) not null,
        table_name varchar(255),
        database_id int8,
        datatype_id int4 not null,
        file_id int8,
        type_id int4 not null,
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

    create table process (
        id int8 not null,
        actions text not null,
        drop_table bool not null,
        features_end int4,
        features_start int4,
        name varchar(255) not null,
        writer_type varchar(255) not null,
        input_id int8 not null,
        mail_id int8 not null,
        output_id int8 not null,
        schedule int8,
        primary key (id)
    );

    create table schedule (
        id int8 not null,
        cron_expression varchar(120) not null,
        from_date date,
        job_name varchar(120) not null,
        schedule_type int4 not null,
        primary key (id)
    );

    create table schedule_type (
        id int4 not null,
        type varchar(2147483647) not null,
        primary key (id)
    );

    alter table database_inout 
        add constraint FK648E8045BD40A631 
        foreign key (type_id) 
        references database_type;

    alter table input_output 
        add constraint FK3D1347161C5BF2D6 
        foreign key (file_id) 
        references file_inout;

    alter table input_output 
        add constraint FK3D134716341B5076 
        foreign key (database_id) 
        references database_inout;

    alter table input_output 
        add constraint FK3D1347167E2A0A07 
        foreign key (type_id) 
        references inout_type;

    alter table input_output 
        add constraint FK3D13471669090347 
        foreign key (datatype_id) 
        references inout_datatype;

    alter table process 
        add constraint FKED8D1E6F4594B9CA 
        foreign key (schedule) 
        references schedule;

    alter table process 
        add constraint FKED8D1E6F1CCF9206 
        foreign key (output_id) 
        references input_output;

    alter table process 
        add constraint FKED8D1E6F80DCC4F6 
        foreign key (mail_id) 
        references mail;

    alter table process 
        add constraint FKED8D1E6FB72FF29D 
        foreign key (input_id) 
        references input_output;

    alter table schedule 
        add constraint FKD6669297B4BB14EF 
        foreign key (schedule_type) 
        references schedule_type;

    create sequence hibernate_sequence;
	
--
-- TOC entry 1927 (class 0 OID 33351)
-- Dependencies: 1539
-- Data for Name: database_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO database_type (id, name) VALUES (1, 'oracle');
INSERT INTO database_type (id, name) VALUES (2, 'msaccess');
INSERT INTO database_type (id, name) VALUES (3, 'postgis');


--
-- TOC entry 1929 (class 0 OID 33467)
-- Dependencies: 1545
-- Data for Name: inout_datatype; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO inout_datatype (id, name) VALUES (1, 'database_inout');
INSERT INTO inout_datatype (id, name) VALUES (2, 'file_inout');


--
-- TOC entry 1928 (class 0 OID 33408)
-- Dependencies: 1541
-- Data for Name: inout_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO inout_type (id, name) VALUES (1, 'input');
INSERT INTO inout_type (id, name) VALUES (2, 'output');


--
-- TOC entry 1944 (class 0 OID 34782)
-- Dependencies: 1565
-- Data for Name: schedule_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO schedule_type (id, type) VALUES (1, 'hour');
INSERT INTO schedule_type (id, type) VALUES (2, 'day');
INSERT INTO schedule_type (id, type) VALUES (3, 'week');
INSERT INTO schedule_type (id, type) VALUES (4, 'month');
INSERT INTO schedule_type (id, type) VALUES (5, 'year');
INSERT INTO schedule_type (id, type) VALUES (6, 'advanced');


