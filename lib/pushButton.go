package lib

import (
	"bufio"
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"
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
	for {
		readKey(input)
		select {
		case i := <-input:
			if i == 68 {
				fmt.Print("\033[H\033[2J")
				fmt.Println("left")

			}
			if i == 65 {
				// fmt.Print("\033[H\033[2J")
				fmt.Println("up")
			}
			if i == 10 {
				rand.Seed(time.Now().UnixNano())
				min := 10
				max := 30
				fmt.Println(rand.Intn(max-min+1) + min)
				// fmt.Println("enter pressed")
			} else {
				var s int
				_, err := fmt.Scanf("%d", &s)
				if err != nil {
					fmt.Println("err")
				}
				fmt.Println(s)
			}
		}

	}

}
