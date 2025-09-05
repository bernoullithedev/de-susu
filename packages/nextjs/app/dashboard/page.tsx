"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Coins, Plus } from "lucide-react"
import { VaultCard } from "@/components/dashboard/vault-card"
import { StatsOverview } from "@/components/dashboard/stats-overview"
import { OnboardingDialog } from "@/components/dashboard/onboarding-dialog"
import { CreateVaultDialog } from "@/components/dashboard/create-vault-dialog"
import DotCard from "@/components/ui/dot-card"
import FaucetBalance from "~~/components/balance"

const mockVaults = [
  {
    id: "1",
    name: "Personal Emergency Fund",
    ensName: "emergency-fund.base.eth",
    type: "personal" as const,
    targetAmount: 5000,
    depositedAmount: 1250,
    lockPeriod: "6 months",
    maturityDate: "2025-08-30",
    currency: "GHC",
  },
  {
    id: "2",
    name: "Business Equipment Susu",
    type: "group" as const,
    targetAmount: 20000,
    depositedAmount: 8500,
    lockPeriod: "12 months",
    maturityDate: "2026-02-30",
    currency: "GHC",
    members: [
      { name: "Kwame A.", avatar: "/thoughtful-african-man.png" },
      { name: "Ama B.", avatar: "/serene-african-woman.png" },
      { name: "Kofi C.", avatar: "/thoughtful-african-man.png" },
      { name: "Akosua D.", avatar: "/serene-african-woman.png" },
    ],
  },
  {
    id: "3",
    name: "Community Development Fund",
    ensName: "community-dev.base.eth",
    type: "group" as const,
    targetAmount: 15000,
    depositedAmount: 3750,
    lockPeriod: "9 months",
    maturityDate: "2025-11-30",
    currency: "GHC",
    members: [
      { name: "Yaw E.", avatar: "/thoughtful-african-man.png" },
      { name: "Efua F.", avatar: "/serene-african-woman.png" },
      { name: "Kojo G.", avatar: "/thoughtful-african-man.png" },
    ],
  },
]

export default function DashboardPage() {
  const [vaults] = useState(mockVaults) // Change to [] to test empty state
  
  const [showOnboarding, setShowOnboarding] = useState(true)
  const [showCreateVault, setShowCreateVault] = useState(false)

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  }

  const cardVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5 },
    },
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-40">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <Coins className="w-5 h-5 text-primary-foreground" />
              </div>
              <h1 className="text-xl font-bold text-balance">Decentralized Susu Vault</h1>
            </div>
            <FaucetBalance />
            <div className="flex items-center gap-2">
              <div className="text-sm text-muted-foreground">kwame.base.eth</div>
              <Avatar className="w-8 h-8">
                <AvatarImage src="/thoughtful-african-man.png" />
                <AvatarFallback>KA</AvatarFallback>
              </Avatar>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8">
        {vaults.length > 0 ? (
          <motion.div variants={containerVariants} initial="hidden" animate="visible" className="space-y-8">
            {/* Stats Overview */}
            <StatsOverview totalSaved={13500} activeVaults={vaults.length} monthlyGrowth={850} currency="GHC" />

            {/* Vault Cards */}
            <div>
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-balance">Your Susu Vaults</h2>
                <Button onClick={() => setShowCreateVault(true)} className="gap-2">
                  <Plus className="w-4 h-4" />
                  Create Vault
                </Button>
              </div>

              <motion.div
                variants={containerVariants}
                className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-6"
              >
                {vaults.map((vault) => (
                  <VaultCard key={vault.id} vault={vault} variants={cardVariants} />
                ))}
              </motion.div>
            </div>

            <div className="mt-12">
              <h3 className="text-xl font-bold mb-4">Featured Card Design</h3>
              <DotCard />
            </div>
          </motion.div>
        ) : (
          /* Empty State */
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="flex flex-col items-center justify-center min-h-[60vh] text-center space-y-6"
          >
            <div className="w-24 h-24 bg-primary/10 rounded-full flex items-center justify-center">
              <Coins className="w-12 h-12 text-primary" />
            </div>
            <div className="space-y-2">
              <h2 className="text-2xl font-bold text-balance">You haven't started any susu yet!</h2>
              <p className="text-muted-foreground max-w-md text-pretty">
                Lock in your savings today and build wealth securely with our blockchain-powered susu system.
              </p>
            </div>
            <Button onClick={() => setShowCreateVault(true)} size="lg" className="gap-2">
              <Plus className="w-5 h-5" />
              Start Saving Now
            </Button>
          </motion.div>
        )}
      </main>

      {/* Dialogs */}
      <OnboardingDialog open={showOnboarding} onComplete={() => setShowOnboarding(false)} />
      <CreateVaultDialog open={showCreateVault} onOpenChange={setShowCreateVault} />
    </div>
  )
}
