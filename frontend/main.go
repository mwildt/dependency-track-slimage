package main

import (
	"log"
	"net/http"
)

func main() {

	fs := http.FileServer(http.Dir("./dist"))

	http.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Log any errors that occur during file serving
		err := recover()
		if err != nil {
			log.Printf("Error serving static file: %s", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		} else {
			fs.ServeHTTP(w, r)
		}
	}))

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}

}
