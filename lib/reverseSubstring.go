package lib

import (
	"fmt"
	"slices"
	"strings"
)

func constantArray() []string {
	return []string{"(", ")"}
}

func Reverse(s string) (result string) {
	for _, v := range s {
		result = string(v) + result
	}
	return
}

func mySplit(s string) []string {
	arr := []string{}
	word := ""
	openString := false
	end := false
	beginSym := constantArray()[0]
	endSym := constantArray()[1]
	for _, w := range s {
		isExeception := slices.Contains(constantArray(), string(w))
		if string(w) == beginSym {
			openString = true
			end = false
		}

		if string(w) == endSym {
			openString = false
			end = true
			arr = append(arr, word)
			word = ""
		}
		if openString && !isExeception && !end {
			word = word + string(w)
		}

	}
	return arr
}

func myRecursionCall(recusionString string) string {
	resultString := ""
	for _, rString := range recusionString {
		fmt.Println(rString)
	}
	return resultString
}
func makeCut(str3 string) []string {
	res3 := strings.Split(str3, "(")
	word := strings.Split(res3[2], ")")
	result := []string{res3[1], word[0], word[1]}
	return result
}

func mySplit3(s string) string {
	stringForReverse := ""
	beginSym := constantArray()[0]
	for _, w := range s {
		// isExeception := slices.Contains(constantArray(), string(w))
		if string(w) == beginSym {
			//отщипнуть строку
			cutedWord := makeCut(s)[0]
			stringForReverse = mySplit3(cutedWord)
			// как пропускать внутрению подстроку
		}
	}
	return stringForReverse
}

func ReverseParentheses(s string) {
	fmt.Println(mySplit3(s))

}
