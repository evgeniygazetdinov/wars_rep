package main

import "wars_rep/lib"

func makeSliceOfSlices(length int) [][]int {

	mySlice := make([][]int, length)
	for i := 1; i < length; i++ {
		mySlice[i] = make([]int, length)
		for j := 0; j < length; j++ {
			mySlice[i][j] = i * j
		}
	}
	return mySlice
}

func caller() string {
	fmt.Println("1")
	defer lib.Runner1()
	fmt.Println("2")
	defer lib.Runner2()
	fmt.Println("3")
	defer lib.Runner3()
	return "here"
}

func main() {

	// lib.MentalCount(10)
	// fmt.Println(lib.MyItoa(456))

	// length := 4
	// {
	// 	mySlice := makeSliceOfSlices(length)
	// 	fmt.Println(lib.Concat(mySlice))
	// }

	fmt.Println(caller())
}
