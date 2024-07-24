package lib

import "fmt"

func LongerCommonPrefix(myArr []string) string {
	longerPrefix := ""
	for i := 0; i < len(myArr); i++ {

		for j := 0; j < len(myArr[i]); j++ {
			if string(myArr[i][j]) == string(myArr[i+1][j]) {

				// переделать на про верку каждой первой второй и третье буквы в каждом слове
				fmt.Println()
				longerPrefix = longerPrefix + string(myArr[i][j])
			} else {
				break
			}
		}
	}
	return ""
}
