-- Add up migration script here
create type rsvp.reservation_status as enum ('unknown','pending','confirmed','blocked');
create type rsvp.reservation_update_type as enum ('unknown', 'create', 'update', 'delete');

create table rsvp.reservations
(
    id          uuid                    not null default gen_random_uuid(),
    user_id     varchar(64)             not null,
    status      rsvp.reservation_status not null default 'pending',
    resource_id varchar(64)             not null,
    timespan    tstzrange               not null,
    Note        text,
    constraint pk_reservations primary key (id),
    -- 排除约束：
    -- using git：指定约束的索引类型，即通用搜索树
    -- (resource_id with =, timespan with &&)：
    -- 排除新插入的行与已有行存在resource_id相等且timespan重叠
    constraint reservation_conflict exclude
        using gist (resource_id with =, timespan with &&)
);
-- 创建索引，根据resource_id和user_id查询reservations
create index reservations_resource_id_idx on rsvp.reservations (resource_id);
create index reservations_user_id_idx on rsvp.reservations (user_id);