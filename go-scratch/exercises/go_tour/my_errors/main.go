package main

//  Copy your Sqrt function from the earlier exercise and modify it to return an
// error value.
//
// Sqrt should return a non-nil error value when given a negative number, as it doesn't
// support complex numbers.
//
// Create a new type
//
// type ErrNegativeSqrt float64
//
// and make it an error by giving it a
//
// func (e ErrNegativeSqrt) Error() string
//
// method such that ErrNegativeSqrt(-2).Error() returns "cannot Sqrt negative number: -2".
//
// Note: A call to fmt.Sprint(e) inside the Error method will send the program into an
// myiinfinite loop. You can avoid this by converting e first: fmt.Sprint(float64(e)). Why?
//
// Change your Sqrt function to return an ErrNegativeSqrt value when given a negative number.
import (
	"fmt"
	"math"
)

type ErrNegativeSqrt float64

func (e ErrNegativeSqrt) Error() string {
	return fmt.Sprintf("cannot Sqrt negative number: %v", float64(e))
}

func Sqrt(radicand float64) (float64, error) {
	if radicand < 0 {
		return 0, ErrNegativeSqrt(radicand)
	}
	z := 1.0
	zp := z
	for i := 1; i < 10; i++ {
		zp = z
		z = newtons_method(z, radicand) // (z*z - radicand) / (2 * z)
		var diff = math.Abs(zp) - math.Abs(z)
		if math.Abs(diff) < 0.002 {
			return z, nil
		}
	}
	return radicand, nil
}

func newtons_method(current, radicand float64) float64 {
	return math.Abs(current - (current*current-radicand)/(2*current))
}

func main() {
	fmt.Println(Sqrt(2))
	fmt.Println(Sqrt(-2))
}
