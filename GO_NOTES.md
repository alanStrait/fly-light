# Go Notes

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