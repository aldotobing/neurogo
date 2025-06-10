#!/bin/bash

# Script to set up web files in the correct locations
echo "🌐 Setting up NeuroGO web files..."

# Get the project root directory
PROJECT_ROOT=$(pwd)
echo "📂 Project root: $PROJECT_ROOT"

# Create necessary directories
mkdir -p web/static

# Check if web directories exist
if [ -d "$PROJECT_ROOT/web" ]; then
    echo "✅ web directory exists"
else
    echo "❌ web directory not found, creating..."
    mkdir -p "$PROJECT_ROOT/web"
fi

if [ -d "$PROJECT_ROOT/web/static" ]; then
    echo "✅ web/static directory exists"
else
    echo "❌ web/static directory not found, creating..."
    mkdir -p "$PROJECT_ROOT/web/static"
fi

# Copy HTML files to the correct locations
echo "📝 Creating web/docs.html..."
cat > "$PROJECT_ROOT/web/docs.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NeuroGO API Documentation</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh; 
            line-height: 1.6; 
            color: #333;
        }
        .container { max-width: 1400px; margin: 0 auto; padding: 20px; }
        
        /* Header Styles */
        .header { 
            text-align: center; 
            margin-bottom: 30px; 
            background: white; 
            padding: 40px; 
            border-radius: 20px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .header h1 { color: #333; margin-bottom: 15px; font-size: 2.5rem; font-weight: 700; }
        .header p { color: #666; font-size: 1.2rem; margin-bottom: 20px; }
        
        /* Status Bar */
        .status-bar {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        .status-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            background: #f8f9fa;
            border-radius: 20px;
            font-weight: 500;
        }
        
        /* Navigation */
        .nav { 
            background: white; 
            padding: 20px; 
            border-radius: 15px; 
            margin-bottom: 20px; 
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
        }
        .nav a { 
            display: inline-block; 
            padding: 12px 20px; 
            background: #007bff; 
            color: white; 
            text-decoration: none; 
            border-radius: 25px; 
            transition: all 0.3s ease;
            font-weight: 500;
        }
        .nav a:hover { background: #0056b3; transform: translateY(-2px); }
        
        /* Section Styles */
        .section { 
            background: white; 
            margin-bottom: 25px; 
            padding: 35px; 
            border-radius: 15px; 
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .section h2 { 
            color: #333; 
            margin-bottom: 25px; 
            border-bottom: 3px solid #007bff; 
            padding-bottom: 15px; 
            font-size: 1.8rem;
        }
        .section h3 { 
            color: #555; 
            margin: 25px 0 15px 0; 
            font-size: 1.3rem;
        }
        .section h4 {
            color: #666;
            margin: 20px 0 10px 0;
            font-size: 1.1rem;
        }
        
        /* Provider Management Styles */
        .provider-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .provider-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            border-left: 4px solid #007bff;
        }
        .provider-card.deepseek { border-left-color: #8e44ad; }
        .provider-card.openai { border-left-color: #2ecc71; }
        .provider-card.gemini { border-left-color: #f39c12; }
        .provider-card.ollama { border-left-color: #e74c3c; }
        .provider-card.huggingface { border-left-color: #3498db; }
        
        .provider-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
        }
        .provider-icon { font-size: 1.5rem; }
        .provider-name { font-weight: 600; font-size: 1.1rem; }
        .provider-status { 
            margin-left: auto; 
            padding: 4px 8px; 
            border-radius: 12px; 
            font-size: 0.8rem; 
            font-weight: 600;
        }
        .provider-status.available { background: #d4edda; color: #155724; }
        .provider-status.unavailable { background: #f8d7da; color: #721c24; }
        
        /* Command Examples */
        .command-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .command-example {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #28a745;
        }
        .command-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .command-desc {
            color: #666;
            margin-bottom: 15px;
            font-size: 0.95rem;
        }
        
        /* Endpoint Styles */
        .endpoint { 
            background: #f8f9fa; 
            padding: 25px; 
            border-radius: 12px; 
            margin: 20px 0; 
            border-left: 4px solid #007bff;
        }
        .method { 
            display: inline-block; 
            padding: 6px 12px; 
            border-radius: 6px; 
            color: white; 
            font-weight: bold; 
            margin-right: 15px; 
            font-size: 0.9rem;
        }
        .method.get { background: #28a745; }
        .method.post { background: #007bff; }
        .method.put { background: #ffc107; color: #333; }
        .method.delete { background: #dc3545; }
        
        /* Code Styles */
        .code { 
            background: #2d3748; 
            color: #e2e8f0;
            padding: 20px; 
            border-radius: 8px; 
            font-family: 'Monaco', 'Menlo', monospace; 
            overflow-x: auto; 
            margin: 15px 0;
            font-size: 0.9rem;
        }
        .code-inline {
            background: #f1f3f4;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 0.9em;
        }
        
        /* Test Section Styles */
        .test-section { 
            background: #e3f2fd; 
            padding: 25px; 
            border-radius: 12px; 
            margin: 20px 0;
        }
        .test-button { 
            background: #007bff; 
            color: white; 
            padding: 12px 20px; 
            border: none; 
            border-radius: 8px; 
            cursor: pointer; 
            margin: 8px; 
            font-weight: 500;
            transition: all 0.2s ease;
        }
        .test-button:hover { background: #0056b3; transform: translateY(-1px); }
        .test-button.provider-test { margin: 5px; padding: 8px 16px; font-size: 0.9rem; }
        
        .test-result { 
            background: #f8f9fa; 
            padding: 20px; 
            border-radius: 8px; 
            margin-top: 15px; 
            border-left: 4px solid #28a745;
            font-family: monospace;
            font-size: 0.9rem;
        }
        .test-error { border-left-color: #dc3545; }
        
        /* Form Elements */
        textarea { 
            width: 100%; 
            padding: 15px; 
            border: 2px solid #e9ecef; 
            border-radius: 8px; 
            font-family: monospace;
            font-size: 0.9rem;
            resize: vertical;
        }
        textarea:focus {
            outline: none;
            border-color: #007bff;
        }
        
        /* WebSocket Styles */
        .ws-container {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin: 15px 0;
        }
        .ws-status {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            margin-bottom: 15px;
        }
        .ws-status.connected { background: #d4edda; color: #155724; }
        .ws-status.disconnected { background: #f8d7da; color: #721c24; }
        
        .ws-messages {
            background: #2d3748;
            color: #e2e8f0;
            padding: 15px;
            border-radius: 8px;
            height: 200px;
            overflow-y: auto;
            font-family: monospace;
            font-size: 0.9rem;
            margin-top: 10px;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .container { padding: 10px; }
            .header h1 { font-size: 2rem; }
            .provider-grid, .command-grid { grid-template-columns: 1fr; }
            .status-bar { flex-direction: column; gap: 10px; }
            .nav { flex-direction: column; }
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .section { animation: fadeIn 0.5s ease-out; }
        
        /* Utility Classes */
        .text-center { text-align: center; }
        .mb-20 { margin-bottom: 20px; }
        .mt-20 { margin-top: 20px; }
        .flex { display: flex; }
        .items-center { align-items: center; }
        .gap-10 { gap: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧠 NeuroGO API Documentation</h1>
            <p>Complete API reference with provider switching capabilities</p>
            <div class="status-bar">
                <div class="status-item" id="apiStatus">
                    <span>🔍</span>
                    <span>Checking API status...</span>
                </div>
                <div class="status-item" id="providerCount">
                    <span>🤖</span>
                    <span>Loading providers...</span>
                </div>
                <div class="status-item" id="currentProvider">
                    <span>🎯</span>
                    <span>Current: Loading...</span>
                </div>
            </div>
        </div>

        <div class="nav">
            <a href="#overview">📋 Overview</a>
            <a href="#providers">🔄 Provider Management</a>
            <a href="#endpoints">🔗 API Endpoints</a>
            <a href="#testing">🧪 Live Testing</a>
            <a href="#websocket">🔌 WebSocket</a>
            <a href="/">← Back to Playground</a>
        </div>

        <div class="section" id="overview">
            <h2>📋 API Overview</h2>
            <p>NeuroGO provides a RESTful API for processing natural language prompts through various AI providers with dynamic provider switching capabilities.</p>
            
            <h3>🌟 Key Features</h3>
            <div class="command-grid">
                <div class="command-example">
                    <div class="command-title">
                        <span>🔄</span>
                        <span>Dynamic Provider Switching</span>
                    </div>
                    <div class="command-desc">Switch between AI providers on-the-fly or let the system auto-select the best provider for each task.</div>
                </div>
                <div class="command-example">
                    <div class="command-title">
                        <span>🎯</span>
                        <span>Provider-Specific Commands</span>
                    </div>
                    <div class="command-desc">Use specific providers for individual commands without changing the global setting.</div>
                </div>
                <div class="command-example">
                    <div class="command-title">
                        <span>🤖</span>
                        <span>Intelligent Auto-Selection</span>
                    </div>
                    <div class="command-desc">Automatic provider selection based on task type (translation, reasoning, coding, etc.).</div>
                </div>
                <div class="command-example">
                    <div class="command-title">
                        <span>🔌</span>
                        <span>Real-time Communication</span>
                    </div>
                    <div class="command-desc">WebSocket support for real-time AI interactions and streaming responses.</div>
                </div>
            </div>
            
            <h3>🔗 Base Configuration</h3>
            <div class="code">Base URL: http://localhost:8080/api
Content-Type: application/json
WebSocket: ws://localhost:8080/ws</div>
        </div>

        <div class="section" id="providers">
            <h2>🔄 Provider Management</h2>
            <p>NeuroGO supports multiple AI providers with seamless switching capabilities. Each provider has unique strengths for different types of tasks.</p>
            
            <h3>📊 Available Providers</h3>
            <div class="provider-grid" id="providerGrid">
                <div class="provider-card deepseek">
                    <div class="provider-header">
                        <span class="provider-icon">🧠</span>
                        <span class="provider-name">DeepSeek</span>
                        <span class="provider-status unavailable" id="deepseek-status">Checking...</span>
                    </div>
                    <div><strong>Best for:</strong> Reasoning, analysis, complex problem solving</div>
                    <div><strong>Requires:</strong> DEEPSEEK_API_KEY</div>
                    <div><strong>Models:</strong> deepseek-chat, deepseek-coder</div>
                </div>
                
                <div class="provider-card openai">
                    <div class="provider-header">
                        <span class="provider-icon">🤖</span>
                        <span class="provider-name">OpenAI</span>
                        <span class="provider-status unavailable" id="openai-status">Checking...</span>
                    </div>
                    <div><strong>Best for:</strong> General tasks, production use, creative writing</div>
                    <div><strong>Requires:</strong> OPENAI_API_KEY</div>
                    <div><strong>Models:</strong> gpt-3.5-turbo, gpt-4, gpt-4-turbo</div>
                </div>
                
                <div class="provider-card gemini">
                    <div class="provider-header">
                        <span class="provider-icon">✨</span>
                        <span class="provider-name">Gemini</span>
                        <span class="provider-status unavailable" id="gemini-status">Checking...</span>
                    </div>
                    <div><strong>Best for:</strong> Translation, multimodal tasks</div>
                    <div><strong>Requires:</strong> GEMINI_API_KEY</div>
                    <div><strong>Models:</strong> gemini-pro, gemini-pro-vision</div>
                </div>
                
                <div class="provider-card ollama">
                    <div class="provider-header">
                        <span class="provider-icon">🏠</span>
                        <span class="provider-name">Ollama</span>
                        <span class="provider-status unavailable" id="ollama-status">Checking...</span>
                    </div>
                    <div><strong>Best for:</strong> Local development, privacy, coding</div>
                    <div><strong>Requires:</strong> Local Ollama installation</div>
                    <div><strong>Models:</strong> llama2, codellama, mistral, etc.</div>
                </div>
                
                <div class="provider-card huggingface">
                    <div class="provider-header">
                        <span class="provider-icon">🤗</span>
                        <span class="provider-name">HuggingFace</span>
                        <span class="provider-status unavailable" id="huggingface-status">Checking...</span>
                    </div>
                    <div><strong>Best for:</strong> Specialized models, research</div>
                    <div><strong>Requires:</strong> HUGGINGFACE_API_KEY</div>
                    <div><strong>Models:</strong> Various open-source models</div>
                </div>
            </div>

            <h3>🔄 Provider Switching Commands</h3>
            <div class="command-grid">
                <div class="command-example">
                    <div class="command-title">
                        <span>🎯</span>
                        <span>Switch to Specific Provider</span>
                    </div>
                    <div class="command-desc">Change the active provider for all subsequent commands</div>
                    <div class="code">POST /api/process
{
  "prompt": "use deepseek"
}

// Other examples:
// "use openai"
// "use gemini" 
// "use ollama"</div>
                </div>
                
                <div class="command-example">
                    <div class="command-title">
                        <span>🤖</span>
                        <span>Auto Mode</span>
                    </div>
                    <div class="command-desc">Let the system choose the best provider for each task</div>
                    <div class="code">POST /api/process
{
  "prompt": "use auto"
}</div>
                </div>
                
                <div class="command-example">
                    <div class="command-title">
                        <span>⚡</span>
                        <span>One-Time Provider Use</span>
                    </div>
                    <div class="command-desc">Use a specific provider for a single command</div>
                    <div class="code">POST /api/process
{
  "prompt": "with deepseek explain quantum computing"
}

// Other examples:
// "with openai write a poem"
// "with gemini translate hello to French"</div>
                </div>
                
                <div class="command-example">
                    <div class="command-title">
                        <span>📋</span>
                        <span>Provider Information</span>
                    </div>
                    <div class="command-desc">Get information about available providers</div>
                    <div class="code">// List all providers
{"prompt": "list providers"}

// Check current provider  
{"prompt": "current provider"}

// System status
{"prompt": "status"}</div>
                </div>
            </div>

            <h3>🎯 Auto-Selection Logic</h3>
            <p>When in auto mode, NeuroGO intelligently selects providers based on task type:</p>
            <div class="command-grid">
                <div class="command-example">
                    <div class="command-title">🌐 Translation Tasks</div>
                    <div class="command-desc">Gemini → OpenAI → DeepSeek → Ollama</div>
                </div>
                <div class="command-example">
                    <div class="command-title">🧠 Reasoning Tasks</div>
                    <div class="command-desc">DeepSeek → OpenAI → Gemini → Ollama</div>
                </div>
                <div class="command-example">
                    <div class="command-title">💻 Coding Tasks</div>
                    <div class="command-desc">Ollama → OpenAI → DeepSeek → Gemini</div>
                </div>
                <div class="command-example">
                    <div class="command-title">📝 General Tasks</div>
                    <div class="command-desc">OpenAI → DeepSeek → Gemini → Ollama</div>
                </div>
            </div>

            <h3>🧪 Quick Provider Tests</h3>
            <div class="test-section">
                <h4>Test Provider Switching:</h4>
                <button class="test-button provider-test" onclick="testProviderCommand('list providers')">📋 List Providers</button>
                <button class="test-button provider-test" onclick="testProviderCommand('current provider')">🎯 Current Provider</button>
                <button class="test-button provider-test" onclick="testProviderCommand('use auto')">🤖 Auto Mode</button>
                <button class="test-button provider-test" onclick="testProviderCommand('use deepseek')">🧠 Use DeepSeek</button>
                <button class="test-button provider-test" onclick="testProviderCommand('use openai')">🤖 Use OpenAI</button>
                <button class="test-button provider-test" onclick="testProviderCommand('use gemini')">✨ Use Gemini</button>
                <button class="test-button provider-test" onclick="testProviderCommand('use ollama')">🏠 Use Ollama</button>
                <div id="provider-test-results"></div>
            </div>
        </div>

        <div class="section" id="endpoints">
            <h2>🔗 API Endpoints</h2>
            
            <div class="endpoint">
                <h3><span class="method get">GET</span> /api/health</h3>
                <p>Check API health status and get system information</p>
                <h4>Response:</h4>
                <div class="code">{
  "status": "healthy",
  "framework": "NeuroGO", 
  "version": "1.0.0"
}</div>
                <div class="test-section">
                    <button class="test-button" onclick="testEndpoint('GET', '/api/health')">🔍 Test Health Check</button>
                    <div id="health-result"></div>
                </div>
            </div>

            <div class="endpoint">
                <h3><span class="method get">GET</span> /api/routes</h3>
                <p>Get information about registered command routes</p>
                <h4>Response:</h4>
                <div class="code">{
  "routes": [
    {"pattern": "translate * to *"},
    {"pattern": "summarize *"},
    {"pattern": "use *"}
  ],
  "count": 3
}</div>
                <div class="test-section">
                    <button class="test-button" onclick="testEndpoint('GET', '/api/routes')">🛣️ Test Routes</button>
                    <div id="routes-result"></div>
                </div>
            </div>

            <div class="endpoint">
                <h3><span class="method post">POST</span> /api/process</h3>
                <p>Process a natural language prompt with the current or specified provider</p>
                
                <h4>Request Body:</h4>
                <div class="code">{
  "prompt": "string (required)"
}</div>
                
                <h4>Response:</h4>
                <div class="code">{
  "response": "AI generated response",
  "error": "error message (if error occurred)"
}</div>
                
                <h4>Example Requests:</h4>
                <div class="code">// Provider switching
curl -X POST http://localhost:8080/api/process \\
  -H "Content-Type: application/json" \\
  -d '{"prompt": "use deepseek"}'

// Universal command (uses current provider)
curl -X POST http://localhost:8080/api/process \\
  -H "Content-Type: application/json" \\
  -d '{"prompt": "translate hello to Spanish"}'

// Provider-specific command
curl -X POST http://localhost:8080/api/process \\
  -H "Content-Type: application/json" \\
  -d '{"prompt": "with openai explain AI"}'</div>
                
                <div class="test-section">
                    <h4>Test Process Endpoint:</h4>
                    <textarea id="processPrompt" rows="4" placeholder='{"prompt": "help"}'>{"prompt": "help"}</textarea>
                    <br><br>
                    <button class="test-button" onclick="testProcessEndpoint()">🚀 Test Process</button>
                    <div id="process-result"></div>
                </div>
            </div>
        </div>

        <div class="section" id="testing">
            <h2>🧪 Live API Testing</h2>
            <p>Test various commands and provider switching functionality in real-time:</p>
            
            <div class="test-section">
                <h3>🔄 Provider Management Tests</h3>
                <button class="test-button" onclick="testCommand('list providers')">📋 List Providers</button>
                <button class="test-button" onclick="testCommand('current provider')">🎯 Current Provider</button>
                <button class="test-button" onclick="testCommand('use auto')">🤖 Auto Mode</button>
                <button class="test-button" onclick="testCommand('status')">📊 System Status</button>
            </div>

            <div class="test-section">
                <h3>⚡ Provider Switching Tests</h3>
                <button class="test-button" onclick="testCommand('use deepseek')">🧠 Use DeepSeek</button>
                <button class="test-button" onclick="testCommand('use openai')">🤖 Use OpenAI</button>
                <button class="test-button" onclick="testCommand('use gemini')">✨ Use Gemini</button>
                <button class="test-button" onclick="testCommand('use ollama')">🏠 Use Ollama</button>
            </div>

            <div class="test-section">
                <h3>🌟 Universal Command Tests</h3>
                <button class="test-button" onclick="testCommand('translate hello to Spanish')">🌐 Translation</button>
                <button class="test-button" onclick="testCommand('think about artificial intelligence')">🤔 Deep Thinking</button>
                <button class="test-button" onclick="testCommand('summarize AI is transforming the world')">📝 Summarization</button>
                <button class="test-button" onclick="testCommand('generate code for hello world')">💻 Code Generation</button>
                <button class="test-button" onclick="testCommand('chat how are you?')">💬 Chat</button>
            </div>

            <div class="test-section">
                <h3>🎯 Provider-Specific Tests</h3>
                <button class="test-button" onclick="testCommand('with deepseek explain quantum computing')">🧠 DeepSeek Analysis</button>
                <button class="test-button" onclick="testCommand('with openai write a haiku about nature')">🤖 OpenAI Creative</button>
                <button class="test-button" onclick="testCommand('with gemini translate bonjour to English')">✨ Gemini Translation</button>
                <button class="test-button" onclick="testCommand('with ollama chat tell me a joke')">🏠 Ollama Chat</button>
            </div>

            <div class="test-section">
                <h3>📊 Test Results</h3>
                <div id="test-results" style="max-height: 400px; overflow-y: auto;"></div>
                <button class="test-button" onclick="clearResults()" style="background: #6c757d;">🗑️ Clear Results</button>
            </div>
        </div>

        <div class="section" id="websocket">
            <h2>🔌 WebSocket API</h2>
            <p>Real-time communication via WebSocket for interactive AI conversations</p>
            
            <h3>🔗 Connection</h3>
            <div class="code">WebSocket URL: ws://localhost:8080/ws
Protocol: WebSocket</div>
            
            <h3>📤 Message Format (Client → Server)</h3>
            <div class="code">{
  "type": "process",
  "prompt": "your command here"
}

// Examples:
{"type": "process", "prompt": "use deepseek"}
{"type": "process", "prompt": "translate hello to French"}
{"type": "process", "prompt": "with openai explain AI"}</div>
            
            <h3>📥 Response Format (Server → Client)</h3>
            <div class="code">// Success response
{
  "type": "response",
  "response": "AI generated response"
}

// Error response
{
  "type": "error", 
  "error": "error message"
}</div>

            <div class="ws-container">
                <h4>🧪 WebSocket Testing</h4>
                <div class="ws-status disconnected" id="wsStatus">🔴 Disconnected</div>
                <div class="flex gap-10 mb-20">
                    <button class="test-button" onclick="connectWebSocket()">🔌 Connect</button>
                    <button class="test-button" onclick="disconnectWebSocket()">🔌 Disconnect</button>
                </div>
                
                <div class="flex gap-10 mb-20">
                    <input type="text" id="wsMessage" placeholder="Enter command (e.g., use deepseek)" style="flex: 1; padding: 10px; border: 2px solid #e9ecef; border-radius: 6px;">
                    <button class="test-button" onclick="sendWebSocketMessage()">📤 Send</button>
                </div>
                
                <h4>📨 WebSocket Messages:</h4>
                <div class="ws-messages" id="wsMessages">WebSocket messages will appear here...</div>
                
                <div class="mt-20">
                    <h4>🚀 Quick WebSocket Tests:</h4>
                    <button class="test-button provider-test" onclick="sendWSCommand('list providers')">📋 List Providers</button>
                    <button class="test-button provider-test" onclick="sendWSCommand('use auto')">🤖 Auto Mode</button>
                    <button class="test-button provider-test" onclick="sendWSCommand('current provider')">🎯 Current Provider</button>
                    <button class="test-button provider-test" onclick="sendWSCommand('translate hello to Spanish')">🌐 Translate</button>
                </div>
            </div>
        </div>
    </div>

    <script src="/static/docs.js"></script>
</body>
</html>
EOF

echo "📝 Creating web/static/docs.js..."
cat > "$PROJECT_ROOT/web/static/docs.js" << 'EOF'
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
EOF

echo "📝 Creating web/index.html..."
cat > "$PROJECT_ROOT/web/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NeuroGO Playground</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container">
        <!-- Header Section -->
        <div class="header">
            <h1>🧠 NeuroGO Playground</h1>
            <p>Universal AI Command Router - Switch between providers seamlessly</p>
            <div class="status-bar">
                <div class="status" id="status">
                    <span class="status-indicator" id="statusIndicator">●</span>
                    <span id="statusText">Connecting...</span>
                </div>
                <div class="current-provider" id="currentProvider">
                    <span>🤖 Provider: Loading...</span>
                </div>
            </div>
        </div>
        
        <!-- Navigation -->
        <div class="nav-section">
            <a href="/docs" class="nav-link">📚 API Documentation</a>
            <a href="/api/health" class="nav-link" target="_blank">🔍 Health Check</a>
            <a href="/api/routes" class="nav-link" target="_blank">🛣️ Routes</a>
        </div>

        <!-- Main Playground -->
        <div class="playground">
            <!-- Provider Management Section -->
            <div class="section provider-management">
                <h3>🔄 Provider Management</h3>
                <div class="provider-info">
                    <div class="provider-status" id="providerStatus">
                        <div class="loading-spinner">Loading providers...</div>
                    </div>
                    <div class="provider-actions">
                        <button class="action-btn" onclick="quickCommand('list providers')">📋 List Providers</button>
                        <button class="action-btn" onclick="quickCommand('current provider')">🎯 Current Provider</button>
                        <button class="action-btn" onclick="quickCommand('use auto')">🤖 Auto Mode</button>
                        <button class="action-btn" onclick="quickCommand('status')">📊 Status</button>
                    </div>
                </div>
            </div>

            <!-- Quick Provider Switch -->
            <div class="section provider-switch">
                <h3>⚡ Quick Provider Switch</h3>
                <div class="provider-buttons">
                    <button class="provider-btn deepseek" onclick="switchProvider('deepseek')" title="Best for reasoning and analysis">
                        <span class="provider-icon">🧠</span>
                        <span class="provider-name">DeepSeek</span>
                        <span class="provider-status" id="deepseek-status">●</span>
                    </button>
                    <button class="provider-btn openai" onclick="switchProvider('openai')" title="Best for general tasks">
                        <span class="provider-icon">🤖</span>
                        <span class="provider-name">OpenAI</span>
                        <span class="provider-status" id="openai-status">●</span>
                    </button>
                    <button class="provider-btn gemini" onclick="switchProvider('gemini')" title="Best for translation">
                        <span class="provider-icon">✨</span>
                        <span class="provider-name">Gemini</span>
                        <span class="provider-status" id="gemini-status">●</span>
                    </button>
                    <button class="provider-btn ollama" onclick="switchProvider('ollama')" title="Local AI - No API key needed">
                        <span class="provider-icon">🏠</span>
                        <span class="provider-name">Ollama</span>
                        <span class="provider-status" id="ollama-status">●</span>
                    </button>
                    <button class="provider-btn auto" onclick="switchProvider('auto')" title="Auto-select best provider">
                        <span class="provider-icon">🎯</span>
                        <span class="provider-name">Auto</span>
                        <span class="provider-status">●</span>
                    </button>
                </div>
            </div>

            <!-- Chat Interface -->
            <div class="section chat-section">
                <h3>💬 Chat Interface</h3>
                <div class="chat-container" id="chatContainer">
                    <div class="welcome-message">
                        <div class="welcome-content">
                            <h4>👋 Welcome to NeuroGO!</h4>
                            <p>Start by selecting a provider above or try one of the example commands below.</p>
                            <div class="quick-tips">
                                <div class="tip">
                                    <span class="tip-icon">💡</span>
                                    <span>Use <code>list providers</code> to see available AI providers</span>
                                </div>
                                <div class="tip">
                                    <span class="tip-icon">🔄</span>
                                    <span>Switch providers with <code>use [provider]</code> or click buttons above</span>
                                </div>
                                <div class="tip">
                                    <span class="tip-icon">🎯</span>
                                    <span>Try <code>with [provider] [command]</code> for one-time provider use</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="input-container">
                    <div class="input-wrapper">
                        <input type="text" id="promptInput" placeholder="Enter your command... (e.g., translate hello to Spanish)" />
                        <button class="send-button" id="sendButton">
                            <span id="sendIcon">➤</span>
                            <span id="loadingIcon" style="display: none;">⟳</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Examples Section -->
            <div class="section examples-section">
                <h3>📝 Example Commands</h3>
                
                <div class="example-category">
                    <h4>🔄 Provider Management</h4>
                    <div class="example-grid">
                        <div class="example" onclick="setPrompt('list providers')">
                            <span class="example-icon">📋</span>
                            <div class="example-content">
                                <span class="example-title">List Providers</span>
                                <span class="example-desc">Show all available AI providers</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('use deepseek')">
                            <span class="example-icon">🧠</span>
                            <div class="example-content">
                                <span class="example-title">Use DeepSeek</span>
                                <span class="example-desc">Switch to DeepSeek for reasoning</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('current provider')">
                            <span class="example-icon">🎯</span>
                            <div class="example-content">
                                <span class="example-title">Current Provider</span>
                                <span class="example-desc">Check active provider</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('use auto')">
                            <span class="example-icon">🤖</span>
                            <div class="example-content">
                                <span class="example-title">Auto Mode</span>
                                <span class="example-desc">Let system choose best provider</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="example-category">
                    <h4>🌟 Universal Commands</h4>
                    <div class="example-grid">
                        <div class="example" onclick="setPrompt('translate hello world to Spanish')">
                            <span class="example-icon">🌐</span>
                            <div class="example-content">
                                <span class="example-title">Translation</span>
                                <span class="example-desc">Translate text to any language</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('think about artificial intelligence')">
                            <span class="example-icon">🤔</span>
                            <div class="example-content">
                                <span class="example-title">Deep Thinking</span>
                                <span class="example-desc">Analytical reasoning</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('generate code for a REST API')">
                            <span class="example-icon">💻</span>
                            <div class="example-content">
                                <span class="example-title">Code Generation</span>
                                <span class="example-desc">Generate clean, documented code</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('summarize the benefits of renewable energy')">
                            <span class="example-icon">📝</span>
                            <div class="example-content">
                                <span class="example-title">Summarization</span>
                                <span class="example-desc">Concise content summaries</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="example-category">
                    <h4>🎯 Provider-Specific Commands</h4>
                    <div class="example-grid">
                        <div class="example" onclick="setPrompt('with deepseek explain quantum computing')">
                            <span class="example-icon">🧠</span>
                            <div class="example-content">
                                <span class="example-title">DeepSeek Analysis</span>
                                <span class="example-desc">Use DeepSeek for complex explanations</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('with openai write a poem about nature')">
                            <span class="example-icon">🤖</span>
                            <div class="example-content">
                                <span class="example-title">OpenAI Creative</span>
                                <span class="example-desc">Use OpenAI for creative writing</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('with gemini translate this to French')">
                            <span class="example-icon">✨</span>
                            <div class="example-content">
                                <span class="example-title">Gemini Translation</span>
                                <span class="example-desc">Use Gemini for translations</span>
                            </div>
                        </div>
                        <div class="example" onclick="setPrompt('with ollama chat how are you?')">
                            <span class="example-icon">🏠</span>
                            <div class="example-content">
                                <span class="example-title">Ollama Local</span>
                                <span class="example-desc">Use local Ollama for privacy</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="getting-started">
                    <h4>🚀 Getting Started</h4>
                    <div class="setup-info">
                        <div class="setup-option">
                            <span class="setup-icon">🏠</span>
                            <div class="setup-content">
                                <strong>Local Setup (No API Keys)</strong>
                                <p>Install <a href="https://ollama.ai" target="_blank">Ollama</a> locally and try the Ollama examples above</p>
                            </div>
                        </div>
                        <div class="setup-option">
                            <span class="setup-icon">☁️</span>
                            <div class="setup-content">
                                <strong>Cloud Setup (With API Keys)</strong>
                                <p>Add API keys to your .env file and use any provider</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="/static/app.js"></script>
</body>
</html>
EOF

echo "📝 Creating web/static/style.css..."
cat > "$PROJECT_ROOT/web/static/style.css" << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  color: #333;
  line-height: 1.6;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Header Styles */
.header {
  text-align: center;
  margin-bottom: 30px;
  color: white;
}

.header h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  font-weight: 700;
}

.header p {
  font-size: 1.1rem;
  opacity: 0.9;
  margin-bottom: 20px;
}

.status-bar {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 30px;
  flex-wrap: wrap;
}

.status {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
}

.current-provider {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
  font-weight: 600;
}

.status-indicator {
  font-size: 12px;
  animation: pulse 2s infinite;
}

.status-indicator.connected {
  color: #4ade80;
}

.status-indicator.disconnected {
  color: #f87171;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

/* Navigation Styles */
.nav-section {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.nav-link {
  display: inline-block;
  padding: 10px 20px;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  text-decoration: none;
  border-radius: 25px;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
  font-weight: 500;
}

.nav-link:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

/* Main Playground */
.playground {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* Section Styles */
.section {
  padding: 25px 30px;
  border-bottom: 1px solid #f0f0f0;
}

.section:last-child {
  border-bottom: none;
}

.section h3 {
  margin-bottom: 20px;
  color: #333;
  font-size: 1.3rem;
  font-weight: 600;
}

/* Provider Management Section */
.provider-management {
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 100%);
}

.provider-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.provider-status {
  flex: 1;
  min-width: 200px;
}

.provider-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 8px 16px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: #0056b3;
  transform: translateY(-1px);
}

/* Provider Switch Section */
.provider-switch {
  background: #f8f9fa;
}

.provider-buttons {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 15px;
}

.provider-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 15px;
  background: white;
  border: 2px solid #e9ecef;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.provider-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.provider-btn.active {
  border-color: #007bff;
  background: #f0f8ff;
}

.provider-btn.deepseek:hover {
  border-color: #8e44ad;
}
.provider-btn.openai:hover {
  border-color: #2ecc71;
}
.provider-btn.gemini:hover {
  border-color: #f39c12;
}
.provider-btn.ollama:hover {
  border-color: #e74c3c;
}
.provider-btn.auto:hover {
  border-color: #3498db;
}

.provider-icon {
  font-size: 2rem;
  margin-bottom: 8px;
}

.provider-name {
  font-weight: 600;
  color: #333;
  margin-bottom: 5px;
}

.provider-status {
  position: absolute;
  top: 10px;
  right: 10px;
  font-size: 12px;
}

.provider-status.available {
  color: #28a745;
}
.provider-status.unavailable {
  color: #dc3545;
}

/* Chat Section */
.chat-section {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chat-container {
  flex: 1;
  max-height: 400px;
  overflow-y: auto;
  margin-bottom: 20px;
  padding: 20px;
  background: #fafafa;
  border-radius: 10px;
}

.welcome-message {
  text-align: center;
  padding: 30px 20px;
}

.welcome-content h4 {
  color: #333;
  margin-bottom: 15px;
  font-size: 1.4rem;
}

.welcome-content p {
  color: #666;
  margin-bottom: 25px;
  font-size: 1.1rem;
}

.quick-tips {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: 600px;
  margin: 0 auto;
}

.tip {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  text-align: left;
}

.tip-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.tip code {
  background: #f1f3f4;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: "Monaco", "Menlo", monospace;
  font-size: 0.9em;
}

/* Message Styles */
.message {
  margin-bottom: 20px;
  animation: fadeIn 0.3s ease-in;
}

.message.user {
  text-align: right;
}

.message.assistant {
  text-align: left;
}

.message-content {
  display: inline-block;
  max-width: 80%;
  padding: 15px 20px;
  border-radius: 20px;
  word-wrap: break-word;
}

.message.user .message-content {
  background: #007bff;
  color: white;
  border-bottom-right-radius: 5px;
}

.message.assistant .message-content {
  background: #f1f3f4;
  color: #333;
  border-bottom-left-radius: 5px;
}

.message-content pre {
  white-space: pre-wrap;
  font-family: "Monaco", "Menlo", "Ubuntu Mono", monospace;
  font-size: 0.9em;
  background: rgba(0, 0, 0, 0.05);
  padding: 10px;
  border-radius: 8px;
  margin: 10px 0;
  overflow-x: auto;
}

/* Input Container */
.input-container {
  padding: 20px 0;
}

.input-wrapper {
  display: flex;
  gap: 10px;
  align-items: center;
}

#promptInput {
  flex: 1;
  padding: 15px 20px;
  border: 2px solid #e1e5e9;
  border-radius: 25px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.2s ease;
}

#promptInput:focus {
  border-color: #007bff;
}

.send-button {
  background: #007bff;
  color: white;
  border: none;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.send-button:hover {
  background: #0056b3;
  transform: scale(1.05);
}

.send-button:disabled {
  background: #ccc;
  cursor: not-allowed;
  transform: none;
}

#loadingIcon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* Examples Section */
.examples-section {
  background: #f8f9fa;
}

.example-category {
  margin-bottom: 30px;
}

.example-category h4 {
  margin-bottom: 15px;
  color: #555;
  font-size: 1.1rem;
  font-weight: 600;
}

.example-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 15px;
}

.example {
  display: flex;
  align-items: center;
  gap: 15px;
  background: white;
  padding: 18px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.example:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #007bff;
}

.example-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.example-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.example-title {
  font-weight: 600;
  color: #333;
  font-size: 0.95rem;
}

.example-desc {
  color: #666;
  font-size: 0.85rem;
}

/* Getting Started Section */
.getting-started {
  margin-top: 30px;
  padding-top: 25px;
  border-top: 1px solid #e9ecef;
}

.getting-started h4 {
  margin-bottom: 20px;
  color: #333;
  font-size: 1.2rem;
}

.setup-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.setup-option {
  display: flex;
  gap: 15px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  border-left: 4px solid #007bff;
}

.setup-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.setup-content strong {
  display: block;
  margin-bottom: 8px;
  color: #333;
}

.setup-content p {
  color: #666;
  font-size: 0.9rem;
}

.setup-content a {
  color: #007bff;
  text-decoration: none;
  font-weight: 500;
}

.setup-content a:hover {
  text-decoration: underline;
}

/* Loading Spinner */
.loading-spinner {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #666;
}

.loading-spinner::before {
  content: "";
  width: 16px;
  height: 16px;
  border: 2px solid #f3f3f3;
  border-top: 2px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Responsive Design */
@media (max-width: 768px) {
  .container {
    padding: 10px;
  }

  .header h1 {
    font-size: 2rem;
  }

  .status-bar {
    flex-direction: column;
    gap: 15px;
  }

  .provider-info {
    flex-direction: column;
    align-items: stretch;
  }

  .provider-buttons {
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  }

  .example-grid {
    grid-template-columns: 1fr;
  }

  .message-content {
    max-width: 90%;
  }

  .setup-info {
    grid-template-columns: 1fr;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
EOF

echo "📝 Creating web/static/app.js..."
cat > "$PROJECT_ROOT/web/static/app.js" << 'EOF'
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
EOF

echo ""
echo "✅ Web files created successfully!"
echo ""
echo "📂 Created files:"
echo "  ✅ web/docs.html"
echo "  ✅ web/index.html"
echo "  ✅ web/static/app.js"
echo "  ✅ web/static/style.css"
echo "  ✅ web/static/docs.js"
echo ""
echo "🔧 Next steps:"
echo "1. Restart your NeuroGO server"
echo "2. Visit http://localhost:8080 for the playground"
echo "3. Visit http://localhost:8080/docs for API documentation"
echo ""
echo "🎉 Setup complete!"
EOF

chmod +x "$PROJECT_ROOT/scripts/setup-web-files.sh"

echo "📝 Creating Windows version of the setup script..."
cat > "$PROJECT_ROOT/scripts/setup-web-files.bat" << 'EOF'
@echo off
echo 🌐 Setting up NeuroGO web files...

set PROJECT_ROOT=%cd%
echo 📂 Project root: %PROJECT_ROOT%

REM Create necessary directories
if not exist "web" mkdir web
if not exist "web\static" mkdir web\static

echo ✅ Directories created

echo 📝 Creating web files...

REM Create a simple index.html for Windows
echo ^<!DOCTYPE html^> > web\index.html
echo ^<html^>^<head^>^<title^>NeuroGO^</title^>^</head^> >> web\index.html
echo ^<body^>^<h1^>NeuroGO Playground^</h1^>^<p^>Web files created successfully!^</p^>^</body^>^</html^> >> web\index.html

echo ✅ Basic web files created
echo 🔧 For full functionality, run the Linux setup script or manually copy the files
echo 🎉 Setup complete!
pause
EOF

Now let's update the main server file to better handle the file paths:

```typescriptreact file="cmd/server/main.go"
[v0-no-op-code-block-prefix]package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
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
	webFiles := []string{"web/docs.html", "web/index.html", "web/static/app.js", "web/static/style.css"}
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
			Model: getModelForProvider(provider),
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
			Model: getModelForProvider(provider),
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
			Model: getModelForProvider(provider),
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
			Model: getModelForProvider(provider),
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
			Model: getModelForProvider(provider),
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
			Model: getModelForProvider(provider),
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
	// Get the current working directory for debugging
	if cwd, err := os.Getwd(); err == nil {
		log.Printf("🔍 Current working directory: %s", cwd)
	}

	// Serve static files with multiple path attempts
	staticPaths := []string{"./web/static/", "./static/", "web/static/"}
	var staticDir string
	
	for _, path := range staticPaths {
		if _, err := os.Stat(path); err == nil {
			staticDir = path
			log.Printf("✅ Found static directory: %s", path)
			break
		}
	}
	
	if staticDir == "" {
		log.Println("⚠️  No static directory found, using default")
		staticDir = "./web/static/"
	}

	r.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir(staticDir))))

	// API Documentation endpoint with multiple path attempts
	r.HandleFunc("/docs", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		
		docsPaths := []string{
			"web/docs.html",
			"./web/docs.html",
			"docs.html",
		}
		
		for _, docsPath := range docsPaths {
			if _, err := os.Stat(docsPath); err == nil {
				log.Printf("✅ Serving docs from: %s", docsPath)
				http.ServeFile(w, r, docsPath)
				return
			}
		}
		
		log.Println("⚠️  docs.html file not found, serving embedded fallback")
		fmt.Fprint(w, getEmbeddedDocsHTML())
	})

	// Serve the playground UI with multiple path attempts
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		indexPaths := []string{
			"web/index.html",
			"./web/index.html", 
			"index.html",
		}
		
		for _, indexPath := range indexPaths {
			if _, err := os.Stat(indexPath); err == nil {
				log.Printf("✅ Serving index from: %s", indexPath)
				http.ServeFile(w, r, indexPath)
				return
			}
		}
		
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
