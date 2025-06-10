package providers

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net/http"

	"github.com/aldotobing/neurogo/config"
)

// HuggingFace implements the Provider interface for HuggingFace Inference API
type HuggingFace struct {
	apiKey string
	client *http.Client
}

// HuggingFaceRequest represents the request structure for HuggingFace API
type HuggingFaceRequest struct {
	Inputs     string                 `json:"inputs"`
	Parameters map[string]interface{} `json:"parameters,omitempty"`
}

// NewHuggingFace creates a new HuggingFace provider instance
func NewHuggingFace(apiKey string) *HuggingFace {
	return &HuggingFace{
		apiKey: apiKey,
		client: &http.Client{},
	}
}

// Complete sends a prompt to HuggingFace and returns the completion
func (h *HuggingFace) Complete(prompt string, options config.CompletionOptions) (string, error) {
	if h.apiKey == "" {
		return "", errors.New("HuggingFace API key is required")
	}

	model := "gpt2"
	if options.Model != "" {
		model = options.Model
	}

	// Prepare system prompt if provided
	if options.SystemPrompt != "" {
		prompt = options.SystemPrompt + "\n\n" + prompt
	}

	parameters := map[string]interface{}{}
	if options.Temperature > 0 {
		parameters["temperature"] = options.Temperature
	}
	if options.MaxTokens > 0 {
		parameters["max_new_tokens"] = options.MaxTokens
	}

	reqBody := HuggingFaceRequest{
		Inputs:     prompt,
		Parameters: parameters,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", "https://api-inference.huggingface.co/models/"+model, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+h.apiKey)

	resp, err := h.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	// HuggingFace can return different response formats based on the model
	// Here we handle the most common case for text generation
	var textResponse []struct {
		GeneratedText string `json:"generated_text"`
	}
	
	if err := json.Unmarshal(body, &textResponse); err != nil {
		// Try parsing as a simple string response
		var stringResponse string
		if err := json.Unmarshal(body, &stringResponse); err != nil {
			return "", errors.New("failed to parse HuggingFace response: " + string(body))
		}
		return stringResponse, nil
	}
	
	if len(textResponse) == 0 {
		return "", errors.New("empty response from HuggingFace")
	}
	
	return textResponse[0].GeneratedText, nil
}

// Stream streams a completion from HuggingFace
func (h *HuggingFace) Stream(prompt string, options config.CompletionOptions, callback func(chunk string)) error {
	// HuggingFace Inference API doesn't support streaming directly
	// We could implement a polling mechanism here
	return errors.New("streaming not supported for HuggingFace provider")
}

// IsAvailable checks if the HuggingFace provider is properly configured
func (h *HuggingFace) IsAvailable() bool {
	return h.apiKey != ""
}

// GetName returns the provider name
func (h *HuggingFace) GetName() string {
	return "HuggingFace"
}
