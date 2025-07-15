import React from 'react';
export default function Card({ title, children }: { title?: string, children: React.ReactNode }) {
  return (
    <div className="max-w-lg rounded-xl border shadow-sm p-5 bg-white">
      {title && <h2 className="text-lg font-semibold mb-2">{title}</h2>}
      <div className="text-gray-800">{children}</div>
    </div>
  );
}