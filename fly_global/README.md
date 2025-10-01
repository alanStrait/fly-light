# FlyGlobal

Flylight is emulating a company, fly.io, that operates Cloud infrastructure globally and does so in a thoughtfully compelling way that is accessible for large entities as well as mom-and-pop shops.  The thoughtfulness is reflected in the tools chosen for managing their distributed environment: Go, Rust, Elixir, WireGuard, etc.  The compelling part is that their distributed environment is simplified to manage from the command line--they are explicitly a command line first company.  This project `simulates` infrastructure in a way that `approximates` the fly.io-way.  One notable exception is that their `flyd` process is written in Go, and here we emulate it with an Elixir GenServer.  

## Project Creation

As an API only project, `mix` was used to generate only what is needed with the following command:

`mix phx.new fly_global --no-assets --no-ecto --no-html --no-mailer`

This project simulates the infrastructure being managed, especially servers, called machines, on a per region basis.

FlyGlobal's services listen at localhost on port 4020.

## Getting started

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4020`](http://localhost:4020) from your browser.

