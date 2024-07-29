package lib

import "slices"

func LongerCommonPrefix(myArr []string) string {
resultArr := []string{}
	longerPrefix := ""
	wordsCounter := 0
	for i := 0; i < len(myArr); i++ {
		wordsCounter++
		counter := 0
		if wordsCounter < len(myArr) {
			for j := 0; j < len(myArr[i]); j++ {
				counter++
				if counter < len(myArr[wordsCounter]) {
					if string(myArr[i][j]) == string(myArr[wordsCounter][j]) {

						longerPrefix = longerPrefix + string(myArr[i][j])

					} else {
						break
					}
				} else {
					resultArr = append(resultArr, longerPrefix)
					longerPrefix = ""
					break
				}
			}

			continue

		}
	}
	if len(resultArr) > 0 {
		return slices.Max(resultArr)
	} else {
		return ""
	}
	// переделать на сравнение первого с последнего и с конца

}