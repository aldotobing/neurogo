package providers

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"

	"github.com/aldotobing/neurogo/config"
)

// Ollama implements the Provider interface for Ollama API
type Ollama struct {
	host   string
	client *http.Client
}

// OllamaRequest represents the request structure for Ollama API
type OllamaRequest struct {
	Model  string  `json:"model"`
	Prompt string  `json:"prompt"`
	System string  `json:"system,omitempty"`
	Stream bool    `json:"stream"`
	Temp   float64 `json:"temperature,omitempty"`
}

// OllamaResponse represents the response structure from Ollama API
type OllamaResponse struct {
	Response string `json:"response"`
	Error    string `json:"error,omitempty"`
}

// NewOllama creates a new Ollama provider instance
func NewOllama(host string) *Ollama {
	if host == "" {
		host = "http://localhost:11434"
	}
	
	return &Ollama{
		host:   host,
		client: &http.Client{},
	}
}

// Complete sends a prompt to Ollama and returns the completion
func (o *Ollama) Complete(prompt string, options config.CompletionOptions) (string, error) {
	model := "llama2"
	if options.Model != "" {
		model = options.Model
	}

	reqBody := OllamaRequest{
		Model:  model,
		Prompt: prompt,
		System: options.SystemPrompt,
		Stream: false,
		Temp:   options.Temperature,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", o.host+"/api/generate", bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := o.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	var ollamaResp OllamaResponse
	if err := json.Unmarshal(body, &ollamaResp); err != nil {
		return "", err
	}

	if ollamaResp.Error != "" {
		return "", errors.New(ollamaResp.Error)
	}

	return ollamaResp.Response, nil
}

// Stream streams a completion from Ollama
func (o *Ollama) Stream(prompt string, options config.CompletionOptions, callback func(chunk string)) error {
	model := "llama2"
	if options.Model != "" {
		model = options.Model
	}

	reqBody := OllamaRequest{
		Model:  model,
		Prompt: prompt,
		System: options.SystemPrompt,
		Stream: true,
		Temp:   options.Temperature,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", o.host+"/api/generate", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := o.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	decoder := json.NewDecoder(resp.Body)
	for {
		var streamResp OllamaResponse
		if err := decoder.Decode(&streamResp); err != nil {
			if err == io.EOF {
				break
			}
			return err
		}

		if streamResp.Error != "" {
			return errors.New(streamResp.Error)
		}

		callback(streamResp.Response)
	}

	return nil
}

// IsAvailable checks if the Ollama provider is properly configured
func (o *Ollama) IsAvailable() bool {
	// Try to ping Ollama to see if it's running
	resp, err := o.client.Get(o.host + "/api/tags")
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == 200
}

// GetName returns the provider name
func (o *Ollama) GetName() string {
	return "Ollama"
}
