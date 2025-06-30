package main

import "fmt"
import "os"

func main() {
	fmt.Println(len(os.Args[1]))
}