# The Request of Arya from gab.ai
```
I am interested in preparing to have this job, https://fly.io/jobs/fullstack-phoenix/.  I would like to apply on September 30–given that they have looked for this role for a long time, I hope it is still available then.  My Phoenix / Elixir skills are good, but need to get to the next level.  I need to be conversant with and understand well both Go and Rust.  What do you suggest for a plan of attack?
```
## The Response
Excellent. ambitious That’s a fantastic, goal, and Fly.io is one of the most respected names in the infrastructure space, precisely because of their deep technical work with Elixir. The fact they’ve been looking for this role for a while suggests they have a very high bar; they’re waiting for the right person, not just a person. This is a perfect target.
Your self-assessment is spot on: for this role, being a great Elixir/Phoenix engineer is the baseline. They need someone who can also comfortably navigate their Rust (core platform) and Go (Firecracker, many internal tools) codebase. Your plan to achieve “conversant and understanding” in both by September 30th is aggressive but absolutely possible with a focused, project-based approach.
Here is a tactical 3.5-week plan of attack. It’s structured to not just teach you the languages, but to build the specific context you’ll need for the Fly.io interview.
The Overarching Principle: Learn by Building, Not Just Reading
Your goal isn’t to become a senior Rust/Go developer. It’s to become an elite Elixir developer who can confidently read, debug, modify, and discuss Rust and Go code in the context of a distributed systems platform. Context is everything.
The 3.5-Week “Fly.io Readiness” Plan
Week 1: Foundation & Immersion (Sept 8-14)

    Go (4 Days):
        Tutorial: Go through “A Tour of Go” (go.dev). It’s the best quick start. Focus on: goroutines, channels, context, interfaces, and the standard library (especially HTTP, JSON, io).
        Project: Build a simple CLI tool. Ideas: a tool that fetches data from a public API (e.g., GitHub, SpaceX) and outputs formatted JSON or text. This forces you to understand structs, HTTP, and flags.
        Fly Context: Skim the documentation for machined, the Go-based agent that runs on Fly machines. Don’t try to understand it all; just get a feel for the code structure.
    Rust (3 Days):
        Tutorial: Complete the “Rust Book” up through Chapter 9 (Error Handling). This is non-negotiable. It’s dense but gives you the core concepts: ownership, borrowing, lifetimes, and error handling. These are the mental hurdles.
        Tooling: Get rust-analyzer set up in your editor. It’s a lifesaver.
        Fly Context: Glance at the fly-proxy (the Rust proxy that handles your app’s traffic) and loco (their runtime coordinator) repositories on GitHub. Again, just look at the structure and Cargo.toml files to see what crates they use.

Week 2: Project-Based Integration (Sept 15-21)

    The Core Project: Build a tiny, Fly.io-like platform component in both languages. This is the most important part of your preparation.
        The Idea: A simple HTTP proxy that adds a custom header.
            In Go: Use the standard net/http library. Make it spawn a goroutine per request.
            In Rust: Use the hyper library. Make it use async/.await.
        Why this project? It directly mirrors what fly-proxy does (in a vastly simplified way). You’ll confront concurrency, networking, and performance in both languages.
    Elixir Focus: While building, ask yourself: “How would I connect to this from a Phoenix app?” Write a simple Elixir client that calls your proxy.

Week 3: Fly.io Deep Dive & Refinement (Sept 22-28)

    Code Reading: Now, go back to the Fly.io GitHub repos (fly-proxy, machined, loco). Your goal is to trace a request. Start with a single HTTP request coming into fly-proxy. Can you follow the code? You won’t understand everything, but you should be able to follow the flow. This is what “conversant” means.
    Study Their Blog: Read every technical blog post on fly.io/blog. Pay special attention to anything written by Michael (mjr) or Kurt (kurt). Understand their philosophy and the why behind their technical choices. This is interview gold.
    Mock Interview: Prepare stories. For every bullet point on the job description, have a concrete example from your experience.
        “Tell me about a performance problem you solved.” -> Have an Elixir story ready.
        “How do you approach debugging a complex distributed system?” -> Have a story ready.
        “Why are you interested in working with Rust/Go?” -> Your answer is now: “I’ve built X and Y to understand the languages’ strengths, specifically to contribute to Fly’s platform.”

Final Days: Polish & Apply (Sept 29-30)

    Polish Your Project Code: Put your Go/Rust proxy project on GitHub. Write a good README explaining what it is and why you built it. This is a tangible artifact that proves your initiative.
    Tailor Your Resume/Cover Letter: Your cover letter should not be generic. It should say:
    “I’ve followed Fly’s work for some time and was particularly impressed by your post on [mention a specific post]. To prepare for this role, I built [link to your proxy project] to deepen my understanding of the Rust and Go ecosystems that power your platform. I’m confident my Elixir expertise, combined with this new foundational knowledge, would allow me to quickly contribute to the team.”

This plan shows extreme intentionality. It demonstrates that you understand their problem (needing a bridge between BEAM and their platform) and have taken concrete, quantifiable steps to be the solution. This is how you stand out in a sea of applicants.
You can do this. It’s a grind, but it’s focused and effective. Let me know if you need specifics on any of these steps.