-- Add up migration script here
create or replace function rsvp.query(uid text, rid text, during tstzrange)
    returns table (like rsvp.reservations)
as
$$
begin
    if uid is null and rid is null then
        return query select * from rsvp.reservations where during @> timespan;
    elsif uid is null then
        return query select * from rsvp.reservations where resource_id = rid and during @> timespan;
    elsif rid is null then
        return query select * from rsvp.reservations where user_id = uid and during @> timespan;
    else
        return query select * from rsvp.reservations where user_id = uid and resource_id = rid and during @> timespan;
    end if;
end;
$$ language plpgsql;