import axios from "axios";
import { RegisterData, LoginData } from "../types/Auth";
const API_URL = "/api";
export async function register(data: RegisterData) {
  return axios.post(`${API_URL}/register`, data);
}
export async function login(data: LoginData) {
  return axios.post(`${API_URL}/login`, data);
}