package main

import (
        "os"
	"fmt"
	"os/exec"
        "time"
	"bytes"
)


func main() {

cmd := exec.Command("./F18" )
randomBytes := &bytes.Buffer{}
cmd.Stdout = randomBytes

// Start command asynchronously
err := cmd.Start()
if err != nil {
  os.Stderr.WriteString(err.Error())
}

ticker := time.NewTicker(time.Second)
go func(ticker *time.Ticker) {
  now := time.Now()
  for _ = range ticker.C {
    fmt.Printf("Ticker: %s\n", []byte(fmt.Sprintf("%s", time.Since(now))))
  }
}(ticker)

// Kill the process after 4 seconds
timer := time.NewTimer(time.Second * 4)
go func(timer *time.Timer, ticker *time.Ticker, cmd *exec.Cmd) {
  for _ = range timer.C {
    err := cmd.Process.Signal(os.Kill)
    if err != nil {
      os.Stderr.WriteString(err.Error())
    }
    ticker.Stop()
  }
}(timer, ticker, cmd)

// Wait for the command to finish
cmd.Wait()
fmt.Printf("Result: %d\n", []byte(fmt.Sprintf("%d bytes generated", len(randomBytes.Bytes()))))

}
