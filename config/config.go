package config

// CompletionOptions contains options for AI model completions
type CompletionOptions struct {
	// Model is the name of the model to use
	Model string
	
	// SystemPrompt is the system prompt to use
	SystemPrompt string
	
	// Temperature controls randomness (0.0 to 1.0)
	Temperature float64
	
	// MaxTokens is the maximum number of tokens to generate
	MaxTokens int
}

// LoadConfig loads configuration from environment variables
func LoadConfig() map[string]string {
	// This is a simple implementation
	// In a real application, you might want to use a more robust solution
	config := make(map[string]string)
	
	// Add more environment variables as needed
	return config
}
