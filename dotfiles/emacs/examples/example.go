package main

import (
	"fmt"
	"os"
)

type Person struct {
	Name string
	Age  int
}

func (p Person) Greet() string {
	return fmt.Sprintf("Hello, my name is %s", p.Name)
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: example <name>")
		os.Exit(1)
	}

	person := Person{
		Name: os.Args[1],
		Age:  30,
	}

	fmt.Println(person.Greet())
}
