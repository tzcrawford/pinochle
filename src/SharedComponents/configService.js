// configService.js
export async function fetchConfig() {
  try {
    const response = await fetch('./config');

    if (!response.ok) {
      // If response status is not OK (e.g., 404 Not Found), throw an error
      throw new Error(`Failed to fetch config. Status: ${response.status}`);
    }

    const config = await response.json();
    return config;
  } catch (error) {
    console.error('Error fetching config:', error.message);
    throw error; // Rethrow the error for the caller to handle
  }
}
