package lib

func LongerCommonPrefix(myArr []string) string {
	resultArr := []string{}
	longerPrefix := ""
	wordsCounter := -1
	for i := 0; i < len(myArr); i++ {
		wordsCounter++
		counter := 0
		if wordsCounter <= len(myArr) {
			for j := 0; j < len(myArr[i]); j++ {
				counter++
				if counter < len(myArr[wordsCounter]) {
					if string(myArr[i][j]) == string(myArr[wordsCounter][j]) {

						longerPrefix = longerPrefix + string(myArr[i][j])

					}
					// починить проверку последнего слова с первым
				} else {
					resultArr = append(resultArr, longerPrefix)
					longerPrefix = ""
					break
				}
			}

	}
	return ""
}
