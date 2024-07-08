package lib

func SumOfSeq(begin int, end int, step int) int {
	var sum = 0
	for i := begin; i < begin*end; i = i + step {
		sum = sum + i
	}
	return sum
}
