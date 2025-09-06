"use client"
import { pay } from '@base-org/account'
import { useAccount } from 'wagmi' // Optional - just for display
import { Button } from '../ui/button'

export function BasePayButton() {
  const { address } = useAccount() // Optional

  const handlePayment = async () => {
    try {
      const payment = await pay({
        amount: '21.00',
        to: address||"",
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