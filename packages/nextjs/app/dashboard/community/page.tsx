"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { ArrowLeft, Search, Heart, Users, CheckCircle, ExternalLink, Calendar, MapPin } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Accordion } from "@/components/ui/accordion"
import Link from "next/link"

interface CauseVault {
  id: string
  title: string
  description: string
  organizer: string
  verified: boolean
  targetAmount: number
  raisedAmount: number
  currency: string
  category: string
  location: string
  endDate: string
  image: string
  supporters: number
  story: string
  updates: Array<{
    date: string
    title: string
    content: string
  }>
}

const mockCauses: CauseVault[] = [
  {
    id: "1",
    title: "Kidney Dialysis Machines for Tamale Hospital",
    description: "Help us provide life-saving dialysis equipment for patients in Northern Ghana",
    organizer: "Ghana Health Service",
    verified: true,
    targetAmount: 5,
    raisedAmount: 2.5,
    currency: "ETH",
    category: "Healthcare",
    location: "Tamale, Ghana",
    endDate: "2025-03-15",
    image: "/thoughtful-african-man.png",
    supporters: 127,
    story:
      "The Tamale Teaching Hospital serves over 2 million people in Northern Ghana, but currently has only one functioning dialysis machine for hundreds of patients with kidney disease. Many patients travel over 300km for treatment, and some cannot afford the journey. With your support, we can install 3 new dialysis machines and train local technicians, saving countless lives in our community.",
    updates: [
      {
        date: "2025-01-15",
        title: "Equipment Supplier Confirmed",
        content: "We've partnered with Fresenius Medical Care to provide state-of-the-art dialysis machines.",
      },
    ],
  },
  {
    id: "2",
    title: "Clean Water Wells for Rural Communities",
    description: "Bringing safe drinking water to 10 villages in the Upper East Region",
    organizer: "Water for Life Ghana",
    verified: true,
    targetAmount: 8,
    raisedAmount: 3.2,
    currency: "ETH",
    category: "Environment",
    location: "Upper East Region, Ghana",
    endDate: "2025-04-20",
    image: "/serene-african-woman.png",
    supporters: 89,
    story:
      "Over 15,000 people in remote villages lack access to clean water, forcing families to walk hours daily to collect water from contaminated sources. This project will drill 10 boreholes with solar-powered pumps, providing clean water within walking distance of every household.",
    updates: [
      {
        date: "2025-01-10",
        title: "Site Surveys Completed",
        content: "Our team has completed geological surveys for all 10 proposed well locations.",
      },
    ],
  },
  {
    id: "3",
    title: "Solar Power for Rural Schools",
    description: "Installing solar panels in 20 schools to enable digital learning",
    organizer: "Ghana Education Service",
    verified: true,
    targetAmount: 12,
    raisedAmount: 7.8,
    currency: "ETH",
    category: "Education",
    location: "Volta Region, Ghana",
    endDate: "2025-05-30",
    image: "/thoughtful-african-man.png",
    supporters: 203,
    story:
      "Many rural schools in Ghana lack electricity, limiting students' access to computers and digital learning resources. This initiative will install solar power systems in 20 schools, benefiting over 5,000 students and enabling them to compete in our digital world.",
    updates: [
      {
        date: "2025-01-12",
        title: "First 5 Schools Connected",
        content:
          "We've successfully installed solar systems in the first batch of schools. Students are already using computers for the first time!",
      },
    ],
  },
]

export default function CommunityPage() {
  const [selectedCause, setSelectedCause] = useState<CauseVault | null>(null)
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("all")

  const totalDonated = mockCauses.reduce((sum, cause) => sum + cause.raisedAmount, 0)
  const totalSupporters = mockCauses.reduce((sum, cause) => sum + cause.supporters, 0)

  const filteredCauses = mockCauses.filter((cause) => {
    const matchesSearch =
      cause.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      cause.description.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesCategory = selectedCategory === "all" || cause.category.toLowerCase() === selectedCategory
    return matchesSearch && matchesCategory
  })

  return (
    <div className="min-h-screen bg-background">
      {/* Navigation */}
      <div className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-40">
        <div className="container mx-auto px-4 py-4">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <Link href="/dashboard">
              <Button variant="ghost" size="sm" className="gap-2">
                <ArrowLeft className="w-4 h-4" />
                Back to Dashboard
              </Button>
            </Link>
            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 w-full sm:w-auto">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  placeholder="Search causes..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10 w-full sm:w-64"
                />
              </div>
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="px-3 py-2 border rounded-md text-sm bg-background w-full sm:w-auto"
              >
                <option value="all">All Categories</option>
                <option value="healthcare">Healthcare</option>
                <option value="education">Education</option>
                <option value="environment">Environment</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Hero Section */}
      <section className="bg-gradient-to-b from-primary/5 to-background py-12 sm:py-16">
        <div className="container mx-auto px-4 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="max-w-4xl mx-auto space-y-4 sm:space-y-6"
          >
            <h1 className="text-3xl sm:text-4xl md:text-6xl font-bold text-balance">Join Ghana's Regenerative Susu</h1>
            <p className="text-lg sm:text-xl text-muted-foreground text-balance">Donate to Causes That Matter</p>
            <p className="text-base sm:text-lg text-muted-foreground max-w-2xl mx-auto text-balance">
              Trusted organizations create vaults for causes like healthcare, education, and environment. Donate via
              stream or one-time, track impact on-chain.
            </p>
            <div className="flex items-center justify-center gap-6 sm:gap-8 pt-4">
              <div className="text-center">
                <div className="text-xl sm:text-2xl font-bold text-primary">{totalDonated.toFixed(1)} ETH</div>
                <div className="text-xs sm:text-sm text-muted-foreground">Total Donated</div>
              </div>
              <div className="text-center">
                <div className="text-xl sm:text-2xl font-bold text-primary">{totalSupporters}</div>
                <div className="text-xs sm:text-sm text-muted-foreground">Lives Supported</div>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Featured Causes */}
      <section className="py-12 sm:py-16">
        <div className="container mx-auto px-4">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6 sm:mb-8">
            <h2 className="text-2xl sm:text-3xl font-bold">Featured Causes</h2>
            <Badge variant="secondary" className="gap-1">
              <Heart className="w-3 h-3" />
              Trending
            </Badge>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
            {filteredCauses.map((cause, index) => (
              <motion.div
                key={cause.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
              >
                <Card
                  className="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer"
                  onClick={() => setSelectedCause(cause)}
                >
                  <div className="aspect-video relative overflow-hidden">
                    <img
                      src={cause.image || "/placeholder.svg"}
                      alt={cause.title}
                      className="w-full h-full object-cover"
                    />
                    <Badge className="absolute top-2 sm:top-3 left-2 sm:left-3 text-xs">{cause.category}</Badge>
                  </div>
                  <CardContent className="p-4 sm:p-6 space-y-3 sm:space-y-4">
                    <div>
                      <h3 className="font-bold text-base sm:text-lg text-balance mb-2">{cause.title}</h3>
                      <p className="text-xs sm:text-sm text-muted-foreground text-balance">{cause.description}</p>
                    </div>

                    <div className="flex items-center gap-2">
                      <Avatar className="w-5 h-5 sm:w-6 sm:h-6">
                        <AvatarFallback className="text-xs">{cause.organizer[0]}</AvatarFallback>
                      </Avatar>
                      <span className="text-xs sm:text-sm text-muted-foreground truncate">{cause.organizer}</span>
                      {cause.verified && <CheckCircle className="w-3 h-3 sm:w-4 sm:h-4 text-green-500 flex-shrink-0" />}
                    </div>

                    <div className="space-y-2">
                      <div className="flex justify-between text-xs sm:text-sm">
                        <span className="font-medium">
                          {cause.raisedAmount}/{cause.targetAmount} {cause.currency}
                        </span>
                        <span className="text-muted-foreground">
                          {Math.round((cause.raisedAmount / cause.targetAmount) * 100)}%
                        </span>
                      </div>
                      <Progress value={(cause.raisedAmount / cause.targetAmount) * 100} className="h-2" />
                    </div>

                    <div className="flex items-center justify-between pt-2">
                      <div className="flex items-center gap-3 sm:gap-4 text-xs text-muted-foreground">
                        <span className="flex items-center gap-1">
                          <Users className="w-3 h-3" />
                          {cause.supporters}
                        </span>
                        <span className="flex items-center gap-1 truncate">
                          <MapPin className="w-3 h-3 flex-shrink-0" />
                          <span className="truncate">{cause.location}</span>
                        </span>
                      </div>
                      <Button size="sm" className="gap-1 text-xs">
                        <Heart className="w-3 h-3" />
                        <span className="hidden sm:inline">Donate</span>
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Governance Section */}
      <section className="py-12 sm:py-16 bg-muted/30">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center space-y-6 sm:space-y-8">
            <h2 className="text-2xl sm:text-3xl font-bold">How Public Vaults Work</h2>
            <p className="text-base sm:text-lg text-muted-foreground text-balance">
              Verified by Community, Secured on Base Blockchain
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 sm:gap-6 mt-8 sm:mt-12">
              <div className="text-center space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto">
                  <CheckCircle className="w-5 h-5 sm:w-6 sm:h-6 text-primary" />
                </div>
                <h3 className="font-semibold text-sm sm:text-base">Verification</h3>
                <p className="text-xs sm:text-sm text-muted-foreground">
                  Organizations submit proof and get community verification
                </p>
              </div>
              <div className="text-center space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto">
                  <Users className="w-5 h-5 sm:w-6 sm:h-6 text-primary" />
                </div>
                <h3 className="font-semibold text-sm sm:text-base">Transparency</h3>
                <p className="text-xs sm:text-sm text-muted-foreground">
                  All donations and fund usage tracked on-chain
                </p>
              </div>
              <div className="text-center space-y-3 sm:space-y-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto">
                  <Heart className="w-5 h-5 sm:w-6 sm:h-6 text-primary" />
                </div>
                <h3 className="font-semibold text-sm sm:text-base">Impact</h3>
                <p className="text-xs sm:text-sm text-muted-foreground">
                  Real-time updates on how your donations create change
                </p>
              </div>
            </div>

            <Accordion type="single" collapsible className="max-w-2xl mx-auto mt-8 sm:mt-12"></Accordion>
          </div>
        </div>
      </section>

      {/* Detailed Vault Modal */}
      <Dialog open={!!selectedCause} onOpenChange={() => setSelectedCause(null)}>
        <DialogContent className="max-w-[95vw] sm:max-w-4xl max-h-[95vh] sm:max-h-[90vh] overflow-y-auto m-2 sm:m-6">
          {selectedCause && (
            <>
              <DialogHeader className="pb-4">
                <DialogTitle className="text-xl sm:text-2xl text-balance pr-8">{selectedCause.title}</DialogTitle>
              </DialogHeader>

              <Tabs defaultValue="story" className="w-full">
                <TabsList className="grid w-full grid-cols-3 mb-4">
                  <TabsTrigger value="story" className="text-xs sm:text-sm">
                    Story
                  </TabsTrigger>
                  <TabsTrigger value="progress" className="text-xs sm:text-sm">
                    Progress
                  </TabsTrigger>
                  <TabsTrigger value="updates" className="text-xs sm:text-sm">
                    Updates
                  </TabsTrigger>
                </TabsList>

                <TabsContent value="story" className="space-y-4 sm:space-y-6">
                  <div className="aspect-video relative overflow-hidden rounded-lg">
                    <img
                      src={selectedCause.image || "/placeholder.svg"}
                      alt={selectedCause.title}
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div className="space-y-3 sm:space-y-4">
                    <div className="flex items-center gap-3">
                      <Avatar className="w-8 h-8 sm:w-10 sm:h-10">
                        <AvatarFallback className="text-sm">{selectedCause.organizer[0]}</AvatarFallback>
                      </Avatar>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-2">
                          <span className="font-medium text-sm sm:text-base truncate">{selectedCause.organizer}</span>
                          {selectedCause.verified && <CheckCircle className="w-4 h-4 text-green-500 flex-shrink-0" />}
                        </div>
                        <div className="text-xs sm:text-sm text-muted-foreground flex flex-col sm:flex-row sm:items-center gap-1 sm:gap-4">
                          <span className="flex items-center gap-1">
                            <MapPin className="w-3 h-3" />
                            {selectedCause.location}
                          </span>
                          <span className="flex items-center gap-1">
                            <Calendar className="w-3 h-3" />
                            Ends {selectedCause.endDate}
                          </span>
                        </div>
                      </div>
                    </div>
                    <p className="text-sm sm:text-base text-muted-foreground leading-relaxed">{selectedCause.story}</p>
                  </div>
                </TabsContent>

                <TabsContent value="progress" className="space-y-4 sm:space-y-6">
                  <div className="space-y-3 sm:space-y-4">
                    <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2">
                      <span className="text-xl sm:text-2xl font-bold">
                        {selectedCause.raisedAmount}/{selectedCause.targetAmount} {selectedCause.currency}
                      </span>
                      <span className="text-base sm:text-lg text-muted-foreground">
                        {Math.round((selectedCause.raisedAmount / selectedCause.targetAmount) * 100)}% Complete
                      </span>
                    </div>
                    <Progress value={(selectedCause.raisedAmount / selectedCause.targetAmount) * 100} className="h-3" />
                    <div className="flex items-center justify-between text-xs sm:text-sm text-muted-foreground">
                      <span>{selectedCause.supporters} supporters</span>
                      <span>Ends {selectedCause.endDate}</span>
                    </div>
                  </div>
                  <div className="flex flex-col sm:flex-row gap-3 sm:gap-4">
                    <Button className="flex-1 gap-2">
                      <Heart className="w-4 h-4" />
                      Donate Now
                    </Button>
                    <Button variant="outline" className="gap-2 bg-transparent">
                      <ExternalLink className="w-4 h-4" />
                      Share
                    </Button>
                  </div>
                </TabsContent>

                <TabsContent value="updates" className="space-y-3 sm:space-y-4">
                  {selectedCause.updates.map((update, index) => (
                    <Card key={index}>
                      <CardContent className="p-3 sm:p-4">
                        <div className="flex items-start gap-3">
                          <div className="w-2 h-2 bg-primary rounded-full mt-2 flex-shrink-0" />
                          <div className="space-y-2 min-w-0 flex-1">
                            <div className="flex flex-col sm:flex-row sm:items-center gap-1 sm:gap-2">
                              <h4 className="font-medium text-sm sm:text-base">{update.title}</h4>
                              <span className="text-xs text-muted-foreground">{update.date}</span>
                            </div>
                            <p className="text-xs sm:text-sm text-muted-foreground">{update.content}</p>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </TabsContent>
              </Tabs>
            </>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
