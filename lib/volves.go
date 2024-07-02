package lib

import (
	"fmt"
	"slices"
)

var volveList = []rune{'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'}

func RemoveAllVolves(someString string) string {
	var result string
	for _, b := range someString {
		if slices.Contains(volveList, b) {
			fmt.Println(string(b))
		} else {
			result = result + string(b)
		}
	}
	return result
}
