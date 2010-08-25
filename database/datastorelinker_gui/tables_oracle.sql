
    create table database_inout (
        id number(19,0) not null,
        db_alias varchar2(255 char),
        col_x varchar2(255 char),
        col_y varchar2(255 char),
        database_name varchar2(255 char),
        host_name clob,
        instance varchar2(255 char),
        name varchar2(255 char) not null,
        password varchar2(255 char),
        port number(10,0),
        db_schema varchar2(255 char),
        srs varchar2(255 char),
        url varchar2(255 char),
        username varchar2(255 char),
        type_id number(10,0) not null,
        primary key (id)
    );

    create table database_type (
        id number(10,0) not null,
        name varchar2(255 char) not null,
        primary key (id)
    );

    create table file_inout (
        id number(19,0) not null,
        directory varchar2(255 char) not null,
        is_directory number(1,0) not null,
        name varchar2(255 char) not null,
        primary key (id)
    );

    create table input_output (
        id number(19,0) not null,
        name varchar2(255 char) not null,
        table_name varchar2(255 char),
        database_id number(19,0),
        datatype_id number(10,0) not null,
        file_id number(19,0),
        type_id number(10,0) not null,
        primary key (id)
    );

    create table inout_datatype (
        id number(10,0) not null,
        name varchar2(255 char),
        primary key (id)
    );

    create table inout_type (
        id number(10,0) not null,
        name varchar2(255 char),
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
        name varchar2(255 char) not null,
        writer_type varchar2(255 char) not null,
        input_id number(19,0) not null,
        mail_id number(19,0) not null,
        output_id number(19,0) not null,
        schedule number(19,0),
        primary key (id)
    );

    create table schedule (
        id number(19,0) not null,
        cron_expression varchar2(120 char) not null,
        from_date date,
        job_name varchar2(120 char) not null,
        schedule_type number(10,0) not null,
        primary key (id)
    );

    create table schedule_type (
        id number(10,0) not null,
        type long not null,
        primary key (id)
    );

    alter table database_inout 
        add constraint FK6AA9117BBD40A631 
        foreign key (type_id) 
        references database_type;

    alter table input_output 
        add constraint FK5FB54091C5BF2D6 
        foreign key (file_id) 
        references file_inout;

    alter table input_output 
        add constraint FK5FB5409341B5076 
        foreign key (database_id) 
        references database_inout;

    alter table input_output 
        add constraint FK5FB54097E2A0A07 
        foreign key (type_id) 
        references inout_type;

    alter table input_output 
        add constraint FK5FB540969090347 
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

