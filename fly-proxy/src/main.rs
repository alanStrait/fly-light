use fly_proxy::handlers::regions;
use fly_proxy::FlyKVService;
use warp::Filter;

#[tokio::main]
async fn main() {
    let fly_kv_service = FlyKVService::new();
    
    // Clone the service for use in the filter
    let fly_kv_service_filter = warp::any().map(move || fly_kv_service.clone());

    // Define routes
    let regions_route = warp::path("regions")
        .and(warp::get())
        .and(fly_kv_service_filter)
        .and_then(regions::list_regions_handler);

    println!("Starting fly-proxy server on http://127.0.0.1:3030");
    warp::serve(regions_route)
        .run(([127, 0, 0, 1], 3030))
        .await;
}
