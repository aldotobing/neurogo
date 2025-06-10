package router

import (
	"errors"
	"regexp"
	"strings"
)

// Handler is a function that processes a matched route
type Handler func(*Context) error

// Route represents a pattern and its associated handler
type Route struct {
	Pattern     string
	Handler     Handler
	RegexPattern *regexp.Regexp
}

// Router manages routes and processes incoming prompts
type Router struct {
	routes []*Route
}

// Context contains information about the current request
type Context struct {
	OriginalPrompt string
	MatchedPattern string
	MatchedText    string
	Captures       []string
	Response       string
}

// New creates a new Router instance
func New() *Router {
	return &Router{
		routes: make([]*Route, 0),
	}
}

// Handle registers a new route with a pattern and handler
func (r *Router) Handle(pattern string, handler Handler) {
	// Convert the pattern to a regex
	regexPattern := patternToRegex(pattern)
	compiledRegex := regexp.MustCompile(regexPattern)
	
	r.routes = append(r.routes, &Route{
		Pattern:      pattern,
		Handler:      handler,
		RegexPattern: compiledRegex,
	})
}

// Process takes a prompt and routes it to the appropriate handler
func (r *Router) Process(prompt string) (string, error) {
	for _, route := range r.routes {
		matches := route.RegexPattern.FindStringSubmatch(prompt)
		if matches != nil {
			ctx := &Context{
				OriginalPrompt: prompt,
				MatchedPattern: route.Pattern,
				MatchedText:    matches[0],
				Captures:       matches[1:],
			}
			
			err := route.Handler(ctx)
			if err != nil {
				return "", err
			}
			
			return ctx.Response, nil
		}
	}
	
	return "", errors.New("no matching route found for prompt")
}

// patternToRegex converts a wildcard pattern to a regex pattern
func patternToRegex(pattern string) string {
	// Replace * with a capture group
	parts := strings.Split(pattern, "*")
	if len(parts) == 1 {
		// No wildcards, exact match
		return "^" + regexp.QuoteMeta(pattern) + "$"
	}
	
	var regexBuilder strings.Builder
	regexBuilder.WriteString("^")
	
	for i, part := range parts {
		regexBuilder.WriteString(regexp.QuoteMeta(part))
		if i < len(parts)-1 {
			regexBuilder.WriteString("(.*?)")
		}
	}
	
	regexBuilder.WriteString("$")
	return regexBuilder.String()
}

// GetRoutes returns information about registered routes
func (r *Router) GetRoutes() []map[string]string {
	routes := make([]map[string]string, len(r.routes))
	for i, route := range r.routes {
		routes[i] = map[string]string{
			"pattern": route.Pattern,
		}
	}
	return routes
}
