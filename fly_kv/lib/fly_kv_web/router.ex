defmodule FlyKvWeb.Router do
  use FlyKvWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FlyKvWeb do
    pipe_through :api
  end

  scope "/fly-kv", FlyKvWeb do
    pipe_through :api

    # GET /fly-kv/regions
    get "/regions", RegionController, :index

    # This creates nested routes for machines under a region
    # GET /fly-kv/regions/:region_code/machines
    # GET /fly-kv/regions/:region_code/machines/:id
    # POST /fly-kv/regions/:region_code/machines
    # PATCH /fly-kv/regions/:region_code/machines/:id
    resources "/regions/:region_code/machines", MachineController, only: [:index, :show, :create, :update]

    # I've reinterpreted this as a metric endpoint for a region.
    # PUT /fly-kv/regions/:region_code/metrics
    put "/regions/:region_code/metrics", RegionController, :update_metrics
  end


  # Enable LiveDashboard in development
  if Application.compile_env(:fly_kv, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: FlyKvWeb.Telemetry
    end
  end
end
