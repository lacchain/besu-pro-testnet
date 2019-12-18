package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
)

func main() {
	port := flag.String("port", "4444", "port on localhost to check")
	flag.Parse()

	resp, err := http.Get("http://127.0.0.1:" + *port + "/upcheck") // Note pointer dereference using *

	// If there is an error or non-200 status, exit with 1 signaling unsuccessful check.
	if err != nil || resp.StatusCode != 200 {
		fmt.Println("1")
		os.Exit(1)
	}
	//here a more complex cases can be added
	fmt.Println("0")
	os.Exit(0)
}
