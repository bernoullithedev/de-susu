"use client"

import { useState } from "react"
import { CreateVaultDialog } from "../dashboardOld/create-vault-dialog"
import { Button } from "../ui/button"
import { Plus } from "lucide-react"

function CreateVault() {
    const [showCreateVault, setShowCreateVault] = useState(false)
  return (
    <div>
             <Button onClick={() => setShowCreateVault(true)} className="gap-2">
                  <Plus className="w-4 h-4" />
                  Create Vault
                </Button>
        <CreateVaultDialog open={showCreateVault} onOpenChange={setShowCreateVault} />
    </div>
  )
}

export default CreateVault