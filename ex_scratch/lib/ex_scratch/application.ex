defmodule ExScratch.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Exercises.GoTour.Fibonacci, name: Exercises.GoTour.Fibonacci},
      {Exercises.GoTour.WebCrawler, name: Exercises.GoTour.WebCrawler}
    ]

    opts = [strategy: :one_for_one, name: ExScratch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
