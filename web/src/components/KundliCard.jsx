export default function KundliCard({ data }) {
  return (
    <div className='kundli-card'>
      <h2>{data.name}'s Kundli</h2>
      <p>DOB: {data.dob}</p>
      <p>Place: {data.place}</p>
      <pre>{JSON.stringify(data.details, null, 2)}</pre>
    </div>
  );
}
