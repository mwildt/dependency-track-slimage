package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
)

type fileHandler struct {
	root http.FileSystem
}

func (f fileHandler) Open(name string) (http.File, error) {
	file, err := f.root.Open(name)
	if os.IsNotExist(err) {
		return f.root.Open("./index.html") // Versuche index.html, wenn die Datei nicht gefunden wird
	}
	return file, err
}

func main() {

	staticResourcesHandler := http.FileServer(fileHandler{http.Dir("./dist")})

	apiTarget, _ := url.Parse(os.Getenv("API_SERVICE_URL"))
	apiHandler := httputil.NewSingleHostReverseProxy(apiTarget)

	http.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.URL.Path, "/api/") {
			apiHandler.ServeHTTP(w, r)
		} else {
			staticResourcesHandler.ServeHTTP(w, r)
		}
	}))

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}

}
