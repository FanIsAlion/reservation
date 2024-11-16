use std::process::Command;

fn main() {
    tonic_build::configure()
        .out_dir("src/pb")
        // derive sqlx::Type -> 实现在build的时候为指定的类型添加特性sqlx::Type
        .type_attribute("reservation.ReservationStatus", "#[derive(sqlx::Type)]")
        .compile_protos(&["protos/reservation.proto"], &["protos"])
        .unwrap();

    Command::new("cargo").arg("fmt").output().unwrap();

    println!("cargo:rerun-if-changed=protos/reservation.proto");
}
