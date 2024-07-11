package lib

import (
	"slices"
)

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
	return res
}

func ReverseParentheses(s string) string {
	return s
}
