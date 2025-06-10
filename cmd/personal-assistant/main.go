package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
	"github.com/aldotobing/neurogo/apps"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Create your personal assistant
	assistant := apps.NewPersonalAssistant(
		os.Getenv("OPENAI_API_KEY"),
		os.Getenv("DEEPSEEK_API_KEY"),
		os.Getenv("OLLAMA_HOST"),
	)

	fmt.Println("🤖 Personal AI Assistant Started!")
	fmt.Println("Type 'help' to see available commands or 'quit' to exit.")
	fmt.Println()

	scanner := bufio.NewScanner(os.Stdin)
	
	for {
		fmt.Print("You: ")
		if !scanner.Scan() {
			break
		}
		
		input := strings.TrimSpace(scanner.Text())
		if input == "" {
			continue
		}
		
		if input == "quit" || input == "exit" {
			fmt.Println("Goodbye! 👋")
			break
		}
		
		if input == "help" {
			fmt.Println("Available commands:")
			for _, cmd := range assistant.GetAvailableCommands() {
				fmt.Printf("  • %s\n", cmd)
			}
			fmt.Println()
			continue
		}
		
		fmt.Print("Assistant: ")
		response, err := assistant.Process(input)
		if err != nil {
			fmt.Printf("Error: %v\n", err)
		} else {
			fmt.Println(response)
		}
		fmt.Println()
	}
}
