package main

import (
	"fmt"
	"wars_rep/lib"
)

func main() {

	// lib.ReverseParentheses("(u(love)i)")

	d := []string{"flower", "flow", "flight"}
	x := []string{"dog", "racecar", "car"}
	fmt.Println(lib.LongerCommonPrefix(d))
	fmt.Println(lib.LongerCommonPrefix(x))

}
