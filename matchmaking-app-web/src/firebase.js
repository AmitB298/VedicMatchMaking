// src/firebase.js
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getAnalytics } from 'firebase/analytics';

const firebaseConfig = {
  apiKey: "AIzaSyBzNhXIKlLY-XmTqwOAojjYhX_QoVaYRiM",
  authDomain: "vedicmatchmaking.firebaseapp.com",
  projectId: "vedicmatchmaking",
  storageBucket: "vedicmatchmaking.firebasestorage.app",
  messagingSenderId: "232675844747",
  appId: "1:232675844747:web:9a1ebd2a5ed021f1462a8e",
  measurementId: "G-LRXY8J502Q"
};


// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
const analytics = getAnalytics(app);

export { db, auth, analytics };



