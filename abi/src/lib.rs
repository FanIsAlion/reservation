mod pb;

use chrono::{DateTime, Utc};
// pub mod pb;
// pub mod pb 本质上和pub use * 等价,都是把全部pb内的内容导出
// 小区别就是use关键字是导入(内容直接在当前lib包下可见),
// 而mod关键字是导出(内容需要在lib::pb下才可见)
pub use pb::*;
use prost_types::Timestamp;

pub fn convert_to_utc_time(ts: Timestamp) -> DateTime<Utc> {
    let start: DateTime<Utc> = DateTime::from_timestamp(ts.seconds, ts.nanos as u32).unwrap();
    start
}
