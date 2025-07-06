import React from "react";

interface ProgressBarProps {
  value: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({ value }) => {
  const width = Math.min(100, Math.max(0, value));

  return (
    <div className="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
      <div
        className="h-full bg-green-500 transition-all"
        style={{ width: `${value}%` }}
      />
    </div>
  );
};

export default ProgressBar;

