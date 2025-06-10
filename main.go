package main

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"github.com/aldotobing/neurogo/config"
	"github.com/aldotobing/neurogo/providers"
	"github.com/aldotobing/neurogo/router"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize the router
	r := router.New()

	// Configure providers
	openAIProvider := providers.NewOpenAI(os.Getenv("OPENAI_API_KEY"))
	ollamaProvider := providers.NewOllama(os.Getenv("OLLAMA_HOST"))
	geminiProvider := providers.NewGemini(os.Getenv("GEMINI_API_KEY"))

	// Register routes with different providers
	r.Handle("summarize *", func(ctx *router.Context) error {
		response, err := openAIProvider.Complete(ctx.MatchedText, config.CompletionOptions{
			Model: "gpt-4o",
			SystemPrompt: "You are a summarization expert. Provide concise summaries.",
		})
		if err != nil {
			return err
		}
		ctx.Response = response
		return nil
	})

	r.Handle("translate * to *", func(ctx *router.Context) error {
		text := ctx.Captures[0]
		language := ctx.Captures[1]
		
		response, err := geminiProvider.Complete(
			fmt.Sprintf("Translate the following text to %s: %s", language, text),
			config.CompletionOptions{
				Model: "gemini-pro",
			},
		)
		if err != nil {
			return err
		}
		ctx.Response = response
		return nil
	})

	r.Handle("generate code for *", func(ctx *router.Context) error {
		response, err := ollamaProvider.Complete(
			fmt.Sprintf("Write code for: %s", ctx.Captures[0]),
			config.CompletionOptions{
				Model: "codellama",
			},
		)
		if err != nil {
			return err
		}
		ctx.Response = response
		return nil
	})

	// Example usage
	result, err := r.Process("summarize the following article: AI has made significant progress in recent years...")
	if err != nil {
		log.Fatalf("Error processing request: %v", err)
	}
	fmt.Println("Result:", result)

	result, err = r.Process("translate hello world to Spanish")
	if err != nil {
		log.Fatalf("Error processing request: %v", err)
	}
	fmt.Println("Result:", result)

	result, err = r.Process("generate code for a simple HTTP server in Go")
	if err != nil {
		log.Fatalf("Error processing request: %v", err)
	}
	fmt.Println("Result:", result)
}
