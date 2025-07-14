import React from "react";

export default function SocialLoginButtons({ onGoogle, onFacebook }: any) {
  return (
    <div className="flex flex-col gap-4">
      <button
        onClick={onGoogle}
        className="bg-red-500 text-white px-4 py-2 rounded-md"
      >
        Continue with Google
      </button>
      <button
        onClick={onFacebook}
        className="bg-blue-600 text-white px-4 py-2 rounded-md"
      >
        Continue with Facebook
      </button>
    </div>
  );
}
