import { config } from '../config';

// Use config.backendUrl instead of process.env.REACT_APP_BACKEND_SERVER
const API_URL = config.backendUrl;

// Example API call
export const register = async (userData) => {
    const url = `${config.backendUrl}/api/auth/register`;
    console.log('Sending request to:', url); // For debugging
    
    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(userData),
            credentials: 'include', // Include cookies if needed
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('Registration error:', error);
        throw error;
    }
}; 