# go-scratch
A place to create solutions to exercises for the purpose of learning Go.

There are exercises from `A Tour of Go` as well as Exercism.com.

Every Go example is setup to provide:
- Clear separation between exercises,
- No dependency conflicts,
- Easy to add new exercises,
- Matches Exercism's structure,
- Simple to run individually.

Every new exercise will need to be initialized, e.g.,
```
# Create directory for exercise in the appropriate location, e.g.,
cd exercises/go_tour
mkdir loops_and_functions
# Initialize with its own `go.mod` for isolation
cd loops_and_functions
go mod init loops_and_functions
# Create expected main.go module with `package main` and `func main() {}`
```

In order to run the exercise, follow the instructions below.

## A Tour of Go Exercises
Go Tour exercises are found here:
- `exercises/go_tour/*`

Use `bin/go-exercise-runner.sh` to run exercises.  Exercises will be listed here:

```
# From `go-scratch` root directory.
# Loops and functions
bash bin/go-exercise-runner.sh go_tour/loops_and_functions
```
