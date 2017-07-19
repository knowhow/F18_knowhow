package main

import (
    "fmt"
    "os"
    "os/exec"
    "syscall"
    "time"
)

func main() {

    cmd := "./F18"
    binary, lookErr := exec.LookPath(cmd)
    if lookErr != nil {
        panic(lookErr)
    }
    fmt.Println(binary)

    os.Remove("/tmp/stdin")
    os.Remove("/tmp/stdout")
    os.Remove("/tmp/stderr")

    //fstdin, err1 := os.Create("/tmp/stdin")
    //fstdout, err2 := os.Create("/tmp/stdout")
    fstderr, err3 := os.Create("/tmp/stderr")
    if err3 != nil {
        fmt.Println(err3)
        panic("WOW")
    }

    argv := []string{}
    procAttr := syscall.ProcAttr{
        Dir:   "/tmp",
        Files: []uintptr{ uintptr(syscall.Stdin), uintptr(syscall.Stdout), fstderr.Fd()},
        Env:   []string{"VAR1=ABC123"},
        Sys: &syscall.SysProcAttr{
            Foreground: false,
        },
    }

    pid, err := syscall.Exec(binary, argv, &procAttr)
    fmt.Println("Spawned proc", pid, err)

    time.Sleep(time.Second * 100)
}
