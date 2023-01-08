package main

import (
	"bufio"
	"log"
	"os"
)

func main() {
	fileLogin, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatalln(err)
	}
	defer fileLogin.Close()
	scan := bufio.NewScanner(fileLogin)
	creds := make([]string, 0)
	for scan.Scan() {
		creds = append(creds, scan.Text())
	}
	login, password := creds[0], creds[1]

	passwd := map[string]string{
		"1111":  "1111",
		"1234":  "1234",
		"admin": "admin",
	}

	if pass, ok := passwd[login]; ok {
		if pass == password {
			os.Exit(0)
		}
	}

	os.Exit(1)
}
