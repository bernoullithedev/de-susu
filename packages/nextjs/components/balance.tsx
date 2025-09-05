import { useAccount, useBalance } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'

export default function FaucetBalance() {
  const { address } = useAccount()
  const { data, isLoading } = useBalance({
    address,
    chainId: baseSepolia.id,
  })

  if (isLoading) return <p>Loading...</p>
  return <p>Balance: {data?.formatted} {data?.symbol}</p>
}
