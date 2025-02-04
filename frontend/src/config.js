// Create this new file to handle runtime configuration
const getBackendUrl = () => {
    // Check for runtime configuration first
    const runtimeConfig = window.__RUNTIME_CONFIG__ || {};
    
    // Try to get the URL in this order:
    // 1. Runtime config
    // 2. Environment variable
    // 3. Default localhost
    let url = runtimeConfig.BACKEND_URL || 
              process.env.REACT_APP_BACKEND_SERVER || 
              'http://localhost:8080';
    
    // Remove any trailing slashes
    url = url.replace(/\/+$/, '');
    
    // For debugging
    console.log('Backend URL:', url);
    
    return url;
};

export const config = {
    backendUrl: getBackendUrl()
}; 