import { useAccount, useBalance } from 'wagmi'
export default function FaucetBalance() {
  const { address } = useAccount()
  const { data, isLoading } = useBalance({
    address,
    //chainId: baseSepolia.id,
    token:"0x036CbD53842c5426634e7929541eC2318f3dCF7e"

  })
console.log("USDC:",Number(data?.formatted))
  if (isLoading) return <p>Loading...</p>
  return <p>Balance: {data?.formatted} {data?.symbol}</p>
}
