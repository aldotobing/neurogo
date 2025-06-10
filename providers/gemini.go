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

// Gemini implements the Provider interface for Google's Gemini API
type Gemini struct {
	apiKey string
	client *http.Client
}

// GeminiRequest represents the request structure for Gemini API
type GeminiRequest struct {
	Contents []GeminiContent `json:"contents"`
	Model    string          `json:"model"`
}

// GeminiContent represents a content part in the Gemini request
type GeminiContent struct {
	Parts []GeminiPart `json:"parts"`
	Role  string       `json:"role,omitempty"`
}

// GeminiPart represents a part of content in the Gemini request
type GeminiPart struct {
	Text string `json:"text"`
}

// GeminiResponse represents the response structure from Gemini API
type GeminiResponse struct {
	Candidates []struct {
		Content struct {
			Parts []struct {
				Text string `json:"text"`
			} `json:"parts"`
		} `json:"content"`
	} `json:"candidates"`
	Error struct {
		Message string `json:"message"`
	} `json:"error"`
}

// NewGemini creates a new Gemini provider instance
func NewGemini(apiKey string) *Gemini {
	return &Gemini{
		apiKey: apiKey,
		client: &http.Client{},
	}
}

// Complete sends a prompt to Gemini and returns the completion
func (g *Gemini) Complete(prompt string, options config.CompletionOptions) (string, error) {
	if g.apiKey == "" {
		return "", errors.New("Gemini API key is required")
	}

	model := "gemini-pro"
	if options.Model != "" {
		model = options.Model
	}

	contents := []GeminiContent{
		{
			Parts: []GeminiPart{
				{Text: prompt},
			},
			Role: "user",
		},
	}

	if options.SystemPrompt != "" {
		// Add system prompt as a separate content
		contents = append([]GeminiContent{
			{
				Parts: []GeminiPart{
					{Text: options.SystemPrompt},
				},
				Role: "system",
			},
		}, contents...)
	}

	reqBody := GeminiRequest{
		Contents: contents,
		Model:    model,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	url := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", model, g.apiKey)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := g.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	var geminiResp GeminiResponse
	if err := json.Unmarshal(body, &geminiResp); err != nil {
		return "", err
	}

	if geminiResp.Error.Message != "" {
		return "", errors.New(geminiResp.Error.Message)
	}

	if len(geminiResp.Candidates) == 0 || len(geminiResp.Candidates[0].Content.Parts) == 0 {
		return "", errors.New("no completion candidates returned")
	}

	return geminiResp.Candidates[0].Content.Parts[0].Text, nil
}

// Stream streams a completion from Gemini
func (g *Gemini) Stream(prompt string, options config.CompletionOptions, callback func(chunk string)) error {
	if g.apiKey == "" {
		return errors.New("Gemini API key is required")
	}

	model := "gemini-pro"
	if options.Model != "" {
		model = options.Model
	}

	contents := []GeminiContent{
		{
			Parts: []GeminiPart{
				{Text: prompt},
			},
			Role: "user",
		},
	}

	if options.SystemPrompt != "" {
		contents = append([]GeminiContent{
			{
				Parts: []GeminiPart{
					{Text: options.SystemPrompt},
				},
				Role: "system",
			},
		}, contents...)
	}

	reqBody := map[string]interface{}{
		"contents":    contents,
		"model":       model,
		"temperature": options.Temperature,
		"max_tokens":  options.MaxTokens,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	url := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:streamGenerateContent?key=%s", model, g.apiKey)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	// Set stream parameter for streaming
	q := req.URL.Query()
	q.Add("alt", "sse")
	req.URL.RawQuery = q.Encode()

	resp, err := g.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("Gemini API error: %s", string(body))
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
				Candidates []struct {
					Content struct {
						Parts []struct {
							Text string `json:"text"`
						} `json:"parts"`
					} `json:"content"`
				} `json:"candidates"`
			}

			if err := json.Unmarshal([]byte(data), &chunk); err != nil {
				continue
			}

			if len(chunk.Candidates) > 0 && len(chunk.Candidates[0].Content.Parts) > 0 {
				callback(chunk.Candidates[0].Content.Parts[0].Text)
			}
		}
	}

	if err := scanner.Err(); err != nil {
		return err
	}

	return nil
}

// IsAvailable checks if the Gemini provider is properly configured
func (g *Gemini) IsAvailable() bool {
	return g.apiKey != ""
}

// GetName returns the provider name
func (g *Gemini) GetName() string {
	return "Gemini"
}
