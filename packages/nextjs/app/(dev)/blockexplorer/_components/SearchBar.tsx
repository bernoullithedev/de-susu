"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { isAddress, isHex } from "viem";
import { hardhat } from "viem/chains";
import { usePublicClient } from "wagmi";

export const SearchBar = () => {
  const [searchInput, setSearchInput] = useState("");
  const router = useRouter();

  const client = usePublicClient({ chainId: hardhat.id });

  const handleSearch = async (event: React.FormEvent) => {
    event.preventDefault();
    if (isHex(searchInput)) {
      try {
        const tx = await client?.getTransaction({ hash: searchInput });
        if (tx) {
          router.push(`/blockexplorer/transaction/${searchInput}`);
          return;
        }
      } catch (error) {
        console.error("Failed to fetch transaction:", error);
      }
    }

    if (isAddress(searchInput)) {
      router.push(`/blockexplorer/address/${searchInput}`);
      return;
    }
  };

  return (
    <form onSubmit={handleSearch} className="flex items-center justify-end mb-5 space-x-3 mx-5">
      <input
        className="border-blue-500 bg-white text-gray-900 placeholder:text-gray-500 p-2 mr-2 w-full md:w-1/2 lg:w-1/3 rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        type="text"
        value={searchInput}
        placeholder="Search by hash or address"
        onChange={e => setSearchInput(e.target.value)}
      />
      <button className="inline-flex items-center px-3 py-1 text-sm font-medium bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors" type="submit">
        Search
      </button>
    </form>
  );
};
