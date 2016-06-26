-----------------------
\echo id is :id
-----------------------
\set
-----------------------
\d authority
\d trader
\d asset1
-----------------------
xdrop table voter;
create table voter (
    gmail   varchar    not null primary key,
    rejoin  varchar(1) not null check (rejoin in ('I','X')),
    vote_ts timestamp  not null default now(),
    join_ts timestamp  not null default now(),
    ip      inet       not null,
    name    varchar    not null
)
-----------------------------------
xdrop table outcome;
create table outcome (
    id   serial  primary key,
    memo varchar,
    stay integer not null,
    quit integer not null
);
insert into outcome (memo, stay, quit) values ('totals', 0, 0);
select * from outcome
-----------------------------------
create table feedback (
)
-----------------------------------
select * from voter;
select * from outcome;
select * from feedback;
-----------------------------------
drop table feedback;
create table feedback (
    gmail varchar references voter,
    ts timestamp default now(),
    words text not null,
    cleared boolean default('f') not null
)
-----------------------
