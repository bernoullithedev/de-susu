"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Plus } from "lucide-react"
import { toast } from "sonner"
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth"
import { parseEther } from "viem"

interface CreateVaultDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function CreateVaultDialog({ open, onOpenChange }: CreateVaultDialogProps) {
  const { writeContractAsync,isPending,error } = useScaffoldWriteContract({ contractName: "PersonalVaultFactory" });
  const [vaultType, setVaultType] = useState("personal")
  console.log("Hook state:", { writeContractAsync, isPending, error });
  async function handleCreateVault() {
    if (!writeContractAsync) {
      toast.error("Contract not ready. Please connect wallet and try again.");
      return;
    }
    try {
   const result =  await writeContractAsync({
        functionName: "createVault",
        args: [BigInt(60 * 60 * 24 * 1), "Bern Vault"], // 1d lock
        value: parseEther("0.01"),
      });

if(result){
  toast.success("Vault Created!",{  
        description: `Your ${vaultType} vault has been created successfully. With address: ${result}`,
  }
)
}else{
  toast.info(result)
}
   
     console.log("Result:",result)
      // onOpenChange(false)
    } catch (error) {
      toast.error("Failed to create Vault")
      console.log("Failed to create vault:",error)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Create New Susu Vault</DialogTitle>
        </DialogHeader>

        <Tabs value={vaultType} onValueChange={setVaultType} className="space-y-6">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="personal">Personal</TabsTrigger>
            <TabsTrigger value="group">Group</TabsTrigger>
          </TabsList>

          <TabsContent value="personal" className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="amount">Target Amount (GHC)</Label>
              <Input id="amount" placeholder="5000" type="number" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="period">Lock Period</Label>
              <Input id="period" placeholder="6 months" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="ens">ENS Name (Optional)</Label>
              <Input id="ens" placeholder="my-savings.eth" />
            </div>
          </TabsContent>

          <TabsContent value="group" className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="group-name">Group Name</Label>
              <Input id="group-name" placeholder="Business Equipment Fund" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="group-amount">Target Amount (GHC)</Label>
              <Input id="group-amount" placeholder="20000" type="number" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="max-members">Max Members</Label>
              <Input id="max-members" placeholder="5" type="number" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="contribution">Weekly Target (GHC)</Label>
              <Input id="contribution" placeholder="500" type="number" />
            </div>
          </TabsContent>

          <Button disabled={!writeContractAsync || isPending} onClick={handleCreateVault} className="w-full gap-2">
            <Plus className="w-4 h-4" />
            Create Vault
          </Button>
        </Tabs>
      </DialogContent>
    </Dialog>
  )
}
