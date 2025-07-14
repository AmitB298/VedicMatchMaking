param(
    [string]$ProjectPath
)

Write-Host "------------------------------------------------------------"
Write-Host "✅ Starting Web Registration Screen Setup"
Write-Host "------------------------------------------------------------"

# 1️⃣ Make sure path exists
if (-not (Test-Path $ProjectPath)) {
    Write-Error "❌ ERROR: Provided path does not exist: $ProjectPath"
    exit 1
}

# 2️⃣ Create folders
$authPath = Join-Path $ProjectPath "src\components\Auth"
$servicesPath = Join-Path $ProjectPath "src\services"
$typesPath = Join-Path $ProjectPath "src\types"

New-Item -ItemType Directory -Force -Path $authPath | Out-Null
New-Item -ItemType Directory -Force -Path $servicesPath | Out-Null
New-Item -ItemType Directory -Force -Path $typesPath | Out-Null

# 3️⃣ Write types/Auth.ts
Set-Content -Path (Join-Path $typesPath "Auth.ts") -Value @"
export interface RegisterPayload {
  email?: string;
  phone?: string;
  password: string;
  confirmPassword: string;
}
"@

Write-Host "✅ types/Auth.ts written."

# 4️⃣ Write services/authService.ts
Set-Content -Path (Join-Path $servicesPath "authService.ts") -Value @"
import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

export const registerWithEmail = async (data: { email: string, password: string }) => {
  return axios.post(\`\${API_BASE}/register\`, data);
};

export const registerWithPhone = async (data: { phone: string, password: string }) => {
  return axios.post(\`\${API_BASE}/register-phone\`, data);
};

export const socialRegister = async (provider: 'google' | 'facebook', token: string) => {
  return axios.post(\`\${API_BASE}/social-register\`, { provider, token });
};
"@

Write-Host "✅ services/authService.ts written."

# 5️⃣ Write components/Auth/SocialLoginButtons.tsx
Set-Content -Path (Join-Path $authPath "SocialLoginButtons.tsx") -Value @"
import React from 'react';

interface Props {
  onGoogle: () => void;
  onFacebook: () => void;
}

export const SocialLoginButtons: React.FC<Props> = ({ onGoogle, onFacebook }) => (
  <div className=\"flex flex-col gap-3 mt-4\">
    <button
      onClick={onGoogle}
      className=\"w-full bg-red-600 text-white py-2 rounded hover:bg-red-700\"
    >
      Continue with Google
    </button>
    <button
      onClick={onFacebook}
      className=\"w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700\"
    >
      Continue with Facebook
    </button>
  </div>
);
"@

Write-Host "✅ components/Auth/SocialLoginButtons.tsx written."

# 6️⃣ Write components/Auth/RegisterScreen.tsx
Set-Content -Path (Join-Path $authPath "RegisterScreen.tsx") -Value @"
import React, { useState } from 'react';
import { SocialLoginButtons } from './SocialLoginButtons';
import { registerWithEmail, registerWithPhone } from '../../services/authService';
import { RegisterPayload } from '../../types/Auth';
import { useNavigate } from 'react-router-dom';

export const RegisterScreen: React.FC = () => {
  const [form, setForm] = useState<RegisterPayload>({ password: '', confirmPassword: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validate = () => {
    if (!form.email && !form.phone) return 'Either email or phone is required.';
    if (form.password.length < 6) return 'Password must be at least 6 characters.';
    if (form.password !== form.confirmPassword) return 'Passwords do not match.';
    return null;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    const validationError = validate();
    if (validationError) {
      setError(validationError);
      return;
    }

    setLoading(true);
    try {
      if (form.email) {
        await registerWithEmail({ email: form.email, password: form.password });
      } else {
        await registerWithPhone({ phone: form.phone, password: form.password });
      }
      navigate('/login');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Registration failed.');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = () => {
    console.log('Google Sign-In triggered');
  };

  const handleFacebookSignIn = () => {
    console.log('Facebook Sign-In triggered');
  };

  return (
    <div className=\"max-w-md mx-auto p-6 bg-white shadow-lg rounded-lg mt-10\">
      <h2 className=\"text-2xl font-bold mb-4 text-center\">Register</h2>
      <form onSubmit={handleSubmit} className=\"flex flex-col gap-4\">
        <input
          type=\"email\"
          name=\"email\"
          placeholder=\"Email (optional)\"
          value={form.email || ''}
          onChange={handleChange}
          className=\"border rounded p-2\"
        />
        <input
          type=\"tel\"
          name=\"phone\"
          placeholder=\"Phone (optional)\"
          value={form.phone || ''}
          onChange={handleChange}
          className=\"border rounded p-2\"
        />
        <input
          type=\"password\"
          name=\"password\"
          placeholder=\"Password\"
          value={form.password}
          onChange={handleChange}
          className=\"border rounded p-2\"
          required
        />
        <input
          type=\"password\"
          name=\"confirmPassword\"
          placeholder=\"Confirm Password\"
          value={form.confirmPassword}
          onChange={handleChange}
          className=\"border rounded p-2\"
          required
        />
        {error && <p className=\"text-red-600 text-sm\">{error}</p>}
        <button
          type=\"submit\"
          disabled={loading}
          className=\"bg-green-600 text-white py-2 rounded hover:bg-green-700\"
        >
          {loading ? 'Registering...' : 'Register'}
        </button>
      </form>
      <SocialLoginButtons onGoogle={handleGoogleSignIn} onFacebook={handleFacebookSignIn} />
    </div>
  );
};
"@

Write-Host "✅ components/Auth/RegisterScreen.tsx written."
Write-Host "------------------------------------------------------------"
Write-Host "✅ Web Registration Screen setup complete!"
Write-Host "------------------------------------------------------------"
Write-Host "🎯 NEXT STEPS:"
Write-Host "   1. Open your project in VS Code."
Write-Host "   2. Wire up routing for /register to RegisterScreen."
Write-Host "   3. Add real Google & Facebook SDK login flows."
Write-Host "------------------------------------------------------------"
