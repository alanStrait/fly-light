package main

// Fibonacci sequence calculation is not an exercise in the Go Tour,
// but it is referenced and makes for a fun exercise.
//
// TODO: As with the Elixir version, call recursively until the specific
// value at a particular position can be reported.
import "fmt"

func fibonacci() func() int {
	a, b := 0, 1
	return func() int {
		result := a
		a, b = b, a+b
		return result
	}

}

func main() {
	f := fibonacci()
	for i := 0; i < 10; i++ {
		fmt.Println(f())
	}
}
