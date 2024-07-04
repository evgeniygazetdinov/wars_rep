package lib

func DnkToRnkConvertor(someString string) string {
	result := ""
	for _, letter := range someString {
		if letter == 'T' {
			result = result + string('U')
		} else {
			result = result + string(letter)
		}
	}
	return result
}
