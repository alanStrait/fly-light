// src/services/fly_kv.rs
use reqwest::Client;
use serde::{Deserialize, Serialize};
use anyhow::{Result, Context};

#[derive(Debug, Clone)]
pub struct FlyKVService {
    client: Client,
    base_url: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct RegionsResponse {
    pub data: Vec<Region>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Region {
    pub code: String,
    pub status: String,
    pub location: String,
}



impl FlyKVService {
    pub fn new() -> Self {
        FlyKVService {
            client: Client::new(),
            base_url: "http://localhost:4010/".to_string(),
        }
    }

    pub async fn list_regions(&self) -> Result<RegionsResponse> {
        let url = format!("{}fly-kv/regions/", self.base_url);
        
        let response = self.client
            .get(&url)
            .send()
            .await
            .context("Failed to send request to Fly KV regions endpoint")?;
        
        let status = response.status();

        if !status.is_success() {
            let response_text = response.text().await.unwrap_or_default();

            anyhow::bail!(
                "Fly KV regions API returned error status: {} - {}",
                status,
                response_text
            );
        }
        
        // Parse directly into the RegionsResponse struct that matches the API
        let regions_response: RegionsResponse = response
            .json()
            .await
            .context("Failed to parse Fly KV regions response")?;
            
        Ok(regions_response)
    }

}
