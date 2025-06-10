package providers

import (
	"github.com/aldotobing/neurogo/config"
)

// Provider defines the interface for AI model providers
type Provider interface {
	// Complete sends a prompt to the AI model and returns the completion
	Complete(prompt string, options config.CompletionOptions) (string, error)
	
	// Stream streams a completion from the AI model
	Stream(prompt string, options config.CompletionOptions, callback func(chunk string)) error
	
	// IsAvailable checks if the provider is properly configured
	IsAvailable() bool
	
	// GetName returns the provider name
	GetName() string
}
