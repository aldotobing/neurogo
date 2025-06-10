package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/rs/cors"

	"github.com/aldotobing/neurogo/config"
	"github.com/aldotobing/neurogo/providers"
	"github.com/aldotobing/neurogo/router"
	"github.com/aldotobing/neurogo/server"
)

// Global provider registry and current provider
var providerRegistry = make(map[string]providers.Provider)
var currentProvider = ""

func main() {
	// Debug: Print current working directory and file existence
	if cwd, err := os.Getwd(); err == nil {
		log.Printf("🔍 Current working directory: %s", cwd)
	}

	// Check if web files exist
	webFiles := []string{"../../web/docs.html", "../../web/index.html", "../../web/static/app.js", "../../web/static/style.css"}
	for _, file := range webFiles {
		if _, err := os.Stat(file); err == nil {
			log.Printf("✅ Found: %s", file)
		} else {
			log.Printf("❌ Missing: %s", file)
		}
	}

	// Load environment variables with better error handling
	loadEnvironment()

	// Initialize the NeuroGO router
	neuroRouter := router.New()

	// Configure providers
	setupProviders(neuroRouter)

	// Setup universal routes (works with any provider)
	setupUniversalRoutes(neuroRouter)

	// Setup provider switching routes
	setupProviderSwitchingRoutes(neuroRouter)

	// Setup example routes
	setupExampleRoutes(neuroRouter)

	// Create HTTP server
	httpRouter := mux.NewRouter()

	// Setup API routes
	api := httpRouter.PathPrefix("/api").Subrouter()
	server.SetupAPIRoutes(api, neuroRouter)

	// Setup WebSocket for real-time communication
	server.SetupWebSocket(httpRouter, neuroRouter)

	// Serve static files for the playground
	setupStaticFiles(httpRouter)

	// Setup CORS
	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{"*"},
	})

	handler := c.Handler(httpRouter)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("🚀 NeuroGO server starting on port %s\n", port)
	fmt.Printf("📱 Playground UI: http://localhost:%s\n", port)
	fmt.Printf("📚 API Documentation: http://localhost:%s/docs\n", port)
	fmt.Printf("🔗 API Endpoint: http://localhost:%s/api\n", port)

	log.Fatal(http.ListenAndServe(":"+port, handler))
}

// loadEnvironment loads environment variables with better error handling
func loadEnvironment() {
	// Try to load .env file from current directory
	if err := godotenv.Load(); err != nil {
		// Try to load from parent directory (in case we're in cmd/server)
		if err := godotenv.Load("../../.env"); err != nil {
			log.Println("No .env file found, using system environment variables")
		} else {
			log.Println("✅ Loaded .env file from parent directory")
		}
	} else {
		log.Println("✅ Loaded .env file successfully")
	}

	// Debug: Print which environment variables are set
	debugEnvironmentVariables()
}

// debugEnvironmentVariables prints which environment variables are detected
func debugEnvironmentVariables() {
	envVars := []string{
		"OPENAI_API_KEY",
		"DEEPSEEK_API_KEY",
		"GEMINI_API_KEY",
		"HUGGINGFACE_API_KEY",
		"OLLAMA_HOST",
	}

	log.Println("🔍 Environment Variables Status:")
	for _, envVar := range envVars {
		value := os.Getenv(envVar)
		if value != "" {
			// Don't print the full API key for security
			if len(value) > 10 {
				log.Printf("  ✅ %s: %s...%s", envVar, value[:4], value[len(value)-4:])
			} else {
				log.Printf("  ✅ %s: %s", envVar, value)
			}
		} else {
			log.Printf("  ❌ %s: not set", envVar)
		}
	}
}

// getCurrentProvider returns the currently selected provider or the best available one
func getCurrentProvider(taskType string) providers.Provider {
	// If a specific provider is selected, use it
	if currentProvider != "" {
		if provider, exists := providerRegistry[currentProvider]; exists {
			return provider
		}
	}

	// Otherwise, use the best provider for the task type
	return getBestProvider(taskType)
}

// getBestProvider returns the best available provider for a given task type
func getBestProvider(taskType string) providers.Provider {
	// Provider preferences for different task types
	preferences := map[string][]string{
		"translation": {"Gemini", "OpenAI", "DeepSeek", "Ollama"},
		"reasoning":   {"DeepSeek", "OpenAI", "Gemini", "Ollama"},
		"coding":      {"Ollama", "OpenAI", "DeepSeek", "Gemini"},
		"summary":     {"OpenAI", "DeepSeek", "Gemini", "Ollama"},
		"general":     {"OpenAI", "DeepSeek", "Gemini", "Ollama"},
	}

	providerList, exists := preferences[taskType]
	if !exists {
		providerList = preferences["general"]
	}

	// Return the first available provider from the preference list
	for _, providerName := range providerList {
		if provider, exists := providerRegistry[providerName]; exists {
			return provider
		}
	}

	// Fallback: return any available provider
	for _, provider := range providerRegistry {
		return provider
	}

	return nil
}

// getProviderList returns a list of available provider names
func getProviderList() []string {
	var providers []string
	for name := range providerRegistry {
		providers = append(providers, name)
	}
	return providers
}

func setupProviders(r *router.Router) {
	availableProviders := []string{}

	// OpenAI Provider
	if apiKey := os.Getenv("OPENAI_API_KEY"); apiKey != "" {
		openAIProvider := providers.NewOpenAI(apiKey)
		if openAIProvider.IsAvailable() {
			providerRegistry["OpenAI"] = openAIProvider
			availableProviders = append(availableProviders, "OpenAI")
			log.Println("✅ OpenAI provider configured")
		} else {
			log.Println("❌ OpenAI provider configuration failed")
		}
	} else {
		log.Println("⚠️  OpenAI API key not provided")
	}

	// DeepSeek Provider
	if apiKey := os.Getenv("DEEPSEEK_API_KEY"); apiKey != "" {
		deepSeekProvider := providers.NewDeepSeek(apiKey)
		if deepSeekProvider.IsAvailable() {
			providerRegistry["DeepSeek"] = deepSeekProvider
			availableProviders = append(availableProviders, "DeepSeek")
			log.Println("✅ DeepSeek provider configured")
		} else {
			log.Println("❌ DeepSeek provider configuration failed")
		}
	} else {
		log.Println("⚠️  DeepSeek API key not provided")
	}

	// Gemini Provider
	if apiKey := os.Getenv("GEMINI_API_KEY"); apiKey != "" {
		geminiProvider := providers.NewGemini(apiKey)
		if geminiProvider.IsAvailable() {
			providerRegistry["Gemini"] = geminiProvider
			availableProviders = append(availableProviders, "Gemini")
			log.Println("✅ Gemini provider configured")
		} else {
			log.Println("❌ Gemini provider configuration failed")
		}
	} else {
		log.Println("⚠️  Gemini API key not provided")
	}

	// Ollama Provider
	ollamaHost := os.Getenv("OLLAMA_HOST")
	if ollamaHost == "" {
		ollamaHost = "http://localhost:11434"
	}

	log.Printf("🔍 Checking Ollama at: %s", ollamaHost)
	ollamaProvider := providers.NewOllama(ollamaHost)
	if ollamaProvider.IsAvailable() {
		providerRegistry["Ollama"] = ollamaProvider
		availableProviders = append(availableProviders, "Ollama")
		log.Println("✅ Ollama provider configured")
	} else {
		log.Printf("⚠️  Ollama not available - make sure Ollama is running on %s", ollamaHost)
	}

	// HuggingFace Provider
	if apiKey := os.Getenv("HUGGINGFACE_API_KEY"); apiKey != "" {
		hfProvider := providers.NewHuggingFace(apiKey)
		if hfProvider.IsAvailable() {
			providerRegistry["HuggingFace"] = hfProvider
			availableProviders = append(availableProviders, "HuggingFace")
			log.Println("✅ HuggingFace provider configured")
		} else {
			log.Println("❌ HuggingFace provider configuration failed")
		}
	} else {
		log.Println("⚠️  HuggingFace API key not provided")
	}

	// Set default provider to the first available one
	if len(availableProviders) > 0 && currentProvider == "" {
		currentProvider = availableProviders[0]
		log.Printf("🎯 Default provider set to: %s", currentProvider)
	}

	// Log summary
	if len(availableProviders) == 0 {
		log.Println("⚠️  No AI providers configured. Only basic commands will work.")
		log.Println("💡 To get started with Ollama: run 'ollama serve' and 'ollama pull llama2'")
		log.Println("💡 Or add API keys to your .env file for cloud providers")
	} else {
		log.Printf("🎉 Configured providers: %v", availableProviders)
	}
}

// setupProviderSwitchingRoutes creates routes for switching between providers
func setupProviderSwitchingRoutes(r *router.Router) {
	// Switch to a specific provider
	r.Handle("use *", func(ctx *router.Context) error {
		providerName := normalizeProviderName(ctx.Captures[0])

		if _, exists := providerRegistry[providerName]; exists {
			currentProvider = providerName
			ctx.Response = fmt.Sprintf("✅ Switched to %s provider. All subsequent commands will use %s.", providerName, providerName)
		} else {
			availableProviders := getProviderList()
			ctx.Response = fmt.Sprintf("❌ Provider '%s' not available. Available providers: %s",
				ctx.Captures[0], strings.Join(availableProviders, ", "))
		}
		return nil
	})

	// Switch to auto mode (best provider for each task)
	r.Handle("use auto", func(ctx *router.Context) error {
		currentProvider = ""
		ctx.Response = "✅ Switched to auto mode. The system will automatically choose the best provider for each task."
		return nil
	})

	// Show current provider
	r.Handle("current provider", func(ctx *router.Context) error {
		if currentProvider == "" {
			ctx.Response = "🤖 Currently in auto mode - the system chooses the best provider for each task."
		} else {
			ctx.Response = fmt.Sprintf("🎯 Currently using: %s", currentProvider)
		}
		return nil
	})

	// List all available providers
	r.Handle("list providers", func(ctx *router.Context) error {
		providers := getProviderList()
		if len(providers) == 0 {
			ctx.Response = "❌ No providers configured."
			return nil
		}

		response := "📋 Available providers:\n\n"
		for _, name := range providers {
			if name == currentProvider {
				response += fmt.Sprintf("🎯 %s (currently selected)\n", name)
			} else {
				response += fmt.Sprintf("   %s\n", name)
			}
		}

		response += "\n💡 Commands:\n"
		response += "• 'use [provider]' - Switch to specific provider\n"
		response += "• 'use auto' - Auto-select best provider for each task\n"
		response += "• 'current provider' - Show current provider\n"
		response += "• 'list providers' - Show this list\n"

		ctx.Response = response
		return nil
	})

	// Provider-specific commands (force use of specific provider)
	r.Handle("with * *", func(ctx *router.Context) error {
		providerName := normalizeProviderName(ctx.Captures[0])
		command := ctx.Captures[1]

		provider, exists := providerRegistry[providerName]
		if !exists {
			availableProviders := getProviderList()
			ctx.Response = fmt.Sprintf("❌ Provider '%s' not available. Available providers: %s",
				ctx.Captures[0], strings.Join(availableProviders, ", "))
			return nil
		}

		// Execute the command with the specified provider
		response, err := provider.Complete(command, config.CompletionOptions{
			Model: getModelForProvider(provider),
		})
		if err != nil {
			return err
		}

		ctx.Response = fmt.Sprintf("[Using %s]\n\n%s", providerName, response)
		return nil
	})
}

// normalizeProviderName converts provider names to the correct case
func normalizeProviderName(name string) string {
	switch strings.ToLower(name) {
	case "openai":
		return "OpenAI"
	case "deepseek":
		return "DeepSeek"
	case "gemini":
		return "Gemini"
	case "ollama":
		return "Ollama"
	case "huggingface":
		return "HuggingFace"
	default:
		return strings.Title(strings.ToLower(name))
	}
}

// setupUniversalRoutes creates routes that work with any available provider
func setupUniversalRoutes(r *router.Router) {
	// Translation route - works with any provider
	r.Handle("translate * to *", func(ctx *router.Context) error {
		text := ctx.Captures[0]
		language := ctx.Captures[1]

		provider := getCurrentProvider("translation")
		if provider == nil {
			return fmt.Errorf("no AI providers available")
		}

		prompt := fmt.Sprintf("Translate the following text to %s: %s", language, text)
		response, err := provider.Complete(prompt, config.CompletionOptions{
			Model:        getModelForProvider(provider),
			SystemPrompt: "You are a professional translator. Provide accurate translations.",
		})
		if err != nil {
			return err
		}

		providerInfo := ""
		if currentProvider == "" {
			providerInfo = fmt.Sprintf("[Auto-selected: %s]\n\n", provider.GetName())
		} else {
			providerInfo = fmt.Sprintf("[Using: %s]\n\n", provider.GetName())
		}

		ctx.Response = providerInfo + response
		return nil
	})

	// Summarization route - works with any provider
	r.Handle("summarize *", func(ctx *router.Context) error {
		provider := getCurrentProvider("summary")
		if provider == nil {
			return fmt.Errorf("no AI providers available")
		}

		response, err := provider.Complete(ctx.Captures[0], config.CompletionOptions{
			Model:        getModelForProvider(provider),
			SystemPrompt: "You are a summarization expert. Provide concise, clear summaries.",
		})
		if err != nil {
			return err
		}

		providerInfo := ""
		if currentProvider == "" {
			providerInfo = fmt.Sprintf("[Auto-selected: %s]\n\n", provider.GetName())
		} else {
			providerInfo = fmt.Sprintf("[Using: %s]\n\n", provider.GetName())
		}

		ctx.Response = providerInfo + response
		return nil
	})

	// Reasoning route - works with any provider
	r.Handle("think about *", func(ctx *router.Context) error {
		provider := getCurrentProvider("reasoning")
		if provider == nil {
			return fmt.Errorf("no AI providers available")
		}

		response, err := provider.Complete(ctx.Captures[0], config.CompletionOptions{
			Model:        getModelForProvider(provider),
			SystemPrompt: "You are a deep thinking AI. Provide thoughtful, analytical responses.",
		})
		if err != nil {
			return err
		}

		providerInfo := ""
		if currentProvider == "" {
			providerInfo = fmt.Sprintf("[Auto-selected: %s]\n\n", provider.GetName())
		} else {
			providerInfo = fmt.Sprintf("[Using: %s]\n\n", provider.GetName())
		}

		ctx.Response = providerInfo + response
		return nil
	})

	// Step-by-step reasoning
	r.Handle("reason through *", func(ctx *router.Context) error {
		provider := getCurrentProvider("reasoning")
		if provider == nil {
			return fmt.Errorf("no AI providers available")
		}

		prompt := fmt.Sprintf("Please reason through this step by step: %s", ctx.Captures[0])
		response, err := provider.Complete(prompt, config.CompletionOptions{
			Model:        getModelForProvider(provider),
			SystemPrompt: "You are an expert at logical reasoning. Break down problems step by step.",
		})
		if err != nil {
			return err
		}

		providerInfo := ""
		if currentProvider == "" {
			providerInfo = fmt.Sprintf("[Auto-selected: %s]\n\n", provider.GetName())
		} else {
			providerInfo = fmt.Sprintf("[Using: %s]\n\n", provider.GetName())
		}

		ctx.Response = providerInfo + response
		return nil
	})

	// Code generation route
	r.Handle("generate code for *", func(ctx *router.Context) error {
		provider := getCurrentProvider("coding")
		if provider == nil {
			return fmt.Errorf("no AI providers available")
		}

		prompt := fmt.Sprintf("Write clean, well-documented code for: %s", ctx.Captures[0])
		response, err := provider.Complete(prompt, config.CompletionOptions{
			Model:        getModelForProvider(provider),
			SystemPrompt: "You are an expert programmer. Write clean, efficient, and well-documented code.",
		})
		if err != nil {
			return err
		}

		providerInfo := ""
		if currentProvider == "" {
			providerInfo = fmt.Sprintf("[Auto-selected: %s]\n\n", provider.GetName())
		} else {
			providerInfo = fmt.Sprintf("[Using: %s]\n\n", provider.GetName())
		}

		ctx.Response = providerInfo + response
		return nil
	})

	// General chat route
	r.Handle("chat *", func(ctx *router.Context) error {
		provider := getCurrentProvider("general")
		if provider == nil {
			return fmt.Errorf("no AI providers available")
		}

		response, err := provider.Complete(ctx.Captures[0], config.CompletionOptions{
			Model: getModelForProvider(provider),
		})
		if err != nil {
			return err
		}

		providerInfo := ""
		if currentProvider == "" {
			providerInfo = fmt.Sprintf("[Auto-selected: %s]\n\n", provider.GetName())
		} else {
			providerInfo = fmt.Sprintf("[Using: %s]\n\n", provider.GetName())
		}

		ctx.Response = providerInfo + response
		return nil
	})

	// Sentiment analysis
	r.Handle("analyze sentiment of *", func(ctx *router.Context) error {
		provider := getCurrentProvider("general")
		if provider == nil {
			return fmt.Errorf("no AI providers available")
		}

		prompt := fmt.Sprintf("Analyze the sentiment of this text and explain your reasoning: %s", ctx.Captures[0])
		response, err := provider.Complete(prompt, config.CompletionOptions{
			Model:        getModelForProvider(provider),
			SystemPrompt: "You are a sentiment analysis expert. Analyze text sentiment and provide detailed explanations.",
		})
		if err != nil {
			return err
		}

		providerInfo := ""
		if currentProvider == "" {
			providerInfo = fmt.Sprintf("[Auto-selected: %s]\n\n", provider.GetName())
		} else {
			providerInfo = fmt.Sprintf("[Using: %s]\n\n", provider.GetName())
		}

		ctx.Response = providerInfo + response
		return nil
	})
}

// getModelForProvider returns the appropriate model name for each provider
func getModelForProvider(provider providers.Provider) string {
	switch provider.GetName() {
	case "OpenAI":
		return "gpt-3.5-turbo"
	case "DeepSeek":
		return "deepseek-chat"
	case "Gemini":
		return "gemini-pro"
	case "Ollama":
		return "llama2"
	case "HuggingFace":
		return "gpt2"
	default:
		return ""
	}
}

func setupExampleRoutes(r *router.Router) {
	// Enhanced help command
	r.Handle("help", func(ctx *router.Context) error {
		help := `
🧠 NeuroGO Framework - Available Commands:

📋 General Commands:
- "help" - Show this help message
- "status" - Show system status and configured providers

🔄 Provider Management:
- "list providers" - Show all available providers
- "use [provider]" - Switch to specific provider (e.g., "use deepseek")
- "use auto" - Auto-select best provider for each task
- "current provider" - Show currently selected provider
- "with [provider] [command]" - Run one command with specific provider

🌟 Universal Commands (work with any provider):
- "translate [text] to [language]" - Translate text
- "summarize [text]" - Summarize content
- "think about [topic]" - Deep analysis
- "reason through [problem]" - Step-by-step reasoning
- "generate code for [task]" - Generate code
- "chat [message]" - General conversation
- "analyze sentiment of [text]" - Sentiment analysis

💡 Examples:
- "use deepseek" → "translate hello to Spanish"
- "with openai explain quantum computing"
- "list providers"
- "current provider"

🔧 Your configured providers: `

		var configuredProviders []string
		for name := range providerRegistry {
			configuredProviders = append(configuredProviders, name)
		}

		if len(configuredProviders) > 0 {
			help += strings.Join(configuredProviders, ", ")
		} else {
			help += "None"
		}

		if currentProvider != "" {
			help += fmt.Sprintf("\n🎯 Currently using: %s", currentProvider)
		} else {
			help += "\n🤖 Currently in auto mode"
		}

		help += `

🚀 Switch providers anytime to compare responses!
		`

		ctx.Response = help
		return nil
	})

	// Enhanced status command
	r.Handle("status", func(ctx *router.Context) error {
		status := map[string]interface{}{
			"framework": "NeuroGO",
			"version":   "1.0.0",
			"status":    "running",
			"providers": map[string]interface{}{
				"configured": []string{},
				"available":  []string{},
				"current":    currentProvider,
				"mode":       "auto",
				"total":      0,
			},
		}

		var configured []string
		for name := range providerRegistry {
			configured = append(configured, name)
		}

		if currentProvider != "" {
			status["providers"].(map[string]interface{})["mode"] = "manual"
		}

		status["providers"].(map[string]interface{})["configured"] = configured
		status["providers"].(map[string]interface{})["available"] = configured
		status["providers"].(map[string]interface{})["total"] = len(configured)

		if len(configured) == 0 {
			status["message"] = "No providers configured. Install Ollama or add API keys to get started."
		} else {
			if currentProvider != "" {
				status["message"] = fmt.Sprintf("Ready! Using %s provider. %d total provider(s) available.", currentProvider, len(configured))
			} else {
				status["message"] = fmt.Sprintf("Ready! Auto mode - %d provider(s) available: %s", len(configured), strings.Join(configured, ", "))
			}
		}

		jsonData, _ := json.MarshalIndent(status, "", "  ")
		ctx.Response = string(jsonData)
		return nil
	})
}

func setupStaticFiles(r *mux.Router) {
	// Serve static files
	staticDir := "../../web/static/"

	r.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir(staticDir))))

	// API Documentation endpoint
	r.HandleFunc("/docs", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")

		// Try multiple possible paths for docs.html
		docsPaths := []string{
			"../../web/docs.html",
			"../../web/docs.html",
			"docs.html",
		}

		for _, docsPath := range docsPaths {
			if _, err := os.Stat(docsPath); err == nil {
				log.Printf("✅ Serving docs from: %s", docsPath)
				http.ServeFile(w, r, docsPath)
				return
			}
		}

		// If no file found, log and serve fallback
		log.Println("⚠️  docs.html file not found, serving embedded fallback")
		fmt.Fprint(w, getEmbeddedDocsHTML())
	})

	// Serve the playground UI
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Try multiple possible paths for index.html
		indexPaths := []string{
			"../../web/index.html",
			"../../web/index.html",
			"index.html",
		}

		for _, indexPath := range indexPaths {
			if _, err := os.Stat(indexPath); err == nil {
				log.Printf("✅ Serving index from: %s", indexPath)
				http.ServeFile(w, r, indexPath)
				return
			}
		}

		// If no file found, serve fallback
		log.Println("⚠️  index.html file not found, serving embedded fallback")
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, getEmbeddedHTML())
	})
}

func getEmbeddedHTML() string {
	return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NeuroGO Playground</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .header h1 { color: #333; margin-bottom: 10px; }
        .header p { color: #666; }
        .nav { text-align: center; margin-bottom: 20px; }
        .nav a { display: inline-block; margin: 0 10px; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; }
        .nav a:hover { background: #0056b3; }
        .playground { background: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .input-section { margin-bottom: 20px; }
        .input-section label { display: block; margin-bottom: 5px; font-weight: 600; color: #333; }
        .input-section input, .input-section select { width: 100%; padding: 12px; border: 2px solid #ddd; border-radius: 6px; font-size: 16px; }
        .input-section input:focus, .input-section select:focus { outline: none; border-color: #007bff; }
        .button { background: #007bff; color: white; padding: 12px 24px; border: none; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 600; }
        .button:hover { background: #0056b3; }
        .button:disabled { background: #ccc; cursor: not-allowed; }
        .response { margin-top: 20px; padding: 20px; background: #f8f9fa; border-radius: 6px; border-left: 4px solid #007bff; }
        .response pre { white-space: pre-wrap; word-wrap: break-word; }
        .examples { margin-top: 30px; }
        .examples h3 { margin-bottom: 15px; color: #333; }
        .example { background: #e9ecef; padding: 10px; margin: 5px 0; border-radius: 4px; cursor: pointer; }
        .example:hover { background: #dee2e6; }
        .loading { display: none; text-align: center; margin: 20px 0; }
        .spinner { border: 3px solid #f3f3f3; border-top: 3px solid #007bff; border-radius: 50%; width: 30px; height: 30px; animation: spin 1s linear infinite; margin: 0 auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .provider-section { background: #e3f2fd; padding: 15px; border-radius: 6px; margin-bottom: 20px; }
        .provider-section h4 { color: #1565c0; margin-bottom: 10px; }
        .api-info { background: #f0f8ff; padding: 15px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid #007bff; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧠 NeuroGO Playground</h1>
            <p>Test your AI command router with natural language prompts</p>
        </div>
        
        <div class="nav">
            <a href="/docs">📚 API Documentation</a>
            <a href="/api/health">🔍 Health Check</a>
            <a href="/api/routes">🛣️ Routes</a>
        </div>
        
        <div class="playground">
            <div class="api-info">
                <h4>🔗 Available Endpoints:</h4>
                <p><strong>REST API:</strong> /api/process, /api/health, /api/routes</p>
                <p><strong>WebSocket:</strong> /ws</p>
                <p><strong>Documentation:</strong> <a href="/docs">/docs</a> (Full API testing interface)</p>
            </div>
            
            <div class="provider-section">
                <h4>🔄 Provider Management</h4>
                <p>Switch between AI providers or let the system auto-select the best one for each task.</p>
            </div>
            
            <div class="input-section">
                <label for="prompt">Enter your prompt:</label>
                <input type="text" id="prompt" placeholder="e.g., use deepseek, translate hello to Spanish" />
            </div>
            
            <button class="button" onclick="processPrompt()">Process Prompt</button>
            
            <div class="loading" id="loading">
                <div class="spinner"></div>
                <p>Processing your request...</p>
            </div>
            
            <div class="response" id="response" style="display: none;">
                <h3>Response:</h3>
                <pre id="responseText"></pre>
            </div>
            
            <div class="examples">
                <h3>Example Commands:</h3>
                
                <h4>🔄 Provider Management:</h4>
                <div class="example" onclick="setPrompt('list providers')">list providers</div>
                <div class="example" onclick="setPrompt('current provider')">current provider</div>
                <div class="example" onclick="setPrompt('use deepseek')">use deepseek</div>
                <div class="example" onclick="setPrompt('use auto')">use auto</div>
                
                <h4>🌟 Universal Commands:</h4>
                <div class="example" onclick="setPrompt('translate hello world to Spanish')">translate hello world to Spanish</div>
                <div class="example" onclick="setPrompt('think about artificial intelligence')">think about artificial intelligence</div>
                <div class="example" onclick="setPrompt('summarize the benefits of renewable energy')">summarize the benefits of renewable energy</div>
                <div class="example" onclick="setPrompt('generate code for a simple calculator')">generate code for a simple calculator</div>
                
                <h4>🎯 Provider-Specific Commands:</h4>
                <div class="example" onclick="setPrompt('with deepseek explain quantum computing')">with deepseek explain quantum computing</div>
                <div class="example" onclick="setPrompt('with openai write a poem about nature')">with openai write a poem about nature</div>
                
                <h4>📋 System Commands:</h4>
                <div class="example" onclick="setPrompt('help')">help</div>
                <div class="example" onclick="setPrompt('status')">status</div>
            </div>
        </div>
    </div>

    <script>
        function setPrompt(text) {
            document.getElementById('prompt').value = text;
        }

        async function processPrompt() {
            const prompt = document.getElementById('prompt').value.trim();
            if (!prompt) {
                alert('Please enter a prompt');
                return;
            }

            const loading = document.getElementById('loading');
            const response = document.getElementById('response');
            const responseText = document.getElementById('responseText');

            loading.style.display = 'block';
            response.style.display = 'none';

            try {
                const res = await fetch('/api/process', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ prompt: prompt })
                });

                const data = await res.json();
                
                if (data.error) {
                    responseText.textContent = 'Error: ' + data.error;
                } else {
                    responseText.textContent = data.response;
                }
                
                response.style.display = 'block';
            } catch (error) {
                responseText.textContent = 'Error: ' + error.message;
                response.style.display = 'block';
            } finally {
                loading.style.display = 'none';
            }
        }

        // Allow Enter key to submit
        document.getElementById('prompt').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                processPrompt();
            }
        });
    </script>
</body>
</html>`
}

// getEmbeddedDocsHTML returns a minimal fallback for docs if file doesn't exist
func getEmbeddedDocsHTML() string {
	return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NeuroGO API Documentation</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        h1 { color: #333; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .nav { margin: 20px 0; }
        .nav a { display: inline-block; margin-right: 15px; padding: 10px 15px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧠 NeuroGO API Documentation</h1>
        <div class="error">
            <strong>Documentation file not found.</strong><br>
            The docs.html file is missing. Please ensure web/docs.html exists.
        </div>
        <div class="nav">
            <a href="/">← Back to Playground</a>
            <a href="/api/health">Health Check</a>
            <a href="/api/routes">API Routes</a>
        </div>
        <p>For now, you can use the main playground interface or access the API endpoints directly.</p>
    </div>
</body>
</html>`
}
