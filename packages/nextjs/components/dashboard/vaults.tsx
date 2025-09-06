"use client"
import { Coins, Plus } from 'lucide-react'
import React, { useState } from 'react'
import { mockVaultsType } from '~~/lib/mockdata'
import { Button } from '../ui/button'
import { motion } from "framer-motion"
import { VaultCard } from '../dashboardOld/vault-card'
import { CreateVaultDialog } from './create-vault-dialog'
type Props={
userVaults:mockVaultsType[]
}

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

function Vaults({userVaults}:Props) {
    const [showCreateVault, setShowCreateVault] = useState(false)

    if(userVaults.length ==0){
        return(
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
            <CreateVaultDialog open={showCreateVault} onOpenChange={setShowCreateVault} />
          </motion.div>
        )
    }
  return (
    <motion.div variants={containerVariants} initial="hidden" animate="visible" className="space-y-8">
    {/* Vault Cards */}
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-balance">Your Susu Vaults</h2>
      </div>

      <motion.div
        variants={containerVariants}
        className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-6"
      >
        {userVaults.map((vault) => (
          <VaultCard key={vault.id} vault={vault} variants={cardVariants} />
        ))}
      </motion.div>
    </div>
  </motion.div>
  )
}

export default Vaults