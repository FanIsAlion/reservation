-- Add down migration script here
drop trigger reservation_trigger on rsvp.reservations;
drop function rsvp.reservation_trigger;
drop table rsvp.reservation_changes cascade;
