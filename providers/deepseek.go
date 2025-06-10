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

// DeepSeek implements the Provider interface for DeepSeek API
type DeepSeek struct {
	apiKey string
	client *http.Client
}

// DeepSeekRequest represents the request structure for DeepSeek API
type DeepSeekRequest struct {
	Model       string              `json:"model"`
	Messages    []DeepSeekMessage   `json:"messages"`
	Temperature float64             `json:"temperature,omitempty"`
	MaxTokens   int                 `json:"max_tokens,omitempty"`
	Stream      bool                `json:"stream,omitempty"`
}

// DeepSeekMessage represents a message in the DeepSeek chat format
type DeepSeekMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// DeepSeekResponse represents the response structure from DeepSeek API
type DeepSeekResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
	Error struct {
		Message string `json:"message"`
		Type    string `json:"type"`
	} `json:"error"`
}

// NewDeepSeek creates a new DeepSeek provider instance
func NewDeepSeek(apiKey string) *DeepSeek {
	return &DeepSeek{
		apiKey: apiKey,
		client: &http.Client{},
	}
}

// Complete sends a prompt to DeepSeek and returns the completion
func (d *DeepSeek) Complete(prompt string, options config.CompletionOptions) (string, error) {
	if !d.IsAvailable() {
		return "", errors.New("DeepSeek API key is required")
	}

	model := "deepseek-chat"
	if options.Model != "" {
		model = options.Model
	}

	messages := []DeepSeekMessage{
		{Role: "user", Content: prompt},
	}

	if options.SystemPrompt != "" {
		// Insert system message at the beginning
		messages = append([]DeepSeekMessage{{Role: "system", Content: options.SystemPrompt}}, messages...)
	}

	reqBody := DeepSeekRequest{
		Model:       model,
		Messages:    messages,
		Temperature: options.Temperature,
		MaxTokens:   options.MaxTokens,
		Stream:      false,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest("POST", "https://api.deepseek.com/v1/chat/completions", bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", d.apiKey))

	resp, err := d.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	var deepSeekResp DeepSeekResponse
	if err := json.Unmarshal(body, &deepSeekResp); err != nil {
		return "", err
	}

	if deepSeekResp.Error.Message != "" {
		return "", errors.New(deepSeekResp.Error.Message)
	}

	if len(deepSeekResp.Choices) == 0 {
		return "", errors.New("no completion choices returned")
	}

	return deepSeekResp.Choices[0].Message.Content, nil
}

// Stream streams a completion from DeepSeek
func (d *DeepSeek) Stream(prompt string, options config.CompletionOptions, callback func(chunk string)) error {
	if !d.IsAvailable() {
		return errors.New("DeepSeek API key is required")
	}

	model := "deepseek-chat"
	if options.Model != "" {
		model = options.Model
	}

	messages := []DeepSeekMessage{
		{Role: "user", Content: prompt},
	}

	if options.SystemPrompt != "" {
		messages = append([]DeepSeekMessage{{Role: "system", Content: options.SystemPrompt}}, messages...)
	}

	reqBody := DeepSeekRequest{
		Model:       model,
		Messages:    messages,
		Temperature: options.Temperature,
		MaxTokens:   options.MaxTokens,
		Stream:      true,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", "https://api.deepseek.com/v1/chat/completions", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", d.apiKey))

	resp, err := d.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("DeepSeek API error: %s", string(body))
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

// IsAvailable checks if the DeepSeek provider is properly configured
func (d *DeepSeek) IsAvailable() bool {
	return d.apiKey != ""
}

// GetName returns the provider name
func (d *DeepSeek) GetName() string {
	return "DeepSeek"
}
