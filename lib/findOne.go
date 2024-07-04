package lib

import (
	"fmt"
)

func findOdd(seq []int) int {
	smallestNumber := 0
	myMap := make(map[int]int)
	for _, x := range seq {
		myMap[x]++
	}
	//extract values from map
	// res := make([]int, 0, len(myMap))
	// for _, v := range myMap {
	// 	res = append(res, v)
	// }
	// return res
	for key, value := range myMap {
		if value == 1 {
			smallestNumber = key
		}
	}
	return smallestNumber
}

func TestFindOdd() {
	arr := []int{1, 2, 2, 4, 4, 5, 1}
	fmt.Println(findOdd(arr))
}
