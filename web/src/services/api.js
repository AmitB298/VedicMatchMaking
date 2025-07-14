const API_URL = import.meta.env.VITE_BACKEND_URL;

export async function getUserKundli(userId) {
  const response = await fetch(${API_URL}/api/kundli/);
  if (!response.ok) throw new Error('Failed to fetch');
  return response.json();
}
