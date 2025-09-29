use crate::services::fly_kv::FlyKVService;
use warp::{Reply, Rejection, reply::json};
use anyhow::Result;

pub async fn list_regions_handler(fly_kv_service: FlyKVService) -> Result<impl Reply, Rejection> {
    match fly_kv_service.list_regions().await {
        Ok(response) => Ok(json(&response)),
        Err(e) => {
            eprintln!("Error fetching regions: {}", e);
            Err(warp::reject::not_found())
        }
    }
}
