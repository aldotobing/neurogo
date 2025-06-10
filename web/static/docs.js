let ws = null
let availableProviders = []

// Initialize on page load
window.onload = () => {
  checkAPIStatus()
  loadProviders()
  updateCurrentProvider()
}

// API Status Check
async function checkAPIStatus() {
  try {
    const response = await fetch("/api/health")
    const data = await response.json()

    const statusEl = document.getElementById("apiStatus")
    if (data.status === "healthy") {
      statusEl.innerHTML = "<span>✅</span><span>API Online</span>"
    } else {
      statusEl.innerHTML = "<span>❌</span><span>API Offline</span>"
    }
  } catch (error) {
    document.getElementById("apiStatus").innerHTML = "<span>❌</span><span>API Offline</span>"
  }
}

// Load Provider Information
async function loadProviders() {
  try {
    const response = await fetch("/api/process", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "list providers" }),
    })
    const data = await response.json()

    if (data.response) {
      parseProviders(data.response)
      updateProviderStatus()
    }
  } catch (error) {
    console.error("Failed to load providers:", error)
  }
}

// Parse provider information from response
function parseProviders(response) {
  const lines = response.split("\n")
  availableProviders = []

  lines.forEach((line) => {
    if (line.includes("🎯") || line.trim().startsWith("   ")) {
      const providerName = line.replace("🎯", "").replace(/\s+/g, " ").trim()
      if (providerName && !providerName.includes("Commands:")) {
        availableProviders.push(providerName.replace("(currently selected)", "").trim())
      }
    }
  })

  // Update provider count
  const countEl = document.getElementById("providerCount")
  countEl.innerHTML = "<span>🤖</span><span>" + availableProviders.length + " provider(s) available</span>"
}

// Update provider status indicators
function updateProviderStatus() {
  const providers = ["deepseek", "openai", "gemini", "ollama", "huggingface"]

  providers.forEach((provider) => {
    const statusEl = document.getElementById(provider + "-status")
    if (statusEl) {
      const isAvailable = availableProviders.some((p) => p.toLowerCase().includes(provider.toLowerCase()))

      if (isAvailable) {
        statusEl.textContent = "Available"
        statusEl.className = "provider-status available"
      } else {
        statusEl.textContent = "Unavailable"
        statusEl.className = "provider-status unavailable"
      }
    }
  })
}

// Update current provider display
async function updateCurrentProvider() {
  try {
    const response = await fetch("/api/process", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "current provider" }),
    })
    const data = await response.json()

    const currentEl = document.getElementById("currentProvider")
    if (data.response) {
      if (data.response.includes("auto mode")) {
        currentEl.innerHTML = "<span>🎯</span><span>Current: Auto Mode</span>"
      } else {
        const match = data.response.match(/Currently using: (\w+)/)
        if (match) {
          currentEl.innerHTML = "<span>🎯</span><span>Current: " + match[1] + "</span>"
        }
      }
    }
  } catch (error) {
    console.error("Failed to get current provider:", error)
  }
}

// Test API endpoints
async function testEndpoint(method, endpoint) {
  const resultId = endpoint.replace(/[^a-zA-Z]/g, "") + "-result"
  const resultEl = document.getElementById(resultId)

  try {
    const response = await fetch(endpoint, { method: method })
    const data = await response.json()

    resultEl.innerHTML = `<div class="test-result">
            <strong>Status:</strong> ${response.status}<br>
            <strong>Response:</strong><pre>${JSON.stringify(data, null, 2)}</pre>
        </div>`
  } catch (error) {
    resultEl.innerHTML = `<div class="test-result test-error">
            <strong>Error:</strong> ${error.message}
        </div>`
  }
}

// Test process endpoint
async function testProcessEndpoint() {
  const prompt = document.getElementById("processPrompt").value
  const resultEl = document.getElementById("process-result")

  try {
    const response = await fetch("/api/process", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: prompt,
    })
    const data = await response.json()

    resultEl.innerHTML = `<div class="test-result">
            <strong>Status:</strong> ${response.status}<br>
            <strong>Response:</strong><pre>${JSON.stringify(data, null, 2)}</pre>
        </div>`
  } catch (error) {
    resultEl.innerHTML = `<div class="test-result test-error">
            <strong>Error:</strong> ${error.message}
        </div>`
  }
}

// Test commands
async function testCommand(command) {
  const resultEl = document.getElementById("test-results")

  try {
    const response = await fetch("/api/process", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: command }),
    })
    const data = await response.json()

    const timestamp = new Date().toLocaleTimeString()
    const resultDiv = document.createElement("div")
    resultDiv.className = "test-result"
    resultDiv.innerHTML = `
            <strong>[${timestamp}] Command:</strong> ${command}<br>
            <strong>Response:</strong><pre>${data.response || data.error}</pre>
        `
    resultEl.insertBefore(resultDiv, resultEl.firstChild)

    // Update current provider after switching commands
    if (command.startsWith("use ") || command === "current provider") {
      setTimeout(updateCurrentProvider, 500)
    }
  } catch (error) {
    const timestamp = new Date().toLocaleTimeString()
    const resultDiv = document.createElement("div")
    resultDiv.className = "test-result test-error"
    resultDiv.innerHTML = `<strong>[${timestamp}] Error:</strong> ${error.message}`
    resultEl.insertBefore(resultDiv, resultEl.firstChild)
  }
}

// Test provider commands
async function testProviderCommand(command) {
  const resultEl = document.getElementById("provider-test-results")
  await testCommand(command)

  // Also update the provider test results section
  try {
    const response = await fetch("/api/process", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: command }),
    })
    const data = await response.json()

    resultEl.innerHTML = `<div class="test-result">
            <strong>Command:</strong> ${command}<br>
            <strong>Response:</strong><pre>${data.response || data.error}</pre>
        </div>`
  } catch (error) {
    resultEl.innerHTML = `<div class="test-result test-error">
            <strong>Error:</strong> ${error.message}
        </div>`
  }
}

// Clear test results
function clearResults() {
  document.getElementById("test-results").innerHTML = ""
}

// WebSocket functions
function connectWebSocket() {
  const protocol = window.location.protocol === "https:" ? "wss:" : "ws:"
  const wsUrl = protocol + "//" + window.location.host + "/ws"

  ws = new WebSocket(wsUrl)

  ws.onopen = () => {
    document.getElementById("wsStatus").innerHTML = "🟢 Connected"
    document.getElementById("wsStatus").className = "ws-status connected"
    addWSMessage("System", "Connected to WebSocket")
  }

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data)
    addWSMessage("Server", data.response || data.error || JSON.stringify(data))
  }

  ws.onclose = () => {
    document.getElementById("wsStatus").innerHTML = "🔴 Disconnected"
    document.getElementById("wsStatus").className = "ws-status disconnected"
    addWSMessage("System", "Disconnected from WebSocket")
  }

  ws.onerror = (error) => {
    addWSMessage("Error", "WebSocket error: " + error)
  }
}

function disconnectWebSocket() {
  if (ws) {
    ws.close()
    ws = null
  }
}

function sendWebSocketMessage() {
  const message = document.getElementById("wsMessage").value
  if (ws && message) {
    ws.send(
      JSON.stringify({
        type: "process",
        prompt: message,
      }),
    )
    addWSMessage("You", message)
    document.getElementById("wsMessage").value = ""
  }
}

function sendWSCommand(command) {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(
      JSON.stringify({
        type: "process",
        prompt: command,
      }),
    )
    addWSMessage("You", command)
  } else {
    addWSMessage("Error", "WebSocket not connected. Click Connect first.")
  }
}

function addWSMessage(sender, message) {
  const messagesEl = document.getElementById("wsMessages")
  const timestamp = new Date().toLocaleTimeString()
  messagesEl.innerHTML += `<div><strong>[${timestamp}] ${sender}:</strong> ${message}</div>`
  messagesEl.scrollTop = messagesEl.scrollHeight
}

// Allow Enter key for WebSocket messages
document.addEventListener("DOMContentLoaded", () => {
  const wsInput = document.getElementById("wsMessage")
  if (wsInput) {
    wsInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter") {
        sendWebSocketMessage()
      }
    })
  }
})
