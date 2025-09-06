"use client"
import { pay } from '@base-org/account'
import { useAccount } from 'wagmi' // Optional - just for display
import { Button } from '../ui/button'

export function BasePayButton() {
  const { address } = useAccount() // Optional

  const handlePayment = async () => {
    try {
      const payment = await pay({
        amount: '5',
        to: "0x8bE6E8961ea90db32Ad4515C9fCB212B18Bb4559",
        testnet: true
      })
      console.log('Payment sent:', payment.id)
    } catch (error) {
      console.error('Payment failed:', error)
    }
  }

  return (     
      <Button onClick={handlePayment}>
       Deposit Funds
      </Button>
  )
}