create schema rsvp;
create type rsvp.reservation_status as enum ('unknown','pending','confirmed','blocked');
create type rsvp.reservation_update_type as enum ('unknown', 'create', 'update', 'delete');

-- SELECT int4range(10, 20) @> 3 ranger(10,20)是否大于3这个点 (看3是不是在10到20内) -> false
-- SELECT int4range(10, 20) @> int4range(11, 19) 范围(10,20)是否大于(11,19) -> true
-- SELECT int4range(10, 20) && int4range(5, 15) 两个范围是否overlaps -> true
-- SELECT int4range(10, 20) * int4range(15, 25) 两个范围是否相交,返回交集 -> int4range(15, 20)
create table rsvp.reservations
(
    id uuid not null, -- default uuid_generate_v4(),
    user_id     varchar(64)             not null,
    status      rsvp.reservation_status not null
        default 'pending',
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

-- if user id is null, find all reservations within during for the resource
-- if resource id is null, find all reservations within during for the user
-- if both are null, find all reservations within during
-- if both set, find all reservations within during for the user and resource
create or replace function rsvp.query(uid text, rid text, during tstzrange)
    returns table
            (
                id          uuid,
                user_id     varchar(64),
                status      rsvp.reservation_status,
                resource_id varchar(64),
                timespan    tstzrange,
                Note        text
            )
as
$$
begin
end;
$$ language plpgsql;

-- reservation change queue
create table rsvp.reservation_changes
(
    id             serial                       not null,
    reservation_id uuid                         not null,
    op             rsvp.reservation_update_type not null
);

-- trigger for add/update/delete a reservation
create or replace function rsvp.reservation_trigger()
    returns trigger as
$$
begin
    if tg_op = 'INSERT' then
        -- update reservation_changes
        insert into rsvp.reservation_changes (reservation_id, op) values (NEW.id, 'CREATE');
    elsif tg_op = 'UPDATE' then
        -- if status changed, update reservation_changes
        if old.status <> new.status then
            insert into rsvp.reservation_changes (reservation_id, op) values (NEW.id, 'UPDATE');
        end if;
    elsif tg_op = 'DELETE' then
        -- update reservation_changes
        insert into rsvp.reservation_changes (reservation_id, op) values (OLD.id, 'DELETE');
    end if;
    -- notify a channel called reservation_update
    notify reservation_update;
    -- because return after insert/update/delete from define in down below
    return null;
end;
$$ language plpgsql;

create trigger reservation_trigger
    after insert or update or delete
    on rsvp.reservations
    for each row
execute procedure rsvp.reservation_trigger();