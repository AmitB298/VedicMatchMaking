import { useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import KundliCard from '../components/KundliCard';
import { getUserKundli } from '../services/api';

export default function KundliDetailPage() {
  const { userId } = useParams();
  const [kundli, setKundli] = useState(null);

  useEffect(() => {
    getUserKundli(userId).then(setKundli);
  }, [userId]);

  return (
    <div>
      <h1>User Kundli Details</h1>
      {kundli ? <KundliCard data={kundli} /> : <p>Loading...</p>}
    </div>
  );
}
