import React from "react";
type ProgressBarProps = {
  value: number;
};
const ProgressBar: React.FC<ProgressBarProps> = ({ value }) => {
  return (
    <div className="w-full h-4 bg-gray-200 rounded overflow-hidden">
      <div
        className="h-full bg-green-500 transition-all"
        style={{ width: `${value}%` }}
      ></div>
    </div>
  );
};
export default ProgressBar;