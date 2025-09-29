use crate::models::{Region, RegionsResponse};
use anyhow::Result;
use reqwest::Client;

#[derive(Debug)]
pub struct FlyKVService {
    client: Client,
    base_url: String,
    auth_token: Option<String>,
}

impl FlyKVService {
    pub fn new() -> Self {
        FlyKVService {
            client: Client::new(),
            base_url: "https://localhost:4010/".to_string(),
            auth_token: None,
        }
    }

    pub async fn list_regions(&self) -> Result<RegionsResponse> {
        // Mock implementation - in production, this would connect to actual Fly KV
        let regions = vec![
            Region {
                id: "iad".to_string(),
                name: "Northern Virginia".to_string(),
                code: "iad".to_string(),
                enabled: true,
            },
            Region {
                id: "ams".to_string(),
                name: "Amsterdam".to_string(),
                code: "ams".to_string(),
                enabled: true,
            },
            Region {
                id: "sin".to_string(),
                name: "Singapore".to_string(),
                code: "sin".to_string(),
                enabled: false,
            },
        ];

        Ok(RegionsResponse {
            count: regions.len(),
            regions,
        })
    }
}

impl Clone for FlyKVService {
   fn clone(&self) -> Self {
       FlyKVService {
           client: self.client.clone(),
           base_url: self.base_url.clone(),
           auth_token: self.auth_token.clone(),
           // Clone any other fields
       }
   }

}
