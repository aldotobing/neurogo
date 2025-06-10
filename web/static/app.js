class NeuroGOPlayground {
  constructor() {
    this.ws = null
    this.isConnected = false
    this.currentProvider = "auto"
    this.availableProviders = []
    this.init()
  }

  init() {
    this.setupWebSocket()
    this.setupEventListeners()
    this.checkAPIHealth()
    this.loadProviderStatus()
    this.updateCurrentProvider()
  }

  setupWebSocket() {
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:"
    const wsUrl = `${protocol}//${window.location.host}/ws`

    try {
      this.ws = new WebSocket(wsUrl)

      this.ws.onopen = () => {
        this.isConnected = true
        this.updateStatus("Connected", true)
        console.log("WebSocket connected")
      }

      this.ws.onmessage = (event) => {
        const message = JSON.parse(event.data)
        this.handleWebSocketMessage(message)
      }

      this.ws.onclose = () => {
        this.isConnected = false
        this.updateStatus("Disconnected", false)
        console.log("WebSocket disconnected")

        // Attempt to reconnect after 3 seconds
        setTimeout(() => this.setupWebSocket(), 3000)
      }

      this.ws.onerror = (error) => {
        console.error("WebSocket error:", error)
        this.updateStatus("Connection Error", false)
      }
    } catch (error) {
      console.error("Failed to create WebSocket:", error)
      this.updateStatus("Connection Failed", false)
    }
  }

  setupEventListeners() {
    const promptInput = document.getElementById("promptInput")
    const sendButton = document.getElementById("sendButton")

    promptInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        this.sendPrompt()
      }
    })

    sendButton.addEventListener("click", () => this.sendPrompt())
  }

  async checkAPIHealth() {
    try {
      const response = await fetch("/api/health")
      const data = await response.json()
      console.log("API Health:", data)
    } catch (error) {
      console.error("API health check failed:", error)
    }
  }

  async loadProviderStatus() {
    try {
      const response = await fetch("/api/process", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt: "list providers" }),
      })
      const data = await response.json()

      if (data.response) {
        this.parseProviderStatus(data.response)
        this.updateProviderButtons()
      }
    } catch (error) {
      console.error("Failed to load provider status:", error)
      document.getElementById("providerStatus").innerHTML =
        '<span style="color: #dc3545;">Failed to load providers</span>'
    }
  }

  parseProviderStatus(response) {
    // Extract provider names from the response
    const lines = response.split("\n")
    this.availableProviders = []

    lines.forEach((line) => {
      if (line.includes("🎯") || line.trim().startsWith("   ")) {
        const providerName = line.replace("🎯", "").replace(/\s+/g, " ").trim()
        if (providerName && !providerName.includes("Commands:")) {
          this.availableProviders.push(providerName.replace("(currently selected)", "").trim())
        }
      }
    })

    // Update provider status display
    const statusEl = document.getElementById("providerStatus")
    if (this.availableProviders.length > 0) {
      statusEl.innerHTML = `
        <div style="color: #28a745; font-weight: 600;">
          ✅ ${this.availableProviders.length} provider(s) available
        </div>
        <div style="color: #666; font-size: 0.9rem; margin-top: 5px;">
          ${this.availableProviders.join(", ")}
        </div>
      `
    } else {
      statusEl.innerHTML = `
        <div style="color: #ffc107; font-weight: 600;">
          ⚠️ No providers configured
        </div>
        <div style="color: #666; font-size: 0.9rem; margin-top: 5px;">
          Install Ollama or add API keys to get started
        </div>
      `
    }
  }

  updateProviderButtons() {
    const providers = ["deepseek", "openai", "gemini", "ollama"]

    providers.forEach((provider) => {
      const button = document.querySelector(`.provider-btn.${provider}`)
      const statusEl = document.getElementById(`${provider}-status`)

      if (button && statusEl) {
        const isAvailable = this.availableProviders.some((p) => p.toLowerCase().includes(provider.toLowerCase()))

        if (isAvailable) {
          statusEl.className = "provider-status available"
          statusEl.textContent = "●"
          button.disabled = false
          button.style.opacity = "1"
        } else {
          statusEl.className = "provider-status unavailable"
          statusEl.textContent = "●"
          button.disabled = true
          button.style.opacity = "0.5"
        }
      }
    })
  }

  async updateCurrentProvider() {
    try {
      const response = await fetch("/api/process", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt: "current provider" }),
      })
      const data = await response.json()

      if (data.response) {
        const currentProviderEl = document.getElementById("currentProvider")
        if (data.response.includes("auto mode")) {
          this.currentProvider = "auto"
          currentProviderEl.innerHTML = "<span>🤖 Provider: Auto Mode</span>"
        } else {
          const match = data.response.match(/Currently using: (\w+)/)
          if (match) {
            this.currentProvider = match[1].toLowerCase()
            currentProviderEl.innerHTML = `<span>🎯 Provider: ${match[1]}</span>`
          }
        }
        this.updateActiveProviderButton()
      }
    } catch (error) {
      console.error("Failed to get current provider:", error)
    }
  }

  updateActiveProviderButton() {
    // Remove active class from all provider buttons
    document.querySelectorAll(".provider-btn").forEach((btn) => {
      btn.classList.remove("active")
    })

    // Add active class to current provider
    const activeButton = document.querySelector(`.provider-btn.${this.currentProvider}`)
    if (activeButton) {
      activeButton.classList.add("active")
    }
  }

  updateStatus(text, connected) {
    const statusText = document.getElementById("statusText")
    const statusIndicator = document.getElementById("statusIndicator")

    statusText.textContent = text
    statusIndicator.className = `status-indicator ${connected ? "connected" : "disconnected"}`
  }

  handleWebSocketMessage(message) {
    switch (message.type) {
      case "response":
        this.addMessage("assistant", message.response)
        break
      case "error":
        this.addMessage("assistant", `Error: ${message.error}`)
        break
      default:
        console.warn("Unknown message type:", message.type)
    }

    this.setLoading(false)
  }

  addMessage(sender, content) {
    const chatContainer = document.getElementById("chatContainer")

    // Remove welcome message if it exists
    const welcomeMessage = chatContainer.querySelector(".welcome-message")
    if (welcomeMessage) {
      welcomeMessage.remove()
    }

    const messageDiv = document.createElement("div")
    messageDiv.className = `message ${sender}`

    const contentDiv = document.createElement("div")
    contentDiv.className = "message-content"

    // Check if content looks like code or structured data
    if (this.isCodeOrStructuredData(content)) {
      const pre = document.createElement("pre")
      pre.textContent = content
      contentDiv.appendChild(pre)
    } else {
      contentDiv.textContent = content
    }

    messageDiv.appendChild(contentDiv)
    chatContainer.appendChild(messageDiv)

    // Scroll to bottom
    chatContainer.scrollTop = chatContainer.scrollHeight
  }

  isCodeOrStructuredData(content) {
    // Simple heuristic to detect code or structured data
    const codeIndicators = [
      "func ",
      "package ",
      "import ",
      "class ",
      "def ",
      "function",
      "{",
      "}",
      "```",
      "http://",
      "https://",
      "#!/",
      "SELECT",
      "FROM",
      "curl",
      "POST",
      "GET",
    ]

    return (
      codeIndicators.some((indicator) => content.toLowerCase().includes(indicator.toLowerCase())) ||
      (content.includes("\n") && content.length > 100)
    )
  }

  async sendPrompt() {
    const promptInput = document.getElementById("promptInput")
    const prompt = promptInput.value.trim()

    if (!prompt) return

    // Add user message
    this.addMessage("user", prompt)
    promptInput.value = ""

    this.setLoading(true)

    // Try WebSocket first, fallback to HTTP
    if (this.isConnected && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(
        JSON.stringify({
          type: "process",
          prompt: prompt,
        }),
      )
    } else {
      await this.sendPromptHTTP(prompt)
    }

    // Update current provider after command
    setTimeout(() => this.updateCurrentProvider(), 1000)
  }

  async sendPromptHTTP(prompt) {
    try {
      const response = await fetch("/api/process", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt: prompt }),
      })

      const data = await response.json()

      if (data.error) {
        this.addMessage("assistant", `Error: ${data.error}`)
      } else {
        this.addMessage("assistant", data.response)
      }
    } catch (error) {
      this.addMessage("assistant", `Network Error: ${error.message}`)
    } finally {
      this.setLoading(false)
    }
  }

  setLoading(loading) {
    const sendButton = document.getElementById("sendButton")
    const sendIcon = document.getElementById("sendIcon")
    const loadingIcon = document.getElementById("loadingIcon")

    sendButton.disabled = loading
    sendIcon.style.display = loading ? "none" : "inline"
    loadingIcon.style.display = loading ? "inline" : "none"
  }

  // Quick command execution
  async quickCommand(command) {
    const promptInput = document.getElementById("promptInput")
    promptInput.value = command
    await this.sendPrompt()
  }

  // Provider switching
  async switchProvider(provider) {
    const command = provider === "auto" ? "use auto" : `use ${provider}`
    await this.quickCommand(command)
  }
}

// Global functions for examples
function setPrompt(text) {
  document.getElementById("promptInput").value = text
  document.getElementById("promptInput").focus()
}

function quickCommand(command) {
  if (window.playground) {
    window.playground.quickCommand(command)
  }
}

function switchProvider(provider) {
  if (window.playground) {
    window.playground.switchProvider(provider)
  }
}

// Initialize the playground when DOM is loaded
document.addEventListener("DOMContentLoaded", () => {
  window.playground = new NeuroGOPlayground()
})
