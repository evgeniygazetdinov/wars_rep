package main

import "wars_rep/lib"

func main() {


	// lib.MentalCount(10)
	// fmt.Println(lib.MyItoa(456))
	length := 4
	mySlice := make([][]int, length)
	for i := 1; i < length; i++ {
		mySlice[i] = make([]int, length)
		for j := 0; j < length; j++ {
			mySlice[i][j] = i * j
		}
	}
	fmt.Println(lib.Concat(mySlice))


}
