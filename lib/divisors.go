package lib

import "fmt"

func Divisor(digit int) int {
	counter := 0
	for x := 0; x < digit+1; x++ {
		fmt.Println(x)
		if x%2 == 0 && x != 0 {
			counter++
			fmt.Println(x)
		}

	}

	return counter
}
