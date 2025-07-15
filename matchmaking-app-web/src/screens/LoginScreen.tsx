import React, { useState } from 'react';
import axios from 'axios';
export default function LoginScreen() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await axios.post('/api/v1/login', { email, password });
            localStorage.setItem('token', res.data.token);
            alert('Login successful!');
        } catch (err) {
            alert('Login failed!');
        }
    };
    return (
        <div className="max-w-md mx-auto mt-10 p-6 rounded-lg shadow-lg bg-white">
            <h1 className="text-2xl mb-4">Login</h1>
            <form onSubmit={handleSubmit}>
                <input className="border p-2 mb-4 w-full" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
                <input type="password" className="border p-2 mb-4 w-full" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} />
                <button className="bg-blue-600 text-white rounded p-2 w-full">Login</button>
            </form>
        </div>
    );
}