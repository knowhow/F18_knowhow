 package main

 import (
         "fmt"
         "net/http"
         "os"
         "strconv"
         "strings"
         "os/exec"
 )

 func main() {
         url := "https://d1ohg4ss876yi2.cloudfront.net/preview/golang.png"

         // we are interested in getting the file or object name
         // so take the last item from the slice
         subStringsSlice := strings.Split(url, "/")
         fileName := subStringsSlice[len(subStringsSlice)-1]

         resp, err := http.Head(url)
         if err != nil {
                 fmt.Println(err)
                 os.Exit(1)
         }

         // Is our request ok?

         if resp.StatusCode != http.StatusOK {
                 fmt.Println(resp.Status)
                 os.Exit(1)
                 // exit if not ok
         }

         // the Header "Content-Length" will let us know
         // the total file size to download
         size, _ := strconv.Atoi(resp.Header.Get("Content-Length"))
         downloadSize := int64(size)

         fmt.Println("Will be downloading ", fileName, " of ", downloadSize, " bytes.")


//       out, err := exec.Command("./F18" ).Output()
         out, _ := exec.Command( "/bin/sh", "-c", "ls" ).Output()
  	 fmt.Printf( "%s\n\n", out )

//        cmd.Stdin = &in

//  	  cmd.Stdout = &out
// 	if err != nil {
  //		log.Fatal(err)
  //	}
  	//fmt.Printf("in all caps: %q\n", out.String())

 //        fmt.Println( "cmd err2:", err2 )




	cmd := exec.Command( "/bin/sh", "-c", "./F18.sh" )

        f18In, _ := cmd.StdinPipe()
        f18Out, _ := cmd.StdoutPipe()
        cmd.Start()
        fmt.Println( f18In )
        fmt.Println( f18Out )
        cmd.Wait()
 }

