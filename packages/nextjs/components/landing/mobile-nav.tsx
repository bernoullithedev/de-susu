"use client"
import {
    MobileNav,
    NavbarLogo,
    MobileNavHeader,
    MobileNavToggle,
    MobileNavMenu,
  } from "@/components/ui/resizable-navbar";
import BaseAccountConnectButton from "./loginButton";
import { useState } from "react";

type Props ={
    navItems: {
        name: string;
        link: string;
    }[]
}
export default function MobileNavigation({navItems}:Props) {
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <MobileNav>
    <MobileNavHeader>
      <NavbarLogo />
      <MobileNavToggle
        isOpen={isMobileMenuOpen}
        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
      />
    </MobileNavHeader>

    <MobileNavMenu
      isOpen={isMobileMenuOpen}
      onClose={() => setIsMobileMenuOpen(false)}
    >
      {navItems.map((item, idx) => (
        <a
          key={`mobile-link-${idx}`}
          href={item.link}
          onClick={() => setIsMobileMenuOpen(false)}
          className="relative text-neutral-600 dark:text-neutral-300"
        >
          <span className="block">{item.name}</span>
        </a>
      ))}
      <div className="flex w-full flex-col gap-4">
        <div className="w-full">
          <BaseAccountConnectButton />
        </div>
      </div>
    </MobileNavMenu>
  </MobileNav>
  )
}
