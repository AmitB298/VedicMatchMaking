import axios from 'axios';

export async function registerOrLogin(userData) {
    return axios.post('/api/auth/google', userData);
}
