package main

import (
         "os"
         "os/exec"
)


 func main() {
         first := exec.Command("./F18")
//         second := exec.Command("wc", "-l")

 //         stdin, _ := cmd.StdinPipe()
 //         stdout, _ := cmd.StdoutPipe()


         // http://golang.org/pkg/io/#Pipe

//         reader, writer := io.Pipe()


    first.Stdout = os.Stdout
    first.Stdin = os.Stdin


         // push first command output to writer
      //   first.Stdout = writer

         // read from first command output
      //   first.Stdin = reader

         // prepare a buffer to capture the output
         // after second command finished executing
//         var buff bytes.Buffer
//         second.Stdout = &buff



         first.Start()

//         second.Start()
         first.Wait()
//         writer.Close()
//         second.Wait()



 }
