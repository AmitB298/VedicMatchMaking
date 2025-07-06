import React, { useState } from 'react';
import axios from 'axios';

export default function RegisterScreen() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [displayName, setDisplayName] = useState('');
    const [photoURL, setPhotoURL] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await axios.post('/api/v1/register', { email, password, displayName, photoURL });
            localStorage.setItem('token', res.data.token);
            alert('Registration successful!');
        } catch (err) {
            alert('Registration failed!');
        }
    };

    return (
        <div className="max-w-md mx-auto mt-10 p-6 rounded-lg shadow-lg bg-white">
            <h1 className="text-2xl mb-4">Register</h1>
            <form onSubmit={handleSubmit}>
                <input className="border p-2 mb-4 w-full" placeholder="Display Name" value={displayName} onChange={e => setDisplayName(e.target.value)} />
                <input className="border p-2 mb-4 w-full" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
                <input type="password" className="border p-2 mb-4 w-full" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} />
                <input className="border p-2 mb-4 w-full" placeholder="Photo URL" value={photoURL} onChange={e => setPhotoURL(e.target.value)} />
                <button className="bg-green-600 text-white rounded p-2 w-full">Register</button>
            </form>
        </div>
    );
}
