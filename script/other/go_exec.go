package main

import (
    "fmt"
    "io/ioutil"
    "os/exec"
)

func main() {
    cmd := exec.Command("/bin/bash","-c",`df -lh`)

    stdout, err := cmd.StdoutPipe()
    if err != nil {
        fmt.Printf("Error:can not obtain stdout pipe for command:%s\n", err)
        return
    }

    if err := cmd.Start(); err != nil {
        fmt.Println("Error:The command is err,", err)
        return
    }

    bytes, err := ioutil.ReadAll(stdout)
    if err != nil {
        fmt.Println("ReadAll Stdout:", err.Error())
        return
    }
    fmt.Printf("stdout:\n\n%s", bytes)
}
