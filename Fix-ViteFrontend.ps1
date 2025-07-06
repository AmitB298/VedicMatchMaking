$webRoot = "E:\VedicMatchMaking\matchmaking-app-web"
$srcPath = "$webRoot\src"

if (-Not (Test-Path $srcPath)) {
    New-Item -ItemType Directory -Path $srcPath -Force
}

# index.html
@'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vedic Matchmaking</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
'@ | Set-Content -Encoding UTF8 -Path "$webRoot\index.html"

# vite.config.ts
@'
import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173
  }
})
'@ | Set-Content -Encoding UTF8 -Path "$webRoot\vite.config.ts"

# src/main.tsx
@'
import React from "react"
import ReactDOM from "react-dom/client"
import App from "./App"
import "./index.css"

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
'@ | Set-Content -Encoding UTF8 -Path "$srcPath\main.tsx"

# src/App.tsx
@'
function App() {
  return (
    <div style={{ padding: "2rem", fontSize: "1.5rem" }}>
      <h1>🕉 Vedic Matchmaking Web UI</h1>
      <p>This is the default landing page. Customize as needed.</p>
    </div>
  )
}

export default App
'@ | Set-Content -Encoding UTF8 -Path "$srcPath\App.tsx"

# src/index.css
@'
body {
  font-family: sans-serif;
  margin: 0;
  background-color: #f9f9f9;
}
'@ | Set-Content -Encoding UTF8 -Path "$srcPath\index.css"

Write-Host "✅ Vite web UI boilerplate recreated. Run this next:" -ForegroundColor Green
Write-Host "   cd $webRoot && npm install && npm run dev" -ForegroundColor Yellow
