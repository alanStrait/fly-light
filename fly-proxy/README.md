# fly-proxy
`fly-proxy` is a Rust process whose purpose 

## Bootstrapping this project
Brew versus Cargo.  `rustup` had already been installed via `Cargo`, `~/.cargo/bin/rustup`, and so I updated it, first ensuring that `~/.cargo/bin` was on my `PATH`:
- `rustup update`

- Ensure components installed:
  - `rustup component add rustfmt`
  - `rustup component add clippy`
  - `rustup component add rust-analyzer`
- Ensure installation of complete, professional Rust development environment:
  - `rustup`
    - Rust toolchain manager.
    - Installs, updates, and manages multiple Rust versions.
    - Switches between stable, beta, and nightly toolchains.
  - `rustc`
    - The Rust compiler.
    - Compiles Rust source code to machine code.
    - Rarely used dirctly (cargo calls it for you).
  - `cargo`
    - Rust's build system and package manager.
    - Creates new projects (`cargo new`)
    - Builds projects (`cargo build`)
    - Runs projects (`cargo run`)
    - Manages dependencies
    - Runs tests (`cargo test`)
  - `rustfmt`
    - Code formatter
    - Automatically formats Rust code to standard style.
    - Run with `cargo fmt`.
  - `clippy`
    - Advanced linter.
    - Catches common mistakes and suggests improvements.
    - Run with `cargo clippy`.
  - `rust-analyzer`
    - Main Rust extension.
    - Real-time error checking, code completion, go-to-definition.
    - Integration with all the above tools.
  - `dependi`
    - Dependency manager.
    - Shows outdated crates, version infromation.
    - Replaces the deprecated `crates` extension.
  - `Even Better TOML`
    - Configuration file support.
    - Syntax highlighting and validation for Cargo.toml.
  - `CodeLLDB`
    - Debug Rust code with breakpoints, variable inspection.
- Generate new `fly-proxy` project:
  - `cargo new fly-proxy`
- VS Code Extensions:
  - `rust-analyzer`
  - `Even Better TOML`
  - `dependi` (replaces `crates`)
  - `CodeLLDB`
  - `Error Lens`