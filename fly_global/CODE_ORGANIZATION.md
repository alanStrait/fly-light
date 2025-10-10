# Fly Global Code Organization

**Question to Arya**
For Phoenix Framework, when calling a RESTful service from a controller in a separate service, is it sufficient to use the `Client` module as the context for making the call?  Client functions use `Req` to make the needed external calls, and I am currently using `Client` directly in the Infrastructure GenServer in order to instantiate MachineD and FlyD with machine content.

**Arya's Answer**

Excellent question. This gets to the heart of organizing Elixir applications, particularly around the concept of contexts and boundaries.

The short answer is: **No, it is generally not considered good practice to call your `Client` module directly from a Controller or a GenServer.** Using the `Client` module as a "context" is a misunderstanding of the purpose of a context.

Let's break down the correct architecture and why the `Client` module should be considered part of your **anti-corruption layer** or **implementation detail**, not the public interface.

### The Conceptual Layers

A well-structured Phoenix application follows a layered approach:

1.  **Presentation Layer (Web):** Controllers, Views, LiveViews. Their job is to handle web requests, call the business logic, and format the response.
2.  **Business Logic Layer (Core):** Contexts. Their job is to orchestrate the core rules and workflows of your application. A context is a public API for a specific domain (e.g., `Accounts`, `Blog`, `Billing`).
3.  **Infrastructure/Adapters Layer (External):** This is where your `Client` module lives, along with Ecto Repos, other API clients, etc. This layer's job is to talk to the outside world (databases, external APIs, file systems).

The key principle is that the inner layers (Business Logic) should **not depend on the outer layers (Infrastructure)**. The outer layers should depend on the interfaces defined by the inner layers.

### Your Current Setup and Its Problem

You currently have:
`Controller/GenServer -> Client (with Req) -> External API`

The issue is that your Controller/GenServer (Business/Presentation layer) is **directly coupled to a specific HTTP client implementation (`Req`)**. This violates the **Dependency Inversion Principle**.

**What happens if you need to change?**
*   Switch from `Req` to `Tesla` or `HTTPoison`? You have to change every single place that calls `Client`.
*   Need to add caching in front of the external API? You have to change your Controller/GenServer logic.
*   Want to mock the external API for tests? You have to do complex mocking of the `Client` module, which is messy.

### The Recommended Architecture

You should insert a **Context module** between your GenServer and the `Client`. The `Client` becomes a private implementation detail of that context.

The flow should be:
`Controller/GenServer -> MyApp.Context -> Client (with Req) -> External API`

Here’s how to structure it:

**1. Define a Context (The Public Interface)**
Create a module in `lib/my_app/` that represents the domain concept you're working with. Since you're dealing with machines and Fly, perhaps `MachineContext` or `FlyService`.

```elixir
# lib/my_app/machines.ex
defmodule MyApp.Machines do
  @moduledoc """
  The boundary for machine interactions, including external services.
  """

  # This alias is OK because it's within the same "core" domain.
  alias MyApp.Machines.Client

  @doc """
  Gets all machines from the external service.
  This is the public function your GenServer should call.
  """
  def list_machines do
    Client.list_machines()
  end

  @doc """
  Gets a specific machine by ID from the external service.
  """
  def get_machine(id) do
    Client.get_machine(id)
  end

  # You can add caching, transformation, or other business logic here later without changing the caller.
  # def get_machine(id) do
  #   case Cache.get(:machine_cache, id) do
  #     nil ->
  #       machine = Client.get_machine(id)
  #       Cache.put(:machine_cache, id, machine)
  #       machine
  #
  #     cached_machine ->
  #       cached_machine
  #   end
  # end
end
```

**2. Keep Your Client as the Private Implementation**
Your `Client` module remains, but it's now only called by the context. Notice its name is now more specific (`Machines.Client`), indicating it's the client for the `Machines` context.

```elixir
# lib/my_app/machines/client.ex
defmodule MyApp.Machines.Client do
  @moduledoc false # Mark as false to exclude from public docs, it's an implementation detail.

  use Req.Request

  @base_url "https://api.example.com"

  def list_machines do
    Req.get!("#{@base_url}/machines").body
  end

  def get_machine(id) do
    Req.get!("#{@base_url}/machines/#{id}").body
  end
end
```

**3. Update Your GenServer (The Caller)**
Your Infrastructure GenServer now depends on the stable, public interface of the context, not the volatile implementation of the client.

```elixir
# lib/my_app/infrastructure/gen_server.ex
defmodule MyApp.Infrastructure do
  use GenServer

  # Call the public context, not the private client!
  alias MyApp.Machines

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    # Now you are calling the public API
    machines = Machines.list_machines()
    # ... logic to instantiate MachineD, FlyD, etc.
    {:ok, %{machines: machines}}
  end
end
```

### Why This Is Superior

*   **Testability:** You can test your GenServer in complete isolation by easily mocking the `MyApp.Machines` context. You don't care *how* it gets the data, only that it returns it.
*   **Maintainability:** If the external API changes or you need to switch HTTP clients, you only change code in *one* place: the `MyApp.Machines.Client` module. No GenServer or Controller files need to be touched.
*   **Clarity:** The context defines *what* your application can do with machines. The client defines *how* it talks to the external service to accomplish that. The separation of concerns is clear.
*   **Resilience:** You can build circuit breakers, rate limiting, logging, and fallback logic into the context layer without polluting your core application logic.

In summary, treat your `Client` module as a private adapter. Wrap it in a context that represents your application's domain to create a clean, maintainable, and testable boundary between your core logic and the external world.