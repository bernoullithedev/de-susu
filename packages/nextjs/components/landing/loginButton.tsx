"use client"

import { useState } from "react";
import { useAccount, useDisconnect } from "wagmi";
import { useBaseAccount } from "~~/hooks/scaffold-eth";
import { NavbarButton } from "../ui/resizable-navbar";

function BaseAccountConnectButton() {
    const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();
  const { hasBaseAccount, isOnBaseNetwork } = useBaseAccount();
  const [isConnecting, setIsConnecting] = useState(false);
  console.log(isOnBaseNetwork)
  const handleConnect = async () => {
     // We import like this (dynamically) to avoid SSR issues.
  
    const baseAccountSDK = await import("@base-org/account");
      const sdk = baseAccountSDK.createBaseAccountSDK(
        {
          appName: 'De-SUSU',
          appLogoUrl: 'https://base.org/logo.png',
        }
      )
    setIsConnecting(true);
    try {
            await sdk.getProvider().request({ method: 'wallet_connect' });        
            setIsConnecting(false)
    } catch (error) {
      console.error("Failed to connect to Base Account:", error);
    } finally {
      setIsConnecting(false);
    }
  };

  const handleDisconnect = () => {
    disconnect();
  };

  if (!isConnected) {
    return (
      <NavbarButton
        onClick={handleConnect}
        variant="primary"
        className="bg-blue-600 hover:bg-blue-700 text-white"
        disabled={isConnecting}
      >
        {isConnecting ? "Connecting..." : "Connect Base Account"}
      </NavbarButton>
    );}

    return (
        <div className="flex items-center gap-3">
          <NavbarButton
            onClick={handleDisconnect}
            variant="primary"
            className="bg-green-600 hover:bg-green-700 text-white"
          >
            {address?.slice(0, 6)}...{address?.slice(-4)}
            {hasBaseAccount && (
              <span className="ml-2 text-xs bg-blue-500 px-2 py-1 rounded">
                Base
              </span>
            )}
          </NavbarButton>
        </div>
      );
}

export default BaseAccountConnectButton