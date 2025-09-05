import { useAccount, useChainId } from "wagmi";
import { useEffect, useState } from "react";

export const useBaseAccount = () => {
  const { address, isConnected } = useAccount();
  const chainId = useChainId();
  const [hasBaseAccount, setHasBaseAccount] = useState<boolean | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  // Check if the connected address has a Base Account
  useEffect(() => {
    const checkBaseAccount = async () => {
      if (!address || !isConnected) {
        setHasBaseAccount(null);
        return;
      }

      setIsLoading(true);
      try {
        // In a real implementation, you would check if the address has a deployed Base Account contract
        // For now, we'll assume if they're connected via Base Account wallet, they have one
        // You could also check the wallet connector type to determine if it's a Base Account
        
        // Example of how you might check for Base Account deployment:
        // const baseAccountFactory = getContract({
        //   address: BASE_ACCOUNT_FACTORY_ADDRESS,
        //   abi: BASE_ACCOUNT_FACTORY_ABI,
        //   publicClient,
        // });
        // const accountAddress = await baseAccountFactory.read.getAddress([address]);
        // setHasBaseAccount(accountAddress !== "0x0000000000000000000000000000000000000000");
        
        setHasBaseAccount(true);
      } catch (error) {
        console.error("Error checking Base Account:", error);
        setHasBaseAccount(false);
      } finally {
        setIsLoading(false);
      }
    };

    checkBaseAccount();
  }, [address, isConnected]);

  const isOnBaseNetwork = chainId === 8453; // Base mainnet chain ID

  return {
    address,
    isConnected,
    hasBaseAccount,
    isOnBaseNetwork,
    isLoading,
  };
};
