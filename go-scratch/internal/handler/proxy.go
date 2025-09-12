package config

import (
	"fmt"
	"net/http"

	"github.com/gorilla/mux" // This is a new dependency
)

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Request received by the proxy!\n")
	})

	http.ListenAndServe(":8080", r)
}
