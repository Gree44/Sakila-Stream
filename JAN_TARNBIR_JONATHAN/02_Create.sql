SET search_path TO sakila;

--
-- Table structure for table `content_type`
--
CREATE TABLE content_type (
  content_type_id SMALLINT    NOT NULL,
  content_ty_name VARCHAR(64) NOT NULL,
  additional_info VARCHAR(255),
  CONSTRAINT pk_content_type PRIMARY KEY (content_type_id)
);

--
-- Table structure for table `content_stream`
--
CREATE TABLE content_stream (
  content_id            INTEGER      NOT NULL,
  content_type_id       SMALLINT     NOT NULL,
  title                 VARCHAR(128) NOT NULL,
  release_year          SMALLINT     NOT NULL,
  original_language_id  SMALLINT     NOT NULL,
  spot_watch_price      DECIMAL(4,2) NOT NULL,
  length                SMALLINT     NOT NULL,
  stream_uuid           UUID         NOT NULL,
  imdb_title_key        VARCHAR(15)  NOT NULL,
  CONSTRAINT pk_content_stream PRIMARY KEY (content_id),
  CONSTRAINT fk_content_stream_content_type
    FOREIGN KEY (content_type_id)
      REFERENCES content_type (content_type_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_content_stream_language
    FOREIGN KEY (original_language_id)
      REFERENCES language (language_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_content_stream_fk_content_type_id
  ON content_stream (content_type_id);

CREATE INDEX idx_content_stream_fk_original_language_id
  ON content_stream (original_language_id);


--
-- Table structure for table `franchise`
--
CREATE TABLE franchise (
  franchise_id        SMALLINT   NOT NULL,
  start_content_id    INTEGER    NOT NULL,
  franchise_name      VARCHAR(80)  NOT NULL,
  franchise_descr     VARCHAR(255) NOT NULL,
  CONSTRAINT pk_franchise PRIMARY KEY (franchise_id),
  CONSTRAINT fk_franchise_start_content
    FOREIGN KEY (start_content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_franchise_fk_start_content_id
  ON franchise (start_content_id);


--
-- Table structure for table `content_language`
--
CREATE TABLE content_language (
  content_id   INTEGER   NOT NULL,
  language_id  SMALLINT  NOT NULL,
  CONSTRAINT pk_content_language PRIMARY KEY (content_id, language_id),
  CONSTRAINT fk_content_language_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_content_language_language
    FOREIGN KEY (language_id)
      REFERENCES language (language_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_content_language_fk_language_id
  ON content_language (language_id);


--
-- Table structure for table `video_quality`
--
CREATE TABLE video_quality (
  video_quality_id  SMALLINT      NOT NULL,
  vidquality_label  VARCHAR(5)    NOT NULL,
  vidquality_descr  VARCHAR(20)   NOT NULL,
  CONSTRAINT pk_video_quality PRIMARY KEY (video_quality_id)
);

--
-- Table structure for table `service_type`
--
CREATE TABLE service_type (
  service_type_id    SMALLINT   NOT NULL,
  service_type_name  VARCHAR(128) NOT NULL,
  CONSTRAINT pk_service_type PRIMARY KEY (service_type_id)
);

--
-- Table structure for table `video_quality_price`
--
CREATE TABLE video_quality_price (
  service_type_id    SMALLINT     NOT NULL,
  video_quality_id   SMALLINT     NOT NULL,
  vid_quality_price  DECIMAL(4,2) NOT NULL,
  CONSTRAINT pk_video_quality_price PRIMARY KEY (service_type_id, video_quality_id),
  CONSTRAINT fk_vqp_service_type
    FOREIGN KEY (service_type_id)
      REFERENCES service_type (service_type_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vqp_video_quality
    FOREIGN KEY (video_quality_id)
      REFERENCES video_quality (video_quality_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_vqp_fk_video_quality_id
  ON video_quality_price (video_quality_id);


--
-- Table structure for table `srv_customer_allocation`
--
CREATE TABLE srv_customer_allocation (
  srv_cust_alloc_id  BIGINT      NOT NULL,
  service_type_id    SMALLINT    NOT NULL,
  srv_reference_id   BIGINT      NOT NULL,
  customer_id        INTEGER     NOT NULL,
  video_quality      SMALLINT    NOT NULL,
  start_date         TIMESTAMP   NOT NULL,
  end_date           TIMESTAMP,
  active             BOOLEAN     NOT NULL DEFAULT TRUE,
  last_update        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_srv_customer_allocation PRIMARY KEY (srv_cust_alloc_id),
  CONSTRAINT fk_sca_service_type
    FOREIGN KEY (service_type_id)
      REFERENCES service_type (service_type_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sca_reference
    FOREIGN KEY (srv_reference_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sca_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sca_video_quality
    FOREIGN KEY (video_quality)
      REFERENCES video_quality (video_quality_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_sca_fk_service_type_id
  ON srv_customer_allocation (service_type_id);

CREATE INDEX idx_sca_fk_reference_id
  ON srv_customer_allocation (srv_reference_id);

CREATE INDEX idx_sca_fk_customer_id
  ON srv_customer_allocation (customer_id);

CREATE INDEX idx_sca_fk_video_quality
  ON srv_customer_allocation (video_quality);





--
-- Table structure for table `billing_head`
--
CREATE TABLE billing_head (
  billing_id    BIGINT     NOT NULL,
  customer_id   INTEGER    NOT NULL,
  billing_date  DATE       NOT NULL,
  last_update   TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_billing_head PRIMARY KEY (billing_id),
  CONSTRAINT fk_billing_head_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_billing_head_fk_customer_id
  ON billing_head (customer_id);


--
-- Table structure for table `billing_item`
--
CREATE TABLE billing_item (
  billing_id         BIGINT      NOT NULL,
  billing_item_id    BIGINT      NOT NULL,
  srv_cust_alloc_id  BIGINT      NOT NULL,
  service_type_id    SMALLINT    NOT NULL,
  amount             DECIMAL(5,2) NOT NULL,
  last_update        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_billing_item PRIMARY KEY (billing_id, billing_item_id),
  CONSTRAINT fk_bitem_billing_head
    FOREIGN KEY (billing_id)
      REFERENCES billing_head (billing_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_bitem_sca
    FOREIGN KEY (srv_cust_alloc_id)
      REFERENCES srv_customer_allocation (srv_cust_alloc_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_bitem_service_type
    FOREIGN KEY (service_type_id)
      REFERENCES service_type (service_type_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_billing_item_fk_sca_id
  ON billing_item (srv_cust_alloc_id);

CREATE INDEX idx_billing_item_fk_service_type_id
  ON billing_item (service_type_id);


--
-- Table structure for table `subscription`
--
CREATE TABLE subscription (
  subscr_id        SMALLINT     NOT NULL,
  subscr_name      VARCHAR(128) NOT NULL,
  additional_info  VARCHAR(255),
  price            DECIMAL(4,2) NOT NULL,
  CONSTRAINT pk_subscription PRIMARY KEY (subscr_id)
);


--
-- Table structure for table `package`
--
CREATE TABLE package (
  package_id       SMALLINT     NOT NULL,
  category_id      SMALLINT     NOT NULL,
  additional_info  VARCHAR(255),
  price            DECIMAL(4,2) NOT NULL,
  CONSTRAINT pk_package PRIMARY KEY (package_id),
  CONSTRAINT fk_package_category
    FOREIGN KEY (category_id)
      REFERENCES category (category_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_package_fk_category_id
  ON package (category_id);


--
-- Table structure for table `package_content`
--
CREATE TABLE package_content (
  package_id  SMALLINT  NOT NULL,
  content_id  INTEGER   NOT NULL,
  CONSTRAINT pk_package_content PRIMARY KEY (package_id, content_id),
  CONSTRAINT fk_pkgcontent_package
    FOREIGN KEY (package_id)
      REFERENCES package (package_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pkgcontent_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_package_content_fk_content_id
  ON package_content (content_id);

--
-- Table structure for table `customer_watchlist`
--
CREATE TABLE customer_watchlist (
  watchlist_id   INTEGER     NOT NULL,
  customer_id    INTEGER     NOT NULL,
  creation_date  TIMESTAMP   NOT NULL,
  name           VARCHAR(25) NOT NULL,
  description    VARCHAR(255),
  last_update    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_customer_watchlist PRIMARY KEY (watchlist_id),
  CONSTRAINT fk_customer_watchlist_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_customer_watchlist_fk_customer_id
  ON customer_watchlist (customer_id);


--
-- Table structure for table `cust_watchlist_item`
--
CREATE TABLE cust_watchlist_item (
  watchlist_id  INTEGER    NOT NULL,
  content_id    INTEGER    NOT NULL,
  seq_num       SMALLINT   NOT NULL,
  last_update   TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_cust_watchlist_item PRIMARY KEY (watchlist_id, content_id),
  CONSTRAINT fk_cust_watchlist_item_watchlist
    FOREIGN KEY (watchlist_id)
      REFERENCES customer_watchlist (watchlist_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cust_watchlist_item_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_cust_watchlist_item_fk_content_id
  ON cust_watchlist_item (content_id);

--
-- Table structure for table `cust_watch_act`
--
CREATE TABLE cust_watch_act (
  cust_watch_act_id  BIGINT     NOT NULL,
  customer_id        INTEGER    NOT NULL,
  content_id         INTEGER    NOT NULL,
  start_date         TIMESTAMP  NOT NULL,
  time_index_seconds SMALLINT   NOT NULL,
  completion_date    TIMESTAMP,
  last_update        TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_cust_watch_act PRIMARY KEY (cust_watch_act_id),
  CONSTRAINT fk_cust_watch_act_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cust_watch_act_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_cust_watch_act_fk_customer_id
  ON cust_watch_act (customer_id);

CREATE INDEX idx_cust_watch_act_fk_content_id
  ON cust_watch_act (content_id);


--
-- Table structure for table `content_country_restricted`
--
CREATE TABLE content_country_restricted (
  country_id SMALLINT NOT NULL,
  content_id INTEGER  NOT NULL,
  CONSTRAINT pk_content_country_restricted PRIMARY KEY (country_id, content_id),
  CONSTRAINT fk_ccr_country
    FOREIGN KEY (country_id)
      REFERENCES country (country_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ccr_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_ccr_fk_content_id
  ON content_country_restricted (content_id);


--
-- Table structure for table `binge_flow`
--
CREATE TABLE binge_flow (
  current_id     INTEGER   NOT NULL,
  next_content   INTEGER   NOT NULL,
  franchise_id   SMALLINT  NOT NULL,
  CONSTRAINT pk_binge_flow PRIMARY KEY (current_id, next_content),
  CONSTRAINT fk_binge_flow_current
    FOREIGN KEY (current_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_binge_flow_next
    FOREIGN KEY (next_content)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_binge_flow_franchise
    FOREIGN KEY (franchise_id)
      REFERENCES franchise (franchise_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);



CREATE INDEX idx_binge_flow_fk_next_content
  ON binge_flow (next_content);

CREATE INDEX idx_binge_flow_fk_franchise_id
  ON binge_flow (franchise_id);
