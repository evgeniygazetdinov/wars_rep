package lib

func InitSeq() func() int {
	i := 0
	return func() int {
		i++
		return i
	}
}
