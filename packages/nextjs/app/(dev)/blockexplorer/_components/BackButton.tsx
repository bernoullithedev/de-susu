"use client";

import { useRouter } from "next/navigation";

export const BackButton = () => {
  const router = useRouter();
  return (
    <button className="inline-flex items-center px-3 py-1 text-sm font-medium bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors" onClick={() => router.back()}>
      Back
    </button>
  );
};
