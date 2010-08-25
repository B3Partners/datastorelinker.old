--
-- PostgreSQL database dump
--

-- Started on 2010-07-15 15:59:05


--
-- TOC entry 1535 (class 1259 OID 33326)
-- Dependencies: 3
-- Name: database; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE database_inout (
    id bigint NOT NULL,
    type_id integer NOT NULL,
    name character varying NOT NULL,
    host_name character varying,
    database_name character varying,
    username character varying,
    password character varying,
    db_schema character varying,
    port integer,
    instance character varying,
    db_alias character varying,
    url character varying,
    srs character varying,
    col_x character varying,
    col_y character varying
);


--
-- TOC entry 1539 (class 1259 OID 33351)
-- Dependencies: 3
-- Name: database_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE database_type (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 1536 (class 1259 OID 33329)
-- Dependencies: 3
-- Name: file; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE file_inout (
    name character varying NOT NULL,
    id bigint NOT NULL,
    directory character varying NOT NULL,
    is_directory boolean DEFAULT false NOT NULL
);


--
-- TOC entry 1534 (class 1259 OID 33317)
-- Dependencies: 3
-- Name: inout; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE input_output (
    id bigint NOT NULL,
    type_id integer NOT NULL,
    datatype_id integer NOT NULL,
    table_name character varying,
    database_id bigint,
    file_id bigint,
    name character varying NOT NULL
);


--
-- TOC entry 1545 (class 1259 OID 33467)
-- Dependencies: 3
-- Name: inout_datatype; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inout_datatype (
    id integer NOT NULL,
    name character varying
);


--
-- TOC entry 1541 (class 1259 OID 33408)
-- Dependencies: 3
-- Name: inout_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inout_type (
    id integer NOT NULL,
    name character varying
);


--
-- TOC entry 1561 (class 1259 OID 34273)
-- Dependencies: 3
-- Name: mail; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mail (
    id bigint NOT NULL,
    smtp_host character varying NOT NULL,
    to_email_address character varying NOT NULL,
    subject character varying,
    from_email_address character varying
);


--
-- TOC entry 1533 (class 1259 OID 33311)
-- Dependencies: 1832 1834 3
-- Name: process; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE process (
    id bigint NOT NULL,
    input_id bigint NOT NULL,
    output_id bigint NOT NULL,
    name character varying NOT NULL,
    actions character varying,
    features_start integer,
    features_end integer,
    mail_id bigint,
    drop_table boolean DEFAULT true NOT NULL,
    writer_type character varying DEFAULT 'ActionCombo_GeometrySplitter_Writer'::character varying NOT NULL,
    schedule bigint
);


--
-- TOC entry 1563 (class 1259 OID 34765)
-- Dependencies: 1843 3
-- Name: schedule; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedule (
    id bigint NOT NULL,
    schedule_type integer DEFAULT 6 NOT NULL,
    cron_expression character varying(120) NOT NULL,
    from_date date,
    job_name character varying(120) NOT NULL
);


--
-- TOC entry 1565 (class 1259 OID 34782)
-- Dependencies: 3
-- Name: schedule_type; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedule_type (
    id integer NOT NULL,
    type character varying NOT NULL
);


--
-- TOC entry 1540 (class 1259 OID 33375)
-- Dependencies: 1535 3
-- Name: database_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE database_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1950 (class 0 OID 0)
-- Dependencies: 1540
-- Name: database_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE database_id_seq OWNED BY database_inout.id;


--
-- TOC entry 1951 (class 0 OID 0)
-- Dependencies: 1540
-- Name: database_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('database_id_seq', 28, true);


--
-- TOC entry 1538 (class 1259 OID 33349)
-- Dependencies: 1539 3
-- Name: database_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE database_type_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1952 (class 0 OID 0)
-- Dependencies: 1538
-- Name: database_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE database_type_id_seq OWNED BY database_type.id;


--
-- TOC entry 1953 (class 0 OID 0)
-- Dependencies: 1538
-- Name: database_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('database_type_id_seq', 3, true);


--
-- TOC entry 1537 (class 1259 OID 33335)
-- Dependencies: 3 1536
-- Name: file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1954 (class 0 OID 0)
-- Dependencies: 1537
-- Name: file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_id_seq OWNED BY file_inout.id;


--
-- TOC entry 1955 (class 0 OID 0)
-- Dependencies: 1537
-- Name: file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('file_id_seq', 67, true);


--
-- TOC entry 1544 (class 1259 OID 33465)
-- Dependencies: 1545 3
-- Name: inout_datatype_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inout_datatype_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1956 (class 0 OID 0)
-- Dependencies: 1544
-- Name: inout_datatype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inout_datatype_id_seq OWNED BY inout_datatype.id;


--
-- TOC entry 1957 (class 0 OID 0)
-- Dependencies: 1544
-- Name: inout_datatype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('inout_datatype_id_seq', 2, true);


--
-- TOC entry 1547 (class 1259 OID 33590)
-- Dependencies: 3 1534
-- Name: inout_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inout_file_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1958 (class 0 OID 0)
-- Dependencies: 1547
-- Name: inout_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inout_file_id_seq OWNED BY input_output.file_id;


--
-- TOC entry 1959 (class 0 OID 0)
-- Dependencies: 1547
-- Name: inout_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('inout_file_id_seq', 2, true);


--
-- TOC entry 1542 (class 1259 OID 33411)
-- Dependencies: 1534 3
-- Name: inout_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inout_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1960 (class 0 OID 0)
-- Dependencies: 1542
-- Name: inout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inout_id_seq OWNED BY input_output.id;


--
-- TOC entry 1961 (class 0 OID 0)
-- Dependencies: 1542
-- Name: inout_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('inout_id_seq', 45, true);


--
-- TOC entry 1543 (class 1259 OID 33428)
-- Dependencies: 1541 3
-- Name: inout_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inout_type_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1962 (class 0 OID 0)
-- Dependencies: 1543
-- Name: inout_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inout_type_id_seq OWNED BY inout_type.id;


--
-- TOC entry 1963 (class 0 OID 0)
-- Dependencies: 1543
-- Name: inout_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('inout_type_id_seq', 2, true);


--
-- TOC entry 1560 (class 1259 OID 34271)
-- Dependencies: 3 1561
-- Name: mail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1964 (class 0 OID 0)
-- Dependencies: 1560
-- Name: mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mail_id_seq OWNED BY mail.id;


--
-- TOC entry 1965 (class 0 OID 0)
-- Dependencies: 1560
-- Name: mail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('mail_id_seq', 1, false);


--
-- TOC entry 1546 (class 1259 OID 33494)
-- Dependencies: 1533 3
-- Name: process_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE process_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1966 (class 0 OID 0)
-- Dependencies: 1546
-- Name: process_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE process_id_seq OWNED BY process.id;


--
-- TOC entry 1967 (class 0 OID 0)
-- Dependencies: 1546
-- Name: process_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('process_id_seq', 66, true);


--
-- TOC entry 1562 (class 1259 OID 34763)
-- Dependencies: 1563 3
-- Name: schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedule_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1968 (class 0 OID 0)
-- Dependencies: 1562
-- Name: schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedule_id_seq OWNED BY schedule.id;


--
-- TOC entry 1969 (class 0 OID 0)
-- Dependencies: 1562
-- Name: schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('schedule_id_seq', 8, true);


--
-- TOC entry 1564 (class 1259 OID 34780)
-- Dependencies: 1565 3
-- Name: schedule_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedule_type_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1970 (class 0 OID 0)
-- Dependencies: 1564
-- Name: schedule_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedule_type_id_seq OWNED BY schedule_type.id;


--
-- TOC entry 1971 (class 0 OID 0)
-- Dependencies: 1564
-- Name: schedule_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('schedule_type_id_seq', 6, true);


--
-- TOC entry 1836 (class 2604 OID 33377)
-- Dependencies: 1540 1535
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE database_inout ALTER COLUMN id SET DEFAULT nextval('database_id_seq'::regclass);


--
-- TOC entry 1838 (class 2604 OID 33354)
-- Dependencies: 1539 1538 1539
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE database_type ALTER COLUMN id SET DEFAULT nextval('database_type_id_seq'::regclass);


--
-- TOC entry 1837 (class 2604 OID 33337)
-- Dependencies: 1537 1536
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE file_inout ALTER COLUMN id SET DEFAULT nextval('file_id_seq'::regclass);


--
-- TOC entry 1835 (class 2604 OID 33695)
-- Dependencies: 1542 1534
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE input_output ALTER COLUMN id SET DEFAULT nextval('inout_id_seq'::regclass);


--
-- TOC entry 1840 (class 2604 OID 33470)
-- Dependencies: 1544 1545 1545
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE inout_datatype ALTER COLUMN id SET DEFAULT nextval('inout_datatype_id_seq'::regclass);


--
-- TOC entry 1839 (class 2604 OID 33696)
-- Dependencies: 1543 1541
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE inout_type ALTER COLUMN id SET DEFAULT nextval('inout_type_id_seq'::regclass);


--
-- TOC entry 1841 (class 2604 OID 34276)
-- Dependencies: 1560 1561 1561
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mail ALTER COLUMN id SET DEFAULT nextval('mail_id_seq'::regclass);


--
-- TOC entry 1833 (class 2604 OID 33496)
-- Dependencies: 1546 1533
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE process ALTER COLUMN id SET DEFAULT nextval('process_id_seq'::regclass);


--
-- TOC entry 1842 (class 2604 OID 34768)
-- Dependencies: 1563 1562 1563
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE schedule ALTER COLUMN id SET DEFAULT nextval('schedule_id_seq'::regclass);


--
-- TOC entry 1844 (class 2604 OID 34785)
-- Dependencies: 1564 1565 1565
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE schedule_type ALTER COLUMN id SET DEFAULT nextval('schedule_type_id_seq'::regclass);


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


--
-- TOC entry 1902 (class 2606 OID 34281)
-- Dependencies: 1561 1561
-- Name: mail_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mail
    ADD CONSTRAINT mail_pk PRIMARY KEY (id);


--
-- TOC entry 1850 (class 2606 OID 33391)
-- Dependencies: 1535 1535
-- Name: pk_database; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY database_inout
    ADD CONSTRAINT pk_database PRIMARY KEY (id);


--
-- TOC entry 1856 (class 2606 OID 33398)
-- Dependencies: 1539 1539
-- Name: pk_database_type; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY database_type
    ADD CONSTRAINT pk_database_type PRIMARY KEY (id);


--
-- TOC entry 1852 (class 2606 OID 33405)
-- Dependencies: 1536 1536
-- Name: pk_file; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY file_inout
    ADD CONSTRAINT pk_file PRIMARY KEY (id);


--
-- TOC entry 1848 (class 2606 OID 33464)
-- Dependencies: 1534 1534
-- Name: pk_inout; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY input_output
    ADD CONSTRAINT pk_inout PRIMARY KEY (id);


--
-- TOC entry 1862 (class 2606 OID 33475)
-- Dependencies: 1545 1545
-- Name: pk_inout_datatype; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inout_datatype
    ADD CONSTRAINT pk_inout_datatype PRIMARY KEY (id);


--
-- TOC entry 1860 (class 2606 OID 33453)
-- Dependencies: 1541 1541
-- Name: pk_inout_type; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inout_type
    ADD CONSTRAINT pk_inout_type PRIMARY KEY (id);


--
-- TOC entry 1846 (class 2606 OID 33519)
-- Dependencies: 1533 1533
-- Name: pk_process; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY process
    ADD CONSTRAINT pk_process PRIMARY KEY (id);


--
-- TOC entry 1904 (class 2606 OID 34771)
-- Dependencies: 1563 1563
-- Name: pk_schedule_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT pk_schedule_id PRIMARY KEY (id);


--
-- TOC entry 1906 (class 2606 OID 34790)
-- Dependencies: 1565 1565
-- Name: pk_schedule_type_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedule_type
    ADD CONSTRAINT pk_schedule_type_id PRIMARY KEY (id);



ALTER TABLE ONLY database_type
    ADD CONSTRAINT unique_database_type_name UNIQUE (name);


--
-- TOC entry 1854 (class 2606 OID 33407)
-- Dependencies: 1536 1536
-- Name: unique_file_dir_name; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY file_inout
    ADD CONSTRAINT unique_file_dir_name UNIQUE (name, directory);


--
-- TOC entry 1915 (class 2606 OID 33399)
-- Dependencies: 1539 1855 1535
-- Name: fk_database_database_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_inout
    ADD CONSTRAINT fk_database_database_type FOREIGN KEY (type_id) REFERENCES database_type(id);


--
-- TOC entry 1912 (class 2606 OID 33604)
-- Dependencies: 1535 1849 1534
-- Name: fk_inout_database; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY input_output
    ADD CONSTRAINT fk_inout_database FOREIGN KEY (database_id) REFERENCES database_inout(id);


--
-- TOC entry 1913 (class 2606 OID 33609)
-- Dependencies: 1851 1534 1536
-- Name: fk_inout_file; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY input_output
    ADD CONSTRAINT fk_inout_file FOREIGN KEY (file_id) REFERENCES file_inout(id);


--
-- TOC entry 1911 (class 2606 OID 33486)
-- Dependencies: 1861 1545 1534
-- Name: fk_inout_inout_datatype; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY input_output
    ADD CONSTRAINT fk_inout_inout_datatype FOREIGN KEY (datatype_id) REFERENCES inout_datatype(id);


--
-- TOC entry 1914 (class 2606 OID 34322)
-- Dependencies: 1859 1541 1534
-- Name: fk_inout_inout_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY input_output
    ADD CONSTRAINT fk_inout_inout_type FOREIGN KEY (type_id) REFERENCES inout_type(id);


--
-- TOC entry 1907 (class 2606 OID 33520)
-- Dependencies: 1534 1533 1847
-- Name: fk_process_input; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY process
    ADD CONSTRAINT fk_process_input FOREIGN KEY (input_id) REFERENCES input_output(id);


--
-- TOC entry 1909 (class 2606 OID 34305)
-- Dependencies: 1533 1901 1561
-- Name: fk_process_mail; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY process
    ADD CONSTRAINT fk_process_mail FOREIGN KEY (mail_id) REFERENCES mail(id);


--
-- TOC entry 1908 (class 2606 OID 33525)
-- Dependencies: 1847 1534 1533
-- Name: fk_process_output; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY process
    ADD CONSTRAINT fk_process_output FOREIGN KEY (output_id) REFERENCES input_output(id);


--
-- TOC entry 1910 (class 2606 OID 34796)
-- Dependencies: 1903 1533 1563
-- Name: fk_process_schedule; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY process
    ADD CONSTRAINT fk_process_schedule FOREIGN KEY (schedule) REFERENCES schedule(id);


--
-- TOC entry 1922 (class 2606 OID 34791)
-- Dependencies: 1565 1563 1905
-- Name: fk_schedule_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT fk_schedule_type FOREIGN KEY (schedule_type) REFERENCES schedule_type(id);


--
-- TOC entry 1949 (class 0 OID 0)
-- Dependencies: 3
-- Name: public; Type: ACL; Schema: -; Owner: -
--

--REVOKE ALL ON SCHEMA public FROM PUBLIC;
--REVOKE ALL ON SCHEMA public FROM postgres;
--GRANT ALL ON SCHEMA public TO postgres;
--GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2010-07-15 15:59:05

--
-- PostgreSQL database dump complete
--

