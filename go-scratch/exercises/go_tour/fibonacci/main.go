package main

// Fibonacci sequence calculation is not an exercise in the Go Tour,
// but it is referenced and makes for a fun exercise.
//
// TODO: As with the Elixir version, call recursively until the specific
// value at a particular position can be reported.
import (
	"fmt"
)

func fibonacci(n int, c chan int) {
	x, y := 0, 1
	for i := 0; i <= n; i++ {
		if i == n {
			c <- x
		}
		x, y = y, x+y
	}
	close(c)
}

func main() {
	c := make(chan int, 40)
	go fibonacci(cap(c), c)
	for i := range c {
		fmt.Println(i)
	}
}
