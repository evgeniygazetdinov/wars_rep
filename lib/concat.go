package lib

func Concat(slices [][]int) []int {
	result := make([]int, 0)
	for i := 0; i < len(slices); i++ {
		for j := 0; j < len(slices[i]); j++ {
			result = append(result, slices[i][j])
		}
	}
	return result
}
