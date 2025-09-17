defmodule Exercises.GoTour.WebCrawler do
  @moduledoc """
  In this exercise you'll use Go's concurrency features to parallelize a web
  crawler.

  Modify the Crawl function to fetch URLs in parallel without fetching the same
  URL twice.

  Hint: you can keep a cache of the URLs that have been fetched on a map, but
  maps alone are not safe for concurrent use!

  NOTE: the above Mutex example for Go requires no Mutex in Elixir.
  This implementation uses a VM Singleton by way of Agent to ensure each
  site is visited only once.

  NOTE: This example is significant in demonstrating the power of Elixir
  as compared with Go when it comes to concurrency.
  """
  alias Exercises.GoTour.WebCrawler
  use Agent

  @sites ~W[
    https://golang.org/
    https://golang.org/pkg/
    https://golang.org/cmd/
    https://golang.org/pkg/fmt/
    https://golang.org/pkg/os/
    ]

  def start_link(_state) do
    Agent.start_link(fn -> @sites end, name: __MODULE__)
  end

  @doc """
  crawl displays the returned HTML rather than the simple message that
  each request was succcessful or not.  This is primarily to kick the
  tires on Wojtek Mach's `Req` HTTP client with the `ReqEasyHTML` plugin.

  TODO: circle back and complete with simple messages.
  """
  def crawl do
    for _i <- 1..state_size(), into: [] do
      Task.async(fn ->
        site = WebCrawler.pop_next()
        req =
          Req.new(base_url: site) |> ReqEasyHTML.attach()
        Req.get!(req).body
      end)
    end
    |> Enum.map(fn task -> Task.await(task) end)
  end

  def list_sites do
    @sites |> IO.inspect(label: "\nSITE\t")
  end

  @doc """
  pop_next pops the first site in the queue and provides it to the
  client.  Because it is removed from the `List` managed by this `Agent`,
  it is not possible for another `Process` to fetch the same site twice.
  """
  def pop_next do
    Agent.get_and_update(
      __MODULE__,
      fn state -> pop_next(state)
      end,
      1000
    )
  end

  def pop_next([h|t]), do: {h, t}
  def pop_next([]), do: {"", []}

  @doc """
  state_size returns the length of the List managed by Agent.
  """
  def state_size do
    Agent.get(__MODULE__, &Enum.count/1)
  end

  @doc """
  reset_state returns the List managed by Agent to its original state.
  """
  def reset_state do
    Agent.update(__MODULE__, fn _ -> @sites end)
  end
end
