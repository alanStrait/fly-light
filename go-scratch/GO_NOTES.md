# Go Notes
- [Installing Go](https://go.dev/doc/install/)
- [Go Documentation](https://go.dev/doc/)
- [A Tour of Go](https://go.dev/tour)
- [How to Write Go Code](https://go.dev/doc/)
- [Package reference for standard library](https://go.dev/pkg/)
  - [Language Spec](https://go.dev/ref/spec)
- Concurrency Patterns
  - [Go Concurrency Patterns (slides)](https://www.youtube.com/watch?v=f6kdp27TYZs)
  - [Advanced Go Concurrency Patterns (slides)](https://www.youtube.com/watch?v=QDDwwePbDtw)
  - [Share Memory by Communicating](https://go.dev/doc/codewalk/sharemem/)
- Web Applications
  - [A simple programming environment (slides)](https://vimeo.com/53221558)
  - [Writing Web Applications](https://go.dev/doc/articles/wiki/)
- [First Class Functions in Go](https://go.dev/doc/codewalk/functions/)
- [Go Blog](https://go.dev/blog/)
- [Go Home Page](https://go.dev/)

## Project Creation
Absolutely. This is a great question because the Go toolchain has a very different philosophy from Elixir’s mix. It’s simpler and more opinionated, which can be confusing at first if you’re used to the flexibility of mix.
Here’s the breakdown of how to create and manage a Go project, both from the CLI and in VS Code, and how it compares to the mix workflow.
The Core Concept: No Project Generator
The biggest difference is that Go does not have a single, canonical command to “create a new project” like mix new my_app.
Instead, you create a directory and start writing .go files. The Go toolchain (go build, go run, etc.) figures out what to do based on the code itself and the directory’s location within your GOPATH (the old way) or as a Go Module (the modern, standard way).
The Modern Way: Using Go Modules (The Standard Since Go 1.11)
This is the equivalent of defining your project and its dependencies. Think of it as initializing your mix.exs file.
Step-by-Step CLI Guide:

    Create your project directory anywhere on your system (it no longer has to be inside a special GOPATH).
    bash

Copy
mkdir my-fly-proxy && cd my-fly-proxy

Initialize a new Go Module. This is the key command. It creates a go.mod file that defines your project’s module path (its name) and tracks dependencies. This is your project’s foundation.
bash
Copy
go mod init github.com/your-github-username/my-fly-proxy

(You can use any module path, but using a GitHub URL is standard practice even for local projects as it ensures uniqueness.)
Create your main application file.
bash
Copy
touch main.go

Open main.go in your editor and add a simple hello world:
go
Copy
package main // Every executable program must have a package 'main'

import "fmt" // Import the format package, like IO or Logger in Elixir

func main() { // The 'main' function is the entry point
    fmt.Println("Hello, from my Go proxy!")
}

Run your code:
bash

    Copy
    go run main.go

    You should see Hello, from my Go proxy! printed.

What did this do?

    go mod init created your go.mod file (like mix.exs).
    go run compiled and executed the code in one step (similar to iex -S mix run but without a long-lived shell).

Key CLI Commands vs. mix
Table
Export
Copy
Elixir (mix)
	Go (go)
	Purpose
mix new
	go mod init + mkdir
	Initialize a new project
mix compile
	go build
	Compile the project into a binary
mix deps.get
	go mod tidy
	Download and tidy dependencies
iex -S mix
	go run .
	Compile & run the main application
mix test
	go test ./...
	Run tests
mix dialyzer
	(N/A, use 3rd party)
	Static analysis
Setting Up VS Code for Go
VS Code is arguably the best editor for Go, thanks to the official Go extension.

    Install the Extension: Search for “Go” in the Extensions marketplace and install the one published by “Go Team at Google”.
    It Will Prompt You to Install Tools: The extension will analyze your code and suggest installing a set of helper tools (gopls, staticcheck, dlv, etc.). Click “Install All”. These tools provide:
        Auto-completion and code navigation (gopls - the Go language server).
        Formatting on save (uses gofmt).
        Linting and vulnerability checks (staticcheck).
        Debugging (dlv).
    Create a Project in VS Code:
        Open VS Code.
        File > Open Folder... and select your my-fly-proxy directory.
        The Go extension will automatically activate. You now have full IntelliSense, formatting, and debugging support.

Your “Fly-Proxy” Project Next Steps in VS Code

    Add a dependency. Let’s add the Gorilla web toolkit, a common library for HTTP routing. Edit your main.go:
    go

Copy
package main

import (
    "fmt"
    "net/http"
    "github.com/gorilla/mux" // This is a new dependency
)

func main() {
    r := mux.NewRouter()
    r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Request received by the proxy!\n")
    })

    http.ListenAndServe(":8080", r)
}

Save the file. VS Code’s gopls will immediately see the new import and mark it as an error (red squiggly) because the dependency isn’t downloaded yet.
Download the Dependency. In the integrated terminal in VS Code (Terminal > New Terminal), run:
bash
Copy
go mod tidy

This command looks at all your imports, downloads the required packages (adding them to your go.mod and creating a go.sum file for checksums), and removes any unused ones. It’s the equivalent of mix deps.get.
Run it:
bash

    Copy
    go run main.go

    Now visit http://localhost:8080 in your browser. You’ve just built a tiny web server.

This workflow—write code, go mod tidy, go run—is the core loop. It’s very fast and straightforward once you’re used to it. You’re now ready to start building out the more complex proxy logic for your Fly.io preparation.

## Project Structure
What is the typical source file structure or naming convention for a go project?
---

Go has very strong, battle-tested conventions for project structure. Unlike the flexibility of an Elixir mix project, a Go project’s layout is highly standardized, which is a huge benefit for readability and maintainability. The community largely follows the same patterns.

Here is the typical structure for a non-trivial application or library, explained layer by layer.

The Standard Project Layout (my-fly-proxy/)

This is what you’d aim for as your project grows beyond a single main.go file.

Plain Text
Copy

<pre>
my-fly-proxy/
├── cmd/
│   └── go-scratch/
│       └── main.go          # The application's entry point
├── internal/
│   ├── handler/             # HTTP handlers (controller logic)
│   │   └── proxy.go
│   ├── service/             # Business logic layer
│   │   └── proxy_service.go
│   └── config/              # Configuration loading
│       └── config.go
├── pkg/
│   └── some_lib/            # Publicly importable code
│       └── lib.go
├── api/
│   └── spec.yaml            # OpenAPI/Swagger spec
├── web/                     # Frontend assets (HTML, CSS, JS)
│   └── static/
├── scripts/                 # Helper scripts (e.g., build, deploy)
├── test/                    # Additional external test apps/scripts
├── go.mod                   # Module definition (like mix.exs)
├── go.sum                   # Dependency checksums (like mix.lock)
└── Makefile                 # Common to define build/test tasks
</pre>

### Key Directories and Conventions
Breakdown of Key Directories & Conventions
1. /cmd - The Entry Points

    Purpose: Houses the main packages for your application. Each subdirectory is a separate executable.
    Convention: If your project has only one application, you typically have a single directory like /cmd/my-app-name/ with a main.go inside.
    Why: It cleanly separates the entry point from the rest of your application logic. A project can have multiple commands (e.g., /cmd/cli-tool/, /cmd/background-worker/).
    Analogy: This is the script that gets run, like a script in a scripts/ folder or the endpoint defined in mix.exs.

2. /internal - Private Application Code

    Purpose: The heart of your application. This contains all the logic that is not meant to be imported by other projects.
    Convention: The Go compiler itself enforces this privacy. Code outside of this project cannot import packages inside /internal.
    Structure: You organize it by concern, not by type. This is a crucial difference from other languages.
        /internal/handler or /internal/transport/http: HTTP controllers. They parse requests and call services.
        /internal/service: Core business logic. Pure, reusable code that doesn’t know about HTTP, databases, etc.
        /internal/store or /internal/repository: Data access layer (database calls).
    Analogy: This is like the lib/my_app/ directory in a Phoenix project, containing your contexts and controllers.

3. /pkg - Public Library Code

    Purpose: Contains code that is safe for other external projects to import and use. Often used for libraries or well-defined, reusable components.
    Convention: If you’re building a binary (an app), you might not have this. If you’re building a library (like a database driver), this is where all your code lives.
    Use Case: If a piece of code in your /internal directory is so well-designed that another team might want to use it, you’d move it to /pkg.
    Analogy: This is like publishing a Hex package. The code is public and versioned for others to use.

4. File Naming Conventions

    Test Files: <name>_test.go. This is mandatory. The test for proxy.go must be named proxy_test.go. The Go toolchain (go test) specifically looks for this pattern.
    Platform-Specific Files: <name>_<OS>.go or <name>_<OS>_<arch>.go.
        file_linux.go - Code that only compiles on Linux.
        file_windows_amd64.go - Code that only compiles on 64-bit Windows.
    General Files: Use snake_case for filenames. proxy_service.go is more common than proxyService.go.

### The "Why": Key Go Philosophies

    1. Explicit over Implicit: There is no magic. No dependency injection framework. You wire up dependencies (like passing a database connection to a service) explicitly in main.go or an initializer. This makes the data flow incredibly clear.
    2. Flat vs. Deep Hierarchies: Deeply nested directories (e.g., internal/handler/http/user/get.go) are frowned upon. Prefer flat structures. A package should contain related types and functions, not be split into a dozen files.
    3. Package Naming: Package names should be short, lowercase, single words. They are what users type when they import your code (import "github.com/you/proxy/handler"). The name should describe what the package provides, not what it contains (e.g., handler, not handlers; user, not userModel).

For your Fly.io proxy project, a great starting structure would be:
Plain Text
Copy
<pre>
my-fly-proxy/
├── cmd/
│   └── fly-proxy/
│       └── main.go          # Wire up HTTP server, config, and services
├── internal/
│   ├── config/
│   │   └── config.go        # Load port number from env vars
│   ├── handler/
│   │   └── proxy.go         # The http.Handler that does the proxying
│   └── service/
│       └── health.go        # Simple health check service
├── go.mod
├── go.sum
└── Makefile
</pre>
This structure immediately signals to any experienced Go developer that you understand the language’s idioms, which is a massive plus for your application. It’s clean, scalable, and maintainable.

## Commands
- `go work use ./path/to/module`