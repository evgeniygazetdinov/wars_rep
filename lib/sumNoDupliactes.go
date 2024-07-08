package lib

func removeDuplicatesFromArray(arrayWithDuplicates []int) []int {
	var resultArr []int
	seen := make(map[int]bool)
	for _, i := range arrayWithDuplicates {
		if _, ok := seen[i]; !ok {
			seen[i] = true
			resultArr = append(resultArr, i)
		}
	}
	return resultArr
}

func SumNoDuplicates(arr []int) int {
	sumOfArray := 0
	arrayWithoutDuplicates := removeDuplicatesFromArray(arr)

	for i := 0; i < len(arrayWithoutDuplicates); i++ {
		sumOfArray = sumOfArray + int(arrayWithoutDuplicates[i])
	}
	return sumOfArray
}
