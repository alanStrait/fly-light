# FlyDash

FlyDash shares a PubSub topic with FlyKv, requiring name and cookie to be set on start.

`iex --name fly_dash@127.0.0.1 --cookie mysharedcookie -S mix phx.server`

## Mix Command to Create

FlyDash is a LiveView SPA, therefore all of the defaults were taken when generating this project.  E.g.,

`mix phx.new fly-dash`
