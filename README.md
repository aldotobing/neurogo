# NeuroGO

**A Universal AI Command Router Built for Maximum Flexibility**

NeuroGO is a lightweight, modular AI command router built in Go that routes natural language prompts to AI providers. Think HTTP router, but for AI - route conversational commands to any AI model with a simple, unified interface.

## 🌟 **Why NeuroGO?**

- **Provider Agnostic**: Works with OpenAI, Gemini, DeepSeek, HuggingFace, Ollama, and any future AI provider
- **Zero Lock-in**: Switch between providers without changing application logic
- **Familiar Patterns**: If you know HTTP routers, you already understand NeuroGO
- **Flexible Deployment**: Local models, cloud APIs, or hybrid setups

## 🚀 **Quick Start**

### Local Setup (No API Keys)
\`\`\`bash
# Install Ollama for local AI
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve && ollama pull llama3.1

# Run NeuroGO
git clone https://github.com/aldotobing/neurogo.git
cd neurogo && make setup && make dev

# Visit http://localhost:8080
\`\`\`

### Cloud Setup (With API Keys)
\`\`\`bash
git clone https://github.com/aldotobing/neurogo.git
cd neurogo && make setup

# Configure providers in .env
echo "OPENAI_API_KEY=sk-your-key" >> .env
echo "DEEPSEEK_API_KEY=your-key" >> .env

make dev
\`\`\`

### Docker
\`\`\`bash
git clone https://github.com/aldotobing/neurogo.git
cd neurogo && cp .env.example .env
make docker-run
\`\`\`

## 🔄 **Provider Management**

NeuroGO allows you to switch between AI providers dynamically or let the system auto-select the best provider for each task.

### **Available Providers**
| Provider | API Key Required | Best For | Status Check |
|----------|------------------|----------|--------------|
| **OpenAI** | ✅ OPENAI_API_KEY | General tasks, production | `use openai` |
| **DeepSeek** | ✅ DEEPSEEK_API_KEY | Reasoning, analysis | `use deepseek` |
| **Gemini** | ✅ GEMINI_API_KEY | Translation, multimodal | `use gemini` |
| **Ollama** | ❌ Local setup | Development, privacy | `use ollama` |
| **HuggingFace** | ✅ HUGGINGFACE_API_KEY | Specialized models | `use huggingface` |

### **Provider Switching Commands**

#### **1. Switch to Specific Provider**
\`\`\`bash
# Switch to DeepSeek for all subsequent commands
POST /api/process
{"prompt": "use deepseek"}

# Switch to OpenAI
{"prompt": "use openai"}

# Switch to Gemini  
{"prompt": "use gemini"}

# Switch to Ollama (local)
{"prompt": "use ollama"}
\`\`\`

#### **2. Auto Mode (Recommended)**
\`\`\`bash
# Let the system choose the best provider for each task
{"prompt": "use auto"}
\`\`\`

#### **3. One-Time Provider Use**
\`\`\`bash
# Use DeepSeek for this command only
{"prompt": "with deepseek explain quantum computing"}

# Use OpenAI for this command only
{"prompt": "with openai write a poem about nature"}
\`\`\`

#### **4. Provider Information**
\`\`\`bash
# List all available providers
{"prompt": "list providers"}

# Check current provider
{"prompt": "current provider"}

# System status
{"prompt": "status"}
\`\`\`

### **Example Workflow**

\`\`\`bash
# 1. Check what providers you have
curl -X POST http://localhost:8080/api/process \
  -H "Content-Type: application/json" \
  -d '{"prompt": "list providers"}'

# 2. Switch to a specific provider
curl -X POST http://localhost:8080/api/process \
  -H "Content-Type: application/json" \
  -d '{"prompt": "use deepseek"}'

# 3. Now all commands use DeepSeek
curl -X POST http://localhost:8080/api/process \
  -H "Content-Type: application/json" \
  -d '{"prompt": "translate hello to Spanish"}'

# 4. Compare with another provider
curl -X POST http://localhost:8080/api/process \
  -H "Content-Type: application/json" \
  -d '{"prompt": "with openai translate hello to Spanish"}'

# 5. Switch back to auto mode
curl -X POST http://localhost:8080/api/process \
  -H "Content-Type: application/json" \
  -d '{"prompt": "use auto"}'
\`\`\`

### **Provider Selection Logic**

When in **auto mode**, NeuroGO automatically selects the best provider based on task type:

- **Translation**: Gemini → OpenAI → DeepSeek → Ollama
- **Reasoning**: DeepSeek → OpenAI → Gemini → Ollama  
- **Coding**: Ollama → OpenAI → DeepSeek → Gemini
- **Summarization**: OpenAI → DeepSeek → Gemini → Ollama
- **General**: OpenAI → DeepSeek → Gemini → Ollama

## 🤖 **Supported Providers**

| Provider | API Key | Best For | Example Commands |
|----------|---------|----------|------------------|
| **OpenAI** | Required | General tasks, production | `summarize [text]` |
| **DeepSeek** | Required | Reasoning, analysis | `think about [topic]`, `reason through [problem]` |
| **Gemini** | Required | Translation, multimodal | `translate [text] to [language]` |
| **HuggingFace** | Required | Specialized models | `analyze sentiment of [text]` |
| **Ollama** | None (local) | Development, privacy | `chat [message]`, `generate code for [task]` |

## 💻 **Usage**

### Playground UI
Start server and visit http://localhost:8080 for interactive testing.

### Programmatic Usage
\`\`\`go
package main

import (
    "fmt"
    "log"
    "os"
    "errors"

	"github.com/joho/godotenv"
    "github.com/aldotobing/neurogo/router"
    "github.com/aldotobing/neurogo/providers"
    "github.com/aldotobing/neurogo/config"
)

func main() {
	// Load environment variables
	godotenv.Load()

	// Initialize the router
	r := router.New()

	// Configure a provider
	openAIProvider := providers.NewOpenAI(os.Getenv("OPENAI_API_KEY"))
	ollamaProvider := providers.NewOllama(os.Getenv("OLLAMA_HOST"))

	// Register a route
	r.Handle("summarize *", func(ctx *router.Context) error {
		response, err := openAIProvider.Complete(ctx.Captures[0], config.CompletionOptions{
			Model: "gpt-3.5-turbo",
			SystemPrompt: "You are a summarization expert.",
		})
		if err != nil {
			return err
		}
		ctx.Response = response
		return nil
	})

	// Process a prompt
	result, err := r.Process("summarize the latest AI research papers")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(result)
}
\`\`\`

### REST API
\`\`\`bash
curl -X POST http://localhost:8080/api/process \
  -H "Content-Type: application/json" \
  -d '{"prompt": "summarize AI developments"}'
\`\`\`

### WebSocket
\`\`\`javascript
const ws = new WebSocket('ws://localhost:8080/ws');
ws.send(JSON.stringify({
  type: 'process',
  prompt: 'translate hello to Spanish'
}));
\`\`\`

## 🔧 **Configuration**

Create `.env` file (add only what you have):
\`\`\`env
# Local
OLLAMA_HOST=http://localhost:11434

# Cloud APIs
OPENAI_API_KEY=sk-your-key
DEEPSEEK_API_KEY=your-key
GEMINI_API_KEY=your-key
HUGGINGFACE_API_KEY=your-key
\`\`\`

## 🎯 **Routing Patterns**

\`\`\`go
// Exact match
r.Handle("help", handler)

// Single capture
r.Handle("summarize *", handler)
// Input: "summarize this article" → ctx.Captures[0] = "this article"

// Multiple captures  
r.Handle("translate * to *", handler)
// Input: "translate hello to Spanish" → ctx.Captures[0] = "hello", ctx.Captures[1] = "Spanish"
\`\`\`

## ➕ **Adding New AI Providers**

### Step 1: Implement Provider Interface
Create `providers/newprovider.go`:
\`\`\`go
package providers

import (
    "github.com/aldotobing/neurogo/config"
	"net/http"
	"errors"
	"log"
	"os"
)

type NewProvider struct {
    apiKey string
    client *http.Client
}

func NewNewProvider(apiKey string) *NewProvider {
    return &NewProvider{
        apiKey: apiKey,
        client: &http.Client{},
    }
}

func (p *NewProvider) Complete(prompt string, options config.CompletionOptions) (string, error) {
    // 1. Build request to your AI service
    request := buildRequest(prompt, options)
    
    // 2. Make HTTP call
    response, err := p.client.Do(request)
    if err != nil {
        return "", err
    }
    
    // 3. Parse and return response
    return parseResponse(response)
}

func (p *NewProvider) Stream(prompt string, options config.CompletionOptions, callback func(chunk string)) error {
    // Implement streaming if supported
    return errors.New("streaming not implemented")
}

func (p *NewProvider) IsAvailable() bool {
    return p.apiKey != ""
}

func (p *NewProvider) GetName() string {
    return "NewProvider"
}
\`\`\`

### Step 2: Register Provider
Add to `cmd/server/main.go` in `setupProviders()` function:
\`\`\`go
func setupProviders(r *router.Router) {
    // ... existing providers ...
    
    // Add your new provider
    if apiKey := os.Getenv("NEWPROVIDER_API_KEY"); apiKey != "" {
        newProvider := providers.NewNewProvider(apiKey)
        if newProvider.IsAvailable() {
            log.Println("✅ NewProvider configured")
            
            r.Handle("your command pattern *", func(ctx *router.Context) error {
                response, err := newProvider.Complete(ctx.Captures[0], config.CompletionOptions{
                    Model: "your-model-name",
                })
                if err != nil {
                    return err
                }
                ctx.Response = response
                return nil
            })
        }
    }
}
\`\`\`

### Step 3: Update Environment
Add to `.env.example`:
\`\`\`env
# New Provider Configuration
NEWPROVIDER_API_KEY=your_new_provider_api_key_here
\`\`\`

### Step 4: Update Documentation
Add to the provider table in README and help command.

**That's it!** Your new provider is now integrated with automatic detection, health checks, and routing.

## 🛠️ **Development**

\`\`\`bash
make help          # Show all commands
make setup         # Setup environment
make dev           # Run with hot reload
make test          # Run tests
make build         # Build binary
make docker-run    # Run with Docker
\`\`\`

## 🏗️ **Project Structure**

\`\`\`
neurogo/
├── cmd/server/          # Server entry point
├── providers/           # AI provider implementations ← Add new providers here
├── router/              # Core routing logic
├── config/              # Configuration management
├── server/              # HTTP/WebSocket server
├── web/                 # Playground UI
└── Makefile            # Build automation
\`\`\`

## 📚 **Examples**

### Multi-Provider Routing
\`\`\`go
// Use different providers for different tasks
r.Handle("summarize *", openAIHandler)      // OpenAI for summaries
r.Handle("reason through *", deepSeekHandler) // DeepSeek for reasoning
r.Handle("translate * to *", geminiHandler)   // Gemini for translation
r.Handle("chat *", ollamaHandler)            // Ollama for general chat
\`\`\`

### Provider Fallbacks
\`\`\`go
r.Handle("ask *", func(ctx *router.Context) error {
    // Try providers in order of preference
    if openAI.IsAvailable() {
        return openAI.Complete(ctx.Captures[0], options)
    }
    if ollama.IsAvailable() {
        return ollama.Complete(ctx.Captures[0], options)
    }
    return errors.New("no providers available")
})
\`\`\`

## 🐳 **Docker Support**

\`\`\`yaml
# docker-compose.yml
version: '3.8'
services:
  neurogo:
    build: .
    ports:
      - "8080:8080"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
    depends_on:
      - ollama
  
  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
\`\`\`

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-provider`)
3. Add provider implementation in `providers/`
4. Register in `cmd/server/main.go`
5. Add tests and documentation
6. Submit pull request

## 📄 **License**

MIT License - see LICENSE file for details.

## 🆘 **Support**

- 📖 **Documentation**: Check code examples and comments
- 🐛 **Issues**: Report bugs on GitHub Issues  
- 💬 **Discussions**: Use GitHub Discussions for questions

---

**Built with ❤️ by [aldotobing](https://github.com/aldotobing)**

*NeuroGO: Where Natural Language Meets Intelligent Routing*
