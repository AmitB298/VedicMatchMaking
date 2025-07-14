param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Starting Web Auth Screens Setup"
Write-Host "------------------------------------------------------------"

# Validate Project Path
if (!(Test-Path $ProjectPath)) {
    Write-Error "❌ ERROR: Provided path does not exist: $ProjectPath"
    exit 1
}

# Create folders
$folders = @(
    "$ProjectPath/src/types",
    "$ProjectPath/src/services",
    "$ProjectPath/src/components/Auth"
)

foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory | Out-Null
        Write-Host "✅ Created folder: $folder"
    }
}

# 1️⃣ types/Auth.ts
@'
export interface RegisterData {
  email?: string;
  phone?: string;
  password?: string;
}

export interface LoginData {
  email?: string;
  phone?: string;
  password?: string;
}
'@ | Set-Content "$ProjectPath/src/types/Auth.ts"
Write-Host "✅ types/Auth.ts written."

# 2️⃣ services/authService.ts
@'
import axios from "axios";
import { RegisterData, LoginData } from "../types/Auth";

const API_URL = "/api";

export async function register(data: RegisterData) {
  return axios.post(`${API_URL}/register`, data);
}

export async function login(data: LoginData) {
  return axios.post(`${API_URL}/login`, data);
}
'@ | Set-Content "$ProjectPath/src/services/authService.ts"
Write-Host "✅ services/authService.ts written."

# 3️⃣ components/Auth/SocialLoginButtons.tsx
@'
import React from "react";

export default function SocialLoginButtons({ onGoogle, onFacebook }: any) {
  return (
    <div className="flex flex-col gap-4">
      <button
        onClick={onGoogle}
        className="bg-red-500 text-white px-4 py-2 rounded-md"
      >
        Continue with Google
      </button>
      <button
        onClick={onFacebook}
        className="bg-blue-600 text-white px-4 py-2 rounded-md"
      >
        Continue with Facebook
      </button>
    </div>
  );
}
'@ | Set-Content "$ProjectPath/src/components/Auth/SocialLoginButtons.tsx"
Write-Host "✅ components/Auth/SocialLoginButtons.tsx written."

# 4️⃣ components/Auth/RegisterScreen.tsx
@'
import React, { useState } from "react";
import { register } from "../../services/authService";
import SocialLoginButtons from "./SocialLoginButtons";

export default function RegisterScreen() {
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    try {
      await register({ email, phone, password });
      alert("Registration successful!");
    } catch (err) {
      console.error(err);
      alert("Error registering.");
    }
  };

  return (
    <div className="max-w-md mx-auto p-6">
      <h2 className="text-2xl font-bold mb-4">Register</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <input
          type="text"
          placeholder="Email"
          className="border px-3 py-2 w-full rounded"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <input
          type="text"
          placeholder="Phone"
          className="border px-3 py-2 w-full rounded"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          className="border px-3 py-2 w-full rounded"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button
          type="submit"
          className="bg-green-600 text-white px-4 py-2 rounded-md"
        >
          Register
        </button>
      </form>
      <div className="mt-6">
        <SocialLoginButtons
          onGoogle={() => alert("Google Sign-In TBD")}
          onFacebook={() => alert("Facebook Sign-In TBD")}
        />
      </div>
    </div>
  );
}
'@ | Set-Content "$ProjectPath/src/components/Auth/RegisterScreen.tsx"
Write-Host "✅ components/Auth/RegisterScreen.tsx written."

# 5️⃣ components/Auth/LoginScreen.tsx
@'
import React, { useState } from "react";
import { login } from "../../services/authService";
import SocialLoginButtons from "./SocialLoginButtons";

export default function LoginScreen() {
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    try {
      await login({ email, phone, password });
      alert("Login successful!");
    } catch (err) {
      console.error(err);
      alert("Error logging in.");
    }
  };

  return (
    <div className="max-w-md mx-auto p-6">
      <h2 className="text-2xl font-bold mb-4">Login</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <input
          type="text"
          placeholder="Email"
          className="border px-3 py-2 w-full rounded"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <input
          type="text"
          placeholder="Phone"
          className="border px-3 py-2 w-full rounded"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          className="border px-3 py-2 w-full rounded"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button
          type="submit"
          className="bg-green-600 text-white px-4 py-2 rounded-md"
        >
          Login
        </button>
      </form>
      <div className="mt-6">
        <SocialLoginButtons
          onGoogle={() => alert("Google Sign-In TBD")}
          onFacebook={() => alert("Facebook Sign-In TBD")}
        />
      </div>
    </div>
  );
}
'@ | Set-Content "$ProjectPath/src/components/Auth/LoginScreen.tsx"
Write-Host "✅ components/Auth/LoginScreen.tsx written."

Write-Host "------------------------------------------------------------"
Write-Host "✅ Web Auth Screens setup complete!"
Write-Host "------------------------------------------------------------"
Write-Host "🎯 NEXT STEPS:"
Write-Host "   1. Add /register and /login routes in your App.tsx."
Write-Host "   2. Install react-google-login and react-facebook-login."
Write-Host "   3. Wire up real social login SDK callbacks."
Write-Host "------------------------------------------------------------"
