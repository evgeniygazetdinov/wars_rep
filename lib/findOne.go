package lib

import (
	"fmt"
)

func findOdd(seq []int) int {
	smallestNumber := 90
	myMap := make(map[int]int)
	for _, x := range seq {
		for k, v := range myMap {
			if v == smallestNumber {

			}
		}
		fmt.Println(x)
	}
	fmt.Println(myMap)
	for k, v := range myMap {
		if v > smallestNumber {
			smallestNumber = k
		}
	}
	return smallestNumber
}

func TestFindOdd() {
	arr := []int{1, 2, 2, 4, 4, 5, 1}
	fmt.Println(findOdd(arr))
}
