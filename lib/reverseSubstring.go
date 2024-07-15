package lib

import (
	"fmt"
	"slices"
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

func mySplit3(s string) []string {
	arr := []string{}

	return arr
}

func split2(s string) string {
	var res string
	listExeptions := []string{"(", ")"}
	for i := 0; i < len(s); i++ {
		curWord := string(s[i])
		withoutCurses := slices.Contains(listExeptions, curWord)
		if !withoutCurses {
			res = res + curWord
		}
	}
	return Reverse(res)
}

func ReverseParentheses(s string) {
	fmt.Println(mySplit(s))
}
