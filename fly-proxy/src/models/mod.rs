use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Region {
    pub id: String,
    pub name: String,
    pub code: String,
    pub enabled: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RegionsResponse {
    pub regions: Vec<Region>,
    pub count: usize,
}
