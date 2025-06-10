package server

import (
	"log"
	"net/http"

	"github.com/aldotobing/neurogo/router"
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins in development
	},
}

// WSMessage represents a WebSocket message
type WSMessage struct {
	Type     string `json:"type"`
	Prompt   string `json:"prompt,omitempty"`
	Response string `json:"response,omitempty"`
	Error    string `json:"error,omitempty"`
}

// SetupWebSocket configures WebSocket endpoints
func SetupWebSocket(r *mux.Router, neuroRouter *router.Router) {
	r.HandleFunc("/ws", handleWebSocket(neuroRouter))
}

// handleWebSocket handles WebSocket connections for real-time communication
func handleWebSocket(neuroRouter *router.Router) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			log.Printf("WebSocket upgrade error: %v", err)
			return
		}
		defer conn.Close()

		log.Println("WebSocket client connected")

		for {
			var msg WSMessage
			err := conn.ReadJSON(&msg)
			if err != nil {
				if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
					log.Printf("WebSocket error: %v", err)
				}
				break
			}

			switch msg.Type {
			case "process":
				response, err := neuroRouter.Process(msg.Prompt)
				if err != nil {
					conn.WriteJSON(WSMessage{
						Type:  "error",
						Error: err.Error(),
					})
				} else {
					conn.WriteJSON(WSMessage{
						Type:     "response",
						Response: response,
					})
				}
			default:
				conn.WriteJSON(WSMessage{
					Type:  "error",
					Error: "Unknown message type",
				})
			}
		}

		log.Println("WebSocket client disconnected")
	}
}
