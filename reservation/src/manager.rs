use crate::{ReservationError, ReservationId, ReservationManager, Rsvp};
use abi::{Reservation, ReservationQuery};
use async_trait::async_trait;
use sqlx::postgres::types::PgRange;
use sqlx::Row;

#[async_trait]
impl Rsvp for ReservationManager {
    async fn reserve(&self, mut rsvp: Reservation) -> Result<Reservation, ReservationError> {
        if rsvp.start.is_none() || rsvp.end.is_none() {
            return Err(ReservationError::InvalidTime);
        }

        let start = abi::convert_to_utc_time(rsvp.start.as_ref().unwrap().clone());
        let end = abi::convert_to_utc_time(rsvp.end.as_ref().unwrap().clone());
        if start <= end {
            return Err(ReservationError::InvalidTime);
        }

        let timespan = PgRange::from(start..end);
        // generate a insert sql for reservation
        let id = sqlx::query("INSERT INTO reservation (user_id, resource_id, start_time, end_time, note) VALUES ($1, $2, $3, $4, $5) RETURNING id")
            .bind(rsvp.user_id.clone())
            .bind(rsvp.resource_id.clone())
            .bind(timespan)
            .bind(rsvp.note.clone())
            .bind(rsvp.status)
            .fetch_one(&self.pool)
            .await?
            .get(0);

        rsvp.id = id;
        Ok(rsvp)
    }

    async fn change_status(&self, id: ReservationId) -> Result<Reservation, ReservationError> {
        todo!()
    }

    async fn update_note(
        &self,
        id: ReservationId,
        note: String,
    ) -> Result<Reservation, ReservationError> {
        todo!()
    }

    async fn delete(&self, id: ReservationId) -> Result<(), ReservationError> {
        todo!()
    }

    async fn get(&self, id: ReservationId) -> Result<Reservation, ReservationError> {
        todo!()
    }

    async fn query(&self, query: ReservationQuery) -> Result<Vec<Reservation>, ReservationError> {
        todo!()
    }
}

