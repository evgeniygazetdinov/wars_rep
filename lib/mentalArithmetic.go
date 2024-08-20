package lib

import (
	"fmt"
	"math/rand/v2"
)

func generateNumber(border int) int {
	return rand.IntN(border)
}

func myPrint(value int, some string) {
	fmt.Println(some)
	fmt.Println(value)
}

func resulter(border int, result int, numberForPlus int) int {
	genetatedNumber := generateNumber(border)
	fmt.Println("that is generated")
	fmt.Println(genetatedNumber)
	fmt.Println("that is result before ")
	fmt.Println(result)
	result = genetatedNumber + numberForPlus
	myPrint(numberForPlus, "number for plus")
	myPrint(result, "that is result after")
	return result
}
func MentalCount(border int) {
	result := 0

	needToStop := false

	for !needToStop {
		var i = 0
		fmt.Print("Type a number: ")
		fmt.Scan(&i)
		new_result := resulter(border, result, i)
		myPrint(new_result, ": new result")
		myPrint(i, ": number for plus")
		myPrint(i+new_result, "expected result")
		// if i != new_result+i {
		// 	needToStop = true
		// 	myPrint(1, "stopped")
		// }
	}
	// TODO finish compare before result with current ? and if error stop loop
	// make training availiable

}
