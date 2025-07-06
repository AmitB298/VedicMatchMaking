import React from "react";

interface ProfileCardProps {
  name1: string;
  name2: string;
  caste1: string;
  caste2: string;
}

const ProfileCard: React.FC<ProfileCardProps> = ({ name1, name2, caste1, caste2 }) => {
  return (
    <div className="bg-white rounded-lg shadow p-4 flex justify-between items-center">
      <div>
        <h3 className="text-lg font-semibold">{name1}</h3>
        <p className="text-gray-600">{caste1}</p>
      </div>
      <span className="text-2xl">❤️</span>
      <div>
        <h3 className="text-lg font-semibold">{name2}</h3>
        <p className="text-gray-600">{caste2}</p>
      </div>
    </div>
  );
};

export default ProfileCard;
