package main

import (
	"fmt"

	"golang.org/x/tour/tree"
)

// Walk walks the tree t sending all values
// from the tree to the channel ch.
func Walk(t *tree.Tree, ch chan int) {
	if t == nil {
		return
	}
	Walk(t.Left, ch)
	ch <- t.Value
	Walk(t.Right, ch)
}

// Same determines whether the trees
// t1 and t2 contain the same values.
func Same(t1, t2 *tree.Tree) bool {
	// Create channels for both trees
	ch1 := make(chan int)
	ch2 := make(chan int)

	// Walk both trees concurrently
	go func() {
		Walk(t1, ch1)
		close(ch1)
	}()
	go func() {
		Walk(t2, ch2)
		close(ch2)
	}()

	// Compare values from both channels
	for {
		v1, ok1 := <-ch1
		v2, ok2 := <-ch2

		// If one channel closed before the other, trees are different sizes
		if ok1 != ok2 {
			return false
		}

		// Both channels closed - we've compared all values
		if !ok1 && !ok2 {
			return true
		}

		// Values differ - trees are not the same
		if v1 != v2 {
			return false
		}
	}
}

func main() {
	t1 := tree.New(10)
	fmt.Println(t1)
	// Test with identical trees
	fmt.Println("Same(tree.New(1), tree.New(1)):", Same(tree.New(1), tree.New(1)))

	// Test with different trees
	fmt.Println("Same(tree.New(1), tree.New(2)):", Same(tree.New(1), tree.New(2)))

	// Additional verification
	fmt.Println("Testing same tree with itself:", Same(tree.New(3), tree.New(3)))
	fmt.Println("Testing different seeds:", Same(tree.New(5), tree.New(7)))
}
