package apps

import (
	"fmt"
	"time"

	"github.com/aldotobing/neurogo/config"
	"github.com/aldotobing/neurogo/providers"
	"github.com/aldotobing/neurogo/router"
)

// ContentManager handles content creation and management
type ContentManager struct {
	router   *router.Router
	provider providers.Provider
	history  []ContentItem
}

type ContentItem struct {
	ID        string    `json:"id"`
	Type      string    `json:"type"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	Tags      []string  `json:"tags"`
}

func NewContentManager(provider providers.Provider) *ContentManager {
	cm := &ContentManager{
		router:   router.New(),
		provider: provider,
		history:  make([]ContentItem, 0),
	}

	cm.setupRoutes()
	return cm
}

func (cm *ContentManager) setupRoutes() {
	// Content creation
	cm.router.Handle("create * content about *", cm.handleContentCreation)
	cm.router.Handle("write * for * audience", cm.handleTargetedContent)
	cm.router.Handle("generate * ideas for *", cm.handleIdeaGeneration)

	// Content optimization
	cm.router.Handle("improve this content: *", cm.handleContentImprovement)
	cm.router.Handle("make this * more engaging: *", cm.handleEngagementOptimization)
	cm.router.Handle("adapt this content for *: *", cm.handleContentAdaptation)

	// Content management
	cm.router.Handle("list my * content", cm.handleContentListing)
	cm.router.Handle("search content about *", cm.handleContentSearch)
	cm.router.Handle("export content as *", cm.handleContentExport)
}

func (cm *ContentManager) handleContentCreation(ctx *router.Context) error {
	contentType := ctx.Captures[0]
	topic := ctx.Captures[1]

	prompt := fmt.Sprintf(`Create a %s about %s. Make it:
	- Engaging and well-structured
	- Appropriate for the content type
	- Include relevant examples
	- Have a clear call-to-action
	- Be optimized for the target platform`, contentType, topic)

	response, err := cm.provider.Complete(prompt, config.CompletionOptions{
		Model:        "gpt-4",
		SystemPrompt: fmt.Sprintf("You are an expert %s creator. Create high-quality, engaging content.", contentType),
		Temperature:  0.8,
	})

	if err != nil {
		return err
	}

	// Save to history
	item := ContentItem{
		ID:        fmt.Sprintf("%d", time.Now().Unix()),
		Type:      contentType,
		Title:     fmt.Sprintf("%s about %s", contentType, topic),
		Content:   response,
		CreatedAt: time.Now(),
		Tags:      []string{contentType, topic},
	}
	cm.history = append(cm.history, item)

	ctx.Response = response
	return nil
}

func (cm *ContentManager) handleContentListing(ctx *router.Context) error {
	contentType := ctx.Captures[0]

	var filtered []ContentItem
	for _, item := range cm.history {
		if item.Type == contentType {
			filtered = append(filtered, item)
		}
	}

	if len(filtered) == 0 {
		ctx.Response = fmt.Sprintf("No %s content found.", contentType)
		return nil
	}

	result := fmt.Sprintf("Found %d %s items:\n\n", len(filtered), contentType)
	for _, item := range filtered {
		result += fmt.Sprintf("• %s (Created: %s)\n", item.Title, item.CreatedAt.Format("2006-01-02 15:04"))
	}

	ctx.Response = result
	return nil
}

func (cm *ContentManager) Process(prompt string) (string, error) {
	return cm.router.Process(prompt)
}
