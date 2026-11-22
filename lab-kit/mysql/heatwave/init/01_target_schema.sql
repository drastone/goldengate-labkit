create database if not exists game_hw
  character set utf8mb4
  collate utf8mb4_0900_ai_ci;

create user if not exists 'mig_loader'@'%' identified by 'WElcome1234##';
grant all privileges on game_hw.* to 'mig_loader'@'%';
grant all privileges on game_hw.* to 'heatwave'@'%';

use game_hw;

create table if not exists migration_landing_note (
  id           bigint unsigned not null auto_increment,
  note         varchar(4000) not null,
  created_at   timestamp(6) not null default current_timestamp(6),
  primary key (id)
) engine=InnoDB;

insert into migration_landing_note(note)
values ('demo_myheat is a HeatWave-compatible MySQL target profile for offline App 101 migration demos.')
on duplicate key update note = values(note);

flush privileges;
