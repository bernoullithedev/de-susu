export type mockVaultsType= {
    id: string;
    name: string;
    ensName?: string;
    type: "personal" |"group";
    targetAmount: number;
    depositedAmount: number;
    lockPeriod: string;
    maturityDate: string;
    currency: string;
    members?:{
        name:string;
        avatar:string;
    }[];
}

export const mockVaults:mockVaultsType[] = [
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