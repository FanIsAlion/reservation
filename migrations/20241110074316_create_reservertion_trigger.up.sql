-- Add up migration script here
create table rsvp.reservation_changes
(
    id             serial                       not null,
    reservation_id uuid                         not null,
    op             rsvp.reservation_update_type not null
);

-- trigger for add/update/delete a reservation
create or replace function rsvp.reservation_trigger() returns trigger as
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