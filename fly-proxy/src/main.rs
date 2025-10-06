use fly_proxy::handlers::{launch, regions};
use fly_proxy::handlers::launch::LaunchParams;
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

    let launch_route = warp::path("launch")
        .and(warp::get())
        .and(warp::query::<LaunchParams>())
        .and_then(launch::launch_handler);

    let routes = regions_route
        .or(launch_route);

    println!("Starting fly-proxy server on http://127.0.0.1:3030");
    println!("Available endpoints: GET /regions, GET /launch?vm_region=X&vm_memory=Y&vm_cores=Z");
    warp::serve(routes)
        .run(([127, 0, 0, 1], 3030))
        .await;
}
