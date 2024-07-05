package lib

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

var reader = bufio.NewReader(os.Stdin)

func readKey(input chan rune) {
	char, _, err := reader.ReadRune()
	if err != nil {
		log.Fatal(err)
	}
	input <- char
}

func HandlePushButton() {
	input := make(chan rune, 1)

	for true {
		readKey(input)

		select {
		case i := <-input:
			if i == 68 {
				fmt.Print("\033[H\033[2J")
				fmt.Println("left")
			}
			if i == 65 {
				fmt.Print("\033[H\033[2J")
				fmt.Println("up")
			}
			if i == 67 {
				fmt.Print("\033[H\033[2J")
				fmt.Println("right")
			}
		}

	}

}
