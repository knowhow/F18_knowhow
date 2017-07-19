package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os/exec"
)

func main() {
	//cmd := exec.Command("sh", "-c", "echo stdout; echo kraj ; echo 1>&2 stderr")
	cmd := exec.Command("sh", "-c", "echo stdout; echo kraj ; ./F18.sh ; echo 1>&2 stderr")
	stderr, err := cmd.StderrPipe()
	if err != nil {
		log.Fatal(err)
	}

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Fatal(err)
	}


	if err := cmd.Start(); err != nil {
		log.Fatal(err)
	}

	slurp, _ := ioutil.ReadAll(stderr)
	fmt.Printf("%s\n", slurp)

	slurp2, _ := ioutil.ReadAll(stdout)
	fmt.Printf("%s\n", slurp2)


	if err := cmd.Wait(); err != nil {
		log.Fatal(err)
	}
}
