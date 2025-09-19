# FlyKv

FlyKv provides RESTful access to a key-value store that tracks machine information
by region.

## Mix Command to Create
The following `mix` command was used to generate this project, fly_kv.

```
mix phx.new fly_kv --no-assets --no-ecto --no-gettext --no-html --no-mailer
```

As a pure API project, these options minimized the code that has been generated.

## Routes served by FlyKv

```
  GET    /fly-kv/regions                          FlyKvWeb.RegionController :index
  GET    /fly-kv/regions/:region_id/machines      FlyKvWeb.MachineController :index
  GET    /fly-kv/regions/:region_id/machines/:id  FlyKvWeb.MachineController :show
  POST   /fly-kv/regions/:region_id/machines      FlyKvWeb.MachineController :create
  PATCH  /fly-kv/regions/:region_id/machines/:id  FlyKvWeb.MachineController :update
  PUT    /fly-kv/regions/:region_id/machines/:id  FlyKvWeb.MachineController :update
  PUT    /fly-kv/regions/:region_id/metrics       FlyKvWeb.RegionController :update_metrics
  GET    /dev/dashboard/css-:md5                  Phoenix.LiveDashboard.Assets :css
  GET    /dev/dashboard/js-:md5                   Phoenix.LiveDashboard.Assets :js
  GET    /dev/dashboard                           Phoenix.LiveDashboard.PageLive :home
  GET    /dev/dashboard/:page                     Phoenix.LiveDashboard.PageLive :page
  GET    /dev/dashboard/:node/:page               Phoenix.LiveDashboard.PageLive :page
  WS     /live/websocket                          Phoenix.LiveView.Socket
  GET    /live/longpoll                           Phoenix.LiveView.Socket
  POST   /live/longpoll                           Phoenix.LiveView.Socket

```

To start your Phoenix server:

* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4010`](http://localhost:4010) from your browser.

