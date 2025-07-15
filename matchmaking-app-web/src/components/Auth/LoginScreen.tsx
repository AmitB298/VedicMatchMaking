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