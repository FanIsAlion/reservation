-- Add down migration script here
drop table rsvp.reservations cascade;
drop type rsvp.reservation_status;
drop type rsvp.reservation_update_type;