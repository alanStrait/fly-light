package main

import (
	"fmt"

	"golang.org/x/tour/pic"
)

func Pic(dx, dy int) [][]uint8 {
	// Create a dy-length slice of slices
	pic := make([][]uint8, dy)
	for y := range pic {
		// Create a dx-length slice for each row
		pic[y] = make([]uint8, dx)
		for x := range pic[y] {
			// Example: XOR of x and y creates an interesting pattern
			// pic[y][x] = uint8(x ^ y)

			// Other common patterns:
			// pic[y][x] = uint8((x + y) / 2)   // Average
			pic[y][x] = uint8(x * y) // Product
			// pic[y][x] = uint8(x*x + y*y)     // Quadratic
		}
	}
	defer fmt.Printf("Pic: %v", pic)
	return pic
}

func main() {
	pic.Show(Pic)
}
