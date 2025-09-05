"use client"

import { Card, CardContent } from "@/components/ui/card"
import { Wallet, Users, ArrowUpRight, Eye, EyeOff } from "lucide-react"
import { useState } from "react"

interface StatsOverviewProps {
  totalSaved: number
  activeVaults: number
  monthlyGrowth: number
  currency: string
}

export function StatsOverview({ totalSaved, activeVaults, monthlyGrowth, currency }: StatsOverviewProps) {
  const [showAmounts, setShowAmounts] = useState(false)

  const toggleAmountVisibility = () => {
    setShowAmounts(!showAmounts)
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
      <Card>
        <CardContent className="p-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center">
              <Wallet className="w-4 h-4 text-primary" />
            </div>
            <div className="flex-1">
              <p className="text-xs text-muted-foreground">Total Saved</p>
              <div className="flex items-center gap-2">
                <p
                  className="text-xl font-bold cursor-pointer hover:text-primary transition-colors"
                  onClick={toggleAmountVisibility}
                >
                  {showAmounts ? `${currency} ${totalSaved.toLocaleString()}` : "••••••"}
                </p>
                <button
                  onClick={toggleAmountVisibility}
                  className="text-muted-foreground hover:text-foreground transition-colors"
                >
                  {showAmounts ? <EyeOff className="w-3 h-3" /> : <Eye className="w-3 h-3" />}
                </button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-accent/10 rounded-lg flex items-center justify-center">
              <Users className="w-4 h-4 text-accent" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Active Vaults</p>
              <p className="text-xl font-bold">{activeVaults}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-chart-2/10 rounded-lg flex items-center justify-center">
              <ArrowUpRight className="w-4 h-4 text-chart-2" />
            </div>
            <div className="flex-1">
              <p className="text-xs text-muted-foreground">This Month</p>
              <div className="flex items-center gap-2">
                <p
                  className="text-xl font-bold cursor-pointer hover:text-primary transition-colors"
                  onClick={toggleAmountVisibility}
                >
                  {showAmounts ? `+${currency} ${monthlyGrowth}` : "+••••"}
                </p>
                <button
                  onClick={toggleAmountVisibility}
                  className="text-muted-foreground hover:text-foreground transition-colors"
                >
                  {showAmounts ? <EyeOff className="w-3 h-3" /> : <Eye className="w-3 h-3" />}
                </button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
