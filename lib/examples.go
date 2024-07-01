package lib

func Solution(str string) []string {
	var res []string
	var myString string
	for i := 0; i < len(str); i++ {
		if i%2 != 0 {
			myString = myString + string(str[i])
			res = append(res, myString)
			myString = ""
		} else if i == len(str)-1 && i%2 == 0 {
			myString = myString + string(str[i]) + "_"
			res = append(res, myString)
		} else {
			myString = myString + string(str[i])

		}
	}
	return res
}
