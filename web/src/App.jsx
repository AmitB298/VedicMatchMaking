import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import KundliDetailPage from './pages/KundliDetailPage';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/kundli/:userId" element={<KundliDetailPage />} />
      </Routes>
    </Router>
  );
}
export default App;
