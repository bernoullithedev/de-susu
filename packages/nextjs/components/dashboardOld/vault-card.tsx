"use client"

import { motion } from "framer-motion"
import { Progress } from "@/components/ui/progress"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Users, Wallet, Calendar, Eye, ArrowUpRight, EyeOff } from "lucide-react"
import { useState } from "react"

interface VaultMember {
  name: string
  avatar?: string
}

interface Vault {
  id: string
  name: string
  ensName?: string
  type: "personal" | "group"
  targetAmount: number
  depositedAmount: number
  lockPeriod: string
  maturityDate: string
  currency: string
  members?: VaultMember[]
}

interface VaultCardProps {
  vault: Vault
  variants?: any
}

export function VaultCard({ vault, variants }: VaultCardProps) {
  const progressPercentage = Math.round((vault.depositedAmount / vault.targetAmount) * 100)
  const displayName = vault.ensName || vault.name
  const [showGroupName, setShowGroupName] = useState(false)
  const [showAmounts, setShowAmounts] = useState(false)

  const handleNameClick = () => {
    if (vault.type === "group" && vault.ensName) {
      setShowGroupName(!showGroupName)
    }
  }

  const toggleAmountVisibility = () => {
    setShowAmounts(!showAmounts)
  }

  return (
    <motion.div variants={variants}>
      <div className="relative mx-auto w-full max-w-sm rounded-lg border border-dashed border-zinc-300 px-4 sm:px-6 md:px-8 dark:border-zinc-800 hover:shadow-lg transition-shadow">
        <div className="absolute top-4 left-0 -z-0 h-px w-full bg-zinc-400 sm:top-6 md:top-8 dark:bg-zinc-700" />
        <div className="absolute bottom-4 left-0 z-0 h-px w-full bg-zinc-400 sm:bottom-6 md:bottom-8 dark:bg-zinc-700" />
        <div className="relative w-full border-x border-zinc-400 dark:border-zinc-700">
          <div className="absolute z-0 grid h-full w-full items-center">
            <section className="absolute z-0 grid h-full w-full grid-cols-2 place-content-between">
              <div className="bg-primary my-4 size-1 -translate-x-[2.5px] rounded-full outline outline-8 outline-gray-50 sm:my-6 md:my-8 dark:outline-gray-950" />
              <div className="bg-primary my-4 size-1 translate-x-[2.5px] place-self-end rounded-full outline outline-8 outline-gray-50 sm:my-6 md:my-8 dark:outline-gray-950" />
              <div className="bg-primary my-4 size-1 -translate-x-[2.5px] rounded-full outline outline-8 outline-gray-50 sm:my-6 md:my-8 dark:outline-gray-950" />
              <div className="bg-primary my-4 size-1 translate-x-[2.5px] place-self-end rounded-full outline outline-8 outline-gray-50 sm:my-6 md:my-8 dark:outline-gray-950" />
            </section>
          </div>
          <div className="relative z-20 mx-auto py-8 px-4">
            <div className="space-y-3">
              <div className="flex items-start justify-between">
                <div>
                  <h3
                    className={`text-lg font-bold text-gray-900 dark:text-gray-100 text-balance ${
                      vault.type === "group" && vault.ensName
                        ? "cursor-pointer hover:text-primary transition-colors"
                        : ""
                    }`}
                    onClick={handleNameClick}
                  >
                    {vault.type === "group" && vault.ensName && showGroupName ? vault.name : displayName}
                  </h3>
                  <div className="flex items-center gap-2 mt-1">
                    {vault.type === "group" ? (
                      <Users className="w-3 h-3 text-muted-foreground" />
                    ) : (
                      <Wallet className="w-3 h-3 text-muted-foreground" />
                    )}
                    <span className="text-xs text-muted-foreground capitalize">{vault.type}</span>
                  </div>
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between items-center text-sm">
                  <div className="flex items-center gap-2">
                    <span
                      className="font-medium text-gray-700 dark:text-gray-300 cursor-pointer hover:text-primary transition-colors"
                      onClick={toggleAmountVisibility}
                    >
                      {showAmounts
                        ? `${vault.currency} ${vault.depositedAmount.toLocaleString()}/${vault.targetAmount.toLocaleString()}`
                        : "••••/••••"}
                    </span>
                    <button
                      onClick={toggleAmountVisibility}
                      className="text-muted-foreground hover:text-foreground transition-colors"
                    >
                      {showAmounts ? <EyeOff className="w-3 h-3" /> : <Eye className="w-3 h-3" />}
                    </button>
                  </div>
                  <span className="text-muted-foreground font-medium">{progressPercentage}%</span>
                </div>
                <Progress value={progressPercentage} className="h-1.5" />
              </div>

              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <Calendar className="w-3 h-3" />
                <span>Matures: {vault.maturityDate}</span>
              </div>

              {vault.type === "group" && vault.members && (
                <div className="flex items-center gap-2">
                  <div className="flex -space-x-1">
                    {vault.members.slice(0, 3).map((member, index) => (
                      <Avatar key={index} className="w-5 h-5 border border-background">
                        <AvatarImage src={member.avatar || "/placeholder.svg"} />
                        <AvatarFallback className="text-[10px]">
                          {member.name
                            .split(" ")
                            .map((n) => n[0])
                            .join("")}
                        </AvatarFallback>
                      </Avatar>
                    ))}
                  </div>
                  <span className="text-xs text-muted-foreground">{vault.members.length} members</span>
                </div>
              )}

              <div className="flex gap-4 pt-1">
                <button className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground transition-colors underline-offset-4 hover:underline">
                  <Eye className="w-3 h-3" />
                  View Details
                </button>
                <button className="flex items-center gap-1 text-xs text-primary hover:text-primary/80 transition-colors font-medium underline-offset-4 hover:underline">
                  <ArrowUpRight className="w-3 h-3" />
                  Deposit
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  )
}
