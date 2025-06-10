package apps

import (
	"fmt"
	"strings"

	"github.com/aldotobing/neurogo/config"
	"github.com/aldotobing/neurogo/providers"
	"github.com/aldotobing/neurogo/router"
)

// PersonalAssistant represents your custom AI application
type PersonalAssistant struct {
	router   *router.Router
	openai   *providers.OpenAI
	ollama   *providers.Ollama
	deepseek *providers.DeepSeek
}

// NewPersonalAssistant creates a new personal assistant app
func NewPersonalAssistant(openaiKey, deepseekKey, ollamaHost string) *PersonalAssistant {
	app := &PersonalAssistant{
		router: router.New(),
	}

	// Initialize providers
	if openaiKey != "" {
		app.openai = providers.NewOpenAI(openaiKey)
	}
	if deepseekKey != "" {
		app.deepseek = providers.NewDeepSeek(deepseekKey)
	}
	app.ollama = providers.NewOllama(ollamaHost)

	// Setup routes
	app.setupRoutes()

	return app
}

func (app *PersonalAssistant) setupRoutes() {
	// Email assistance
	app.router.Handle("write email to * about *", app.handleEmailWriting)
	app.router.Handle("reply to email *", app.handleEmailReply)

	// Content creation
	app.router.Handle("create blog post about *", app.handleBlogPost)
	app.router.Handle("write social media post about *", app.handleSocialPost)

	// Analysis and research
	app.router.Handle("analyze * and give insights", app.handleAnalysis)
	app.router.Handle("research * and summarize", app.handleResearch)

	// Code assistance
	app.router.Handle("debug this code: *", app.handleCodeDebugging)
	app.router.Handle("optimize this code: *", app.handleCodeOptimization)

	// Personal productivity
	app.router.Handle("plan my day with these tasks: *", app.handleDayPlanning)
	app.router.Handle("create meeting agenda for *", app.handleMeetingAgenda)

	// Learning assistance
	app.router.Handle("explain * in simple terms", app.handleSimpleExplanation)
	app.router.Handle("teach me * step by step", app.handleStepByStepLearning)
}

// Email writing handler
func (app *PersonalAssistant) handleEmailWriting(ctx *router.Context) error {
	recipient := ctx.Captures[0]
	subject := ctx.Captures[1]

	prompt := fmt.Sprintf(`Write a professional email to %s about %s. 
	Make it concise, polite, and actionable. Include:
	- Clear subject line
	- Proper greeting
	- Main message
	- Call to action
	- Professional closing`, recipient, subject)

	return app.useProvider(ctx, prompt, config.CompletionOptions{
		Model:        "gpt-3.5-turbo",
		SystemPrompt: "You are a professional email writing assistant. Write clear, concise, and effective emails.",
		Temperature:  0.7,
	})
}

// Blog post creation handler
func (app *PersonalAssistant) handleBlogPost(ctx *router.Context) error {
	topic := ctx.Captures[0]

	prompt := fmt.Sprintf(`Create a comprehensive blog post about %s. Include:
	- Engaging title
	- Introduction hook
	- 3-5 main sections with subheadings
	- Practical examples or tips
	- Conclusion with key takeaways
	- SEO-friendly structure`, topic)

	return app.useProvider(ctx, prompt, config.CompletionOptions{
		Model:        "gpt-4",
		SystemPrompt: "You are an expert content creator and blogger. Write engaging, informative, and well-structured blog posts.",
		Temperature:  0.8,
	})
}

// Code debugging handler
func (app *PersonalAssistant) handleCodeDebugging(ctx *router.Context) error {
	code := ctx.Captures[0]

	prompt := fmt.Sprintf(`Debug this code and provide solutions:

%s

Please:
1. Identify any bugs or issues
2. Explain what's wrong
3. Provide corrected code
4. Suggest improvements
5. Add comments for clarity`, code)

	return app.useProvider(ctx, prompt, config.CompletionOptions{
		Model:        "codellama",
		SystemPrompt: "You are an expert software engineer. Help debug code by identifying issues and providing clear solutions.",
		Temperature:  0.3,
	})
}

// Analysis handler using DeepSeek for reasoning
func (app *PersonalAssistant) handleAnalysis(ctx *router.Context) error {
	content := ctx.Captures[0]

	prompt := fmt.Sprintf(`Analyze the following content and provide deep insights:

%s

Please provide:
1. Key themes and patterns
2. Strengths and weaknesses
3. Opportunities for improvement
4. Strategic recommendations
5. Potential risks or concerns`, content)

	return app.useProvider(ctx, prompt, config.CompletionOptions{
		Model:        "deepseek-chat",
		SystemPrompt: "You are a strategic analyst. Provide thorough, insightful analysis with actionable recommendations.",
		Temperature:  0.6,
	})
}

// Day planning handler
func (app *PersonalAssistant) handleDayPlanning(ctx *router.Context) error {
	tasks := ctx.Captures[0]

	prompt := fmt.Sprintf(`Create an optimized daily schedule for these tasks: %s

Consider:
- Task priority and urgency
- Estimated time requirements
- Energy levels throughout the day
- Buffer time for breaks
- Realistic scheduling

Provide a structured timeline from morning to evening.`, tasks)

	return app.useProvider(ctx, prompt, config.CompletionOptions{
		Model:        "gpt-3.5-turbo",
		SystemPrompt: "You are a productivity expert. Create realistic, efficient daily schedules that maximize productivity while maintaining work-life balance.",
		Temperature:  0.5,
	})
}

// Simple explanation handler
func (app *PersonalAssistant) handleSimpleExplanation(ctx *router.Context) error {
	concept := ctx.Captures[0]

	prompt := fmt.Sprintf(`Explain %s in simple, easy-to-understand terms. 
	Use analogies, examples, and avoid jargon. 
	Make it accessible to someone with no prior knowledge of the topic.`, concept)

	return app.useProvider(ctx, prompt, config.CompletionOptions{
		Model:        "gpt-3.5-turbo",
		SystemPrompt: "You are an excellent teacher who can explain complex concepts simply. Use analogies and real-world examples.",
		Temperature:  0.7,
	})
}

// Smart provider selection based on task type and availability
func (app *PersonalAssistant) useProvider(ctx *router.Context, prompt string, options config.CompletionOptions) error {
	var response string
	var err error

	// Choose provider based on task and availability
	if strings.Contains(prompt, "debug") || strings.Contains(prompt, "code") {
		// Use Ollama for code tasks
		if app.ollama != nil && app.ollama.IsAvailable() {
			response, err = app.ollama.Complete(prompt, options)
		}
	} else if strings.Contains(prompt, "analyze") || strings.Contains(prompt, "insights") {
		// Use DeepSeek for analysis
		if app.deepseek != nil && app.deepseek.IsAvailable() {
			response, err = app.deepseek.Complete(prompt, options)
		}
	} else {
		// Use OpenAI for general tasks
		if app.openai != nil && app.openai.IsAvailable() {
			response, err = app.openai.Complete(prompt, options)
		}
	}

	// Fallback to any available provider
	if err != nil || response == "" {
		if app.ollama != nil && app.ollama.IsAvailable() {
			response, err = app.ollama.Complete(prompt, options)
		} else if app.openai != nil && app.openai.IsAvailable() {
			response, err = app.openai.Complete(prompt, options)
		}
	}

	if err != nil {
		return err
	}

	ctx.Response = response
	return nil
}

// Process handles incoming requests
func (app *PersonalAssistant) Process(prompt string) (string, error) {
	return app.router.Process(prompt)
}

// GetAvailableCommands returns list of available commands
func (app *PersonalAssistant) GetAvailableCommands() []string {
	return []string{
		"write email to [person] about [topic]",
		"reply to email [content]",
		"create blog post about [topic]",
		"write social media post about [topic]",
		"analyze [content] and give insights",
		"research [topic] and summarize",
		"debug this code: [code]",
		"optimize this code: [code]",
		"plan my day with these tasks: [tasks]",
		"create meeting agenda for [meeting topic]",
		"explain [concept] in simple terms",
		"teach me [topic] step by step",
	}
}
