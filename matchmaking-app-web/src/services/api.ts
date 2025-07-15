import axios from "axios";
const API = axios.create({
  baseURL: "http://localhost:3000", // for local web dev
  headers: {
    "Content-Type": "application/json",
  },
});
export default API;