package providers

import (
	"bufio"
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/aldotobing/neurogo/config"
)

// OpenAI implements the Provider interface for OpenAI API
type OpenAI struct {
	apiKey string
	client *http.Client
}

// OpenAIRequest represents the request structure for OpenAI API
type OpenAIRequest struct {
	Model       string        `json:"model"`
	Messages    []OpenAIMessage `json:"messages"`
	Temperature float64       `json:"temperature,omitempty"`
	MaxTokens   int           `json:"max_tokens,omitempty"`
}

// OpenAIMessage represents a message in the OpenAI chat format
type OpenAIMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// OpenAIResponse represents the response structure from OpenAI API
type OpenAIResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
	Error struct {
		Message string `json:"message"`
	} `json:"error"`
}

// NewOpenAI creates a new OpenAI provider instance
func NewOpenAI(apiKey string) *OpenAI {
	return &OpenAI{
		apiKey: apiKey,
		client: &http.Client{},
	}
}

// Complete sends a prompt to OpenAI and returns the completion
func (o *OpenAI) Complete(prompt string, options config.CompletionOptions) (string, error) {
	if o.apiKey == "" {
		return "", errors.New("OpenAI API key is required")
	}

	model := "gpt-3.5-turbo"
	if options.Model != "" {
		model = options.Model
	}

	messages := []OpenAIMessage{
		{Role: "user", Content: prompt},
	}

	if options.SystemPrompt != "" {
		// Insert system message at the beginning
		messages = append([]OpenAIMessage{{Role: "system", Content: options.SystemPrompt}}, messages...)
	}

	reqBody := OpenAIRequest{
		Model:       model,
		Messages:    messages,
		Temperature: options.Temperature,
		MaxTokens:   options.MaxTokens,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", "https://api.openai.com/v1/chat/completions", bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", o.apiKey))

	resp, err := o.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	var openAIResp OpenAIResponse
	if err := json.Unmarshal(body, &openAIResp); err != nil {
		return "", err
	}

	if openAIResp.Error.Message != "" {
		return "", errors.New(openAIResp.Error.Message)
	}

	if len(openAIResp.Choices) == 0 {
		return "", errors.New("no completion choices returned")
	}

	return openAIResp.Choices[0].Message.Content, nil
}

// Stream streams a completion from OpenAI
func (o *OpenAI) Stream(prompt string, options config.CompletionOptions, callback func(chunk string)) error {
	if o.apiKey == "" {
		return errors.New("OpenAI API key is required")
	}

	model := "gpt-3.5-turbo"
	if options.Model != "" {
		model = options.Model
	}

	messages := []OpenAIMessage{
		{Role: "user", Content: prompt},
	}

	if options.SystemPrompt != "" {
		messages = append([]OpenAIMessage{{Role: "system", Content: options.SystemPrompt}}, messages...)
	}

	reqBody := map[string]interface{}{
		"model":       model,
		"messages":    messages,
		"temperature": options.Temperature,
		"max_tokens":  options.MaxTokens,
		"stream":      true,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", "https://api.openai.com/v1/chat/completions", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", o.apiKey))

	resp, err := o.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("OpenAI API error: %s", string(body))
	}

	// Process the streaming response
	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "data: ") {
			data := strings.TrimPrefix(line, "data: ")
			if data == "[DONE]" {
				break
			}

			var chunk struct {
				Choices []struct {
					Delta struct {
						Content string `json:"content"`
					} `json:"delta"`
				} `json:"choices"`
			}

			if err := json.Unmarshal([]byte(data), &chunk); err != nil {
				continue
			}

			if len(chunk.Choices) > 0 && chunk.Choices[0].Delta.Content != "" {
				callback(chunk.Choices[0].Delta.Content)
			}
		}
	}

	if err := scanner.Err(); err != nil {
		return err
	}

	return nil
}

// IsAvailable checks if the OpenAI provider is properly configured
func (o *OpenAI) IsAvailable() bool {
	return o.apiKey != ""
}

// GetName returns the provider name
func (o *OpenAI) GetName() string {
	return "OpenAI"
}
