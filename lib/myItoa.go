package lib

import "fmt"

func myItoa(myInteger int) string {
	result := '0' + myInteger
	return string(result)
}

func MyItoa(integer int) (s string) {
	negative := integer < 0
	if negative {
		integer = 0 - integer
	}
	if integer == 0 {
		return "0"
	}
	for integer > 0 {
		tmp := integer % 10
		fmt.Println("what is tmp")
		fmt.Println(tmp)
		integer = integer / 10
		fmt.Println("what is integer")
		fmt.Println(integer)
		s = string('0'+tmp) + s
	}
	return s
}
