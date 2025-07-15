import { BrowserRouter, Routes, Route } from "react-router-dom";
import KundliMatchReport from "@/pages/KundliMatchReport";
ReactDOM.createRoot(document.getElementById("root")!).render(
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<KundliMatchReport />} />
    </Routes>
  </BrowserRouter>
);