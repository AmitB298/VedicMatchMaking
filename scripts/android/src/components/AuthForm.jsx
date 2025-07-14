import React from 'react';
import { GoogleAuthProvider, getAuth, signInWithPopup } from 'firebase/auth';
import { app } from '../firebase';
import { useAuth } from '../context/AuthContext';

export default function AuthForm() {
    const { setUser } = useAuth();
    const handleGoogleLogin = async () => {
        const auth = getAuth(app);
        const provider = new GoogleAuthProvider();
        try {
            const result = await signInWithPopup(auth, provider);
            setUser(result.user);
        } catch (error) {
            console.error(error);
        }
    };
    return (
        <div>
            <button onClick={handleGoogleLogin}>Sign in with Google</button>
        </div>
    );
}
