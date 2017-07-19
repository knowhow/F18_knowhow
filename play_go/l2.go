package main

import (
    "syscall"
    "os"
    "os/exec"
    "fmt"
    "time"
 ) 

func main() {

   fmt.Println( "start" )
   binary, lookErr := exec.LookPath( "./F18" )
   if lookErr != nil {
        panic( lookErr )
   }

   fmt.Println( binary )

   //args := []string{"ls", "-a", "-l", "-h" }
   args := []string{ "2>F18.err.log" }

   env := os.Environ()

   fmt.Println( env )

    time.Sleep(10000 * time.Millisecond)


   execErr := syscall.Exec( binary, args, env )
   if execErr != nil {
      panic( execErr )
   }
}
