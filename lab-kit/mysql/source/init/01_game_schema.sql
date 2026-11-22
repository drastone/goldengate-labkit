create database if not exists game
  character set utf8mb4
  collate utf8mb4_0900_ai_ci;

create user if not exists 'mig_reader'@'%' identified by 'WElcome1234##';
grant select, show view, reload, replication client, replication slave on *.* to 'mig_reader'@'%';
grant all privileges on game.* to 'game'@'%';

use game;

create table if not exists player_account (
  player_id        bigint unsigned not null auto_increment,
  player_code      varchar(64) not null,
  nickname         varchar(128) not null,
  email            varchar(255),
  country_code     char(2) not null,
  status           enum('ACTIVE','SUSPENDED','DELETED') not null default 'ACTIVE',
  vip_flag         tinyint(1) not null default 0,
  profile_json     json,
  created_at       timestamp(6) not null default current_timestamp(6),
  updated_at       timestamp(6) not null default current_timestamp(6) on update current_timestamp(6),
  primary key (player_id),
  unique key uk_player_account_code (player_code)
) engine=InnoDB;

create table if not exists purchase_order (
  order_id         bigint unsigned not null auto_increment,
  player_id        bigint unsigned not null,
  product_code     varchar(64) not null,
  order_status     varchar(30) not null,
  amount           decimal(18,4) not null,
  currency_code    char(3) not null,
  payload          json,
  receipt_blob     varbinary(2048),
  ordered_at       datetime(6) not null,
  primary key (order_id),
  key ix_purchase_order_player (player_id),
  constraint fk_purchase_order_player foreign key (player_id)
    references player_account(player_id)
) engine=InnoDB;

insert into player_account
  (player_code, nickname, email, country_code, status, vip_flag, profile_json)
values
  ('P000001', 'alpha', 'alpha@example.com', 'KR', 'ACTIVE', 1, json_object('level', 91, 'guild', 'red')),
  ('P000002', 'bravo', 'bravo@example.com', 'US', 'ACTIVE', 0, json_object('level', 44, 'guild', 'blue')),
  ('P000003', 'charlie', null, 'JP', 'SUSPENDED', 0, json_object('level', 12))
on duplicate key update nickname = values(nickname);

insert into purchase_order
  (player_id, product_code, order_status, amount, currency_code, payload, receipt_blob, ordered_at)
select player_id, 'GEM_1000', 'PAID', 9.9900, 'USD',
       json_object('channel', 'app', 'campaign', 'launch'),
       unhex('CAFE'), current_timestamp(6)
  from player_account
 where player_code = 'P000001'
on duplicate key update order_status = values(order_status);

flush privileges;
