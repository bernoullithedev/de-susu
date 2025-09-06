"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Coins, Wallet, CheckCircle, Loader2 } from "lucide-react"
import { toast } from "sonner"

interface OnboardingDialogProps {
  open: boolean
  onComplete: () => void
}

export function OnboardingDialog({ open, onComplete }: OnboardingDialogProps) {
  const [step, setStep] = useState("claim-eth")
  const [basename, setBasename] = useState("")
  const [isCheckingName, setIsCheckingName] = useState(false)
  const [isRegistering, setIsRegistering] = useState(false)
  const [nameAvailable, setNameAvailable] = useState<boolean | null>(null)

  const handleClaimEth = () => {
    toast.success("Test ETH Claimed!",{
      description: "You've received 0.1 ETH for gas fees on Base testnet.",
    })
    setStep("basename")
  }

  const checkBasename = async () => {
    if (!basename.trim()) return

    setIsCheckingName(true)
    await new Promise((resolve) => setTimeout(resolve, 1500))

    const available = !basename.toLowerCase().startsWith("test")
    setNameAvailable(available)
    setIsCheckingName(false)
  }

  const registerBasename = async () => {
    setIsRegistering(true)
    await new Promise((resolve) => setTimeout(resolve, 2000))

    toast.info("Basename Registered!",{
      description: `${basename}.base.eth is now yours!`,
    })
    setIsRegistering(false)
    onComplete()
  }

  return (
    <Dialog open={open} onOpenChange={() => {}}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="text-center">
            {step === "claim-eth" ? "Welcome to Susu Vault!" : "Choose Your Basename"}
          </DialogTitle>
        </DialogHeader>

        {step === "claim-eth" ? (
          <div className="space-y-6 text-center">
            <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto">
              <Coins className="w-8 h-8 text-primary" />
            </div>
            <div className="space-y-2">
              <p className="text-pretty">To get started, you'll need some test ETH for gas fees on Base network.</p>
              <p className="text-sm text-muted-foreground">This is completely free and only for testing purposes.</p>
              <div className="bg-amber-50 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-800 rounded-lg p-3 mt-4">
                <p className="text-xs text-amber-800 dark:text-amber-200 font-medium">
                  ⚠️ Demo Mode: This is for demonstration purposes only. No real funds are involved.
                </p>
              </div>
            </div>
            <Button onClick={handleClaimEth} className="w-full gap-2">
              <Wallet className="w-4 h-4" />
              Claim Free Test ETH
            </Button>
          </div>
        ) : (
          <div className="space-y-6">
            <div className="space-y-2 text-center">
              <p className="text-pretty">Choose a human-readable name for your wallet address.</p>
              <p className="text-sm text-muted-foreground">This will be your identity on Base network.</p>
            </div>

            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="basename">Your Basename</Label>
                <div className="flex gap-2">
                  <div className="relative flex-1">
                    <Input
                      id="basename"
                      value={basename}
                      onChange={(e) => {
                        setBasename(e.target.value)
                        setNameAvailable(null)
                      }}
                      placeholder="kwame"
                      className="pr-20"
                    />
                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                      .base.eth
                    </span>
                  </div>
                  <Button onClick={checkBasename} disabled={!basename.trim() || isCheckingName} variant="outline">
                    {isCheckingName ? <Loader2 className="w-4 h-4 animate-spin" /> : "Check"}
                  </Button>
                </div>
              </div>

              {nameAvailable === true && (
                <div className="flex items-center gap-2 text-sm text-green-600">
                  <CheckCircle className="w-4 h-4" />
                  <span>{basename}.base.eth is available!</span>
                </div>
              )}

              {nameAvailable === false && (
                <div className="text-sm text-destructive">{basename}.base.eth is already taken. Try another name.</div>
              )}

              {nameAvailable === true && (
                <Button onClick={registerBasename} disabled={isRegistering} className="w-full gap-2">
                  {isRegistering ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Registering...
                    </>
                  ) : (
                    <>
                      <CheckCircle className="w-4 h-4" />
                      Register {basename}.base.eth
                    </>
                  )}
                </Button>
              )}
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}
