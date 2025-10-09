# Debug

- `Process.info(Process.whereis(FlyKv.PubSub))`
- 
- `:pg` should no longer work
  - `:pg.get_members(FlyKv.PubSub)`
  - `:pg.which_groups()`
- Use these instead
  - `:sys.get_state(FlyKv.PubSub)`
  - `Registry.keys(FlyKv.PubSub, self())`
  - `Node.list() |> IO.inspect(label: "Connected nodes")`
  - `:net_adm.ping(:"fly_dash@MacBookPro") |> IO.inspect(label: "Ping result")`

# fly_cli
- cd fly-cli/cmd/fly-cli
- `make build`
- `./fly-cli --vm-region SIN --vm-memory 6 --vm-cores 4 `

# fly-kv
- `clear; iex --sname fly_kv --cookie mysharedcookie -S mix phx.server `

# fly-dash
- `clear; iex --sname fly_dash --cookie mysharedcookie -S mix phx.server `
