use warp::{Rejection, Reply};
use serde::Deserialize;
use anyhow::Result as AnyResult;

#[derive(Debug, Deserialize)]
pub struct LaunchParams {
    vm_region: String,
    vm_memory: u32,
    vm_cores: u32,
}

pub async fn launch_handler(params: LaunchParams) -> Result<impl Reply, Rejection> {
    log::info!("Received launch request: {:?}", params);
    println!("Received launch request: {:?}", params);

    // hardcoded valid range check to protect fly-global service from invalid requests
    let allowed_regions = ["DEN", "ARN", "BOM", "GDL", "GRU", "HKG", "JNB", "MEL", "MRT", "SIN"];
    if !allowed_regions.contains(&&*params.vm_region) {
        return Ok(warp::reply::with_status(
            format!("Invalid region: '{}'.  Must be one of: {:?}", params.vm_region, allowed_regions),
            warp::http::StatusCode::BAD_REQUEST,
        ));
    }
    if params.vm_memory == 0 || params.vm_cores == 0 {
        return Ok(warp::reply::with_status(
            "Memory and cores must be greater than 0".to_string(),
            warp::http::StatusCode::BAD_REQUEST,
        ));
    }

    let machine_address = match delegate_to_fly_global(params).await {
        Ok(id) => id,
        Err(e) => {
            log::error!("Delegation to fly-global failed: {}", e);
            return Ok(warp::reply::with_status(
                "Failed to communicate with the orchestratio service".to_string(),
                warp::http::StatusCode::BAD_GATEWAY,
            ));
        }
    };

    println!("machine_address {}", machine_address);

    Ok(warp::reply::with_status(
        machine_address,
        warp::http::StatusCode::OK,
    ))
}

pub async fn delegate_to_fly_global(params: LaunchParams) -> AnyResult<String> {
    let client = reqwest::Client::new();
    let request_body = serde_json::json!({
        "region_code": params.vm_region,
        "memory_gb": params.vm_memory,
        "cores": params.vm_cores
    });

    println!("\nrequest_body {}", request_body);

    let url = format!("http://localhost:4020/fly-global/regions/{}/allocate", params.vm_region);

    println!("\nurl {}", url);

    let response = client
        .post(url)
        .json(&request_body)
        .send()
        .await?;

    if !response.status().is_success() {
        let status = response.status();
        let error_body = response.text().await?;
        return Err(anyhow::anyhow!("fly-global error ({}): {}", status, error_body));
    }

    let machine_address = response.text().await?;
    Ok(machine_address)
}

