package server

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/aldotobing/neurogo/router"
)

// ProcessRequest represents the API request structure
type ProcessRequest struct {
	Prompt string `json:"prompt"`
}

// ProcessResponse represents the API response structure
type ProcessResponse struct {
	Response string `json:"response,omitempty"`
	Error    string `json:"error,omitempty"`
}

// SetupAPIRoutes configures the API routes
func SetupAPIRoutes(r *mux.Router, neuroRouter *router.Router) {
	r.HandleFunc("/process", handleProcess(neuroRouter)).Methods("POST", "OPTIONS")
	r.HandleFunc("/routes", handleRoutes(neuroRouter)).Methods("GET")
	r.HandleFunc("/health", handleHealth).Methods("GET")
}

// handleProcess processes a prompt through the NeuroGO router
func handleProcess(neuroRouter *router.Router) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		var req ProcessRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(ProcessResponse{
				Error: "Invalid JSON payload",
			})
			return
		}

		if req.Prompt == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(ProcessResponse{
				Error: "Prompt is required",
			})
			return
		}

		response, err := neuroRouter.Process(req.Prompt)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(ProcessResponse{
				Error: err.Error(),
			})
			return
		}

		json.NewEncoder(w).Encode(ProcessResponse{
			Response: response,
		})
	}
}

// handleRoutes returns information about registered routes
func handleRoutes(neuroRouter *router.Router) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		
		routes := neuroRouter.GetRoutes()
		json.NewEncoder(w).Encode(map[string]interface{}{
			"routes": routes,
			"count":  len(routes),
		})
	}
}

// handleHealth returns the health status of the API
func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":    "healthy",
		"framework": "NeuroGO",
		"version":   "1.0.0",
	})
}
