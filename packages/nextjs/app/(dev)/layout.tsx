"use client";
import React from 'react'
import { useInitializeNativeCurrencyPrice } from "~~/hooks/scaffold-eth";

import { Footer } from "~~/components/Footer";
import { Header } from "~~/components/Header";
import { Toaster } from "~~/components/ui/sonner";
export default function layout({
    children,
  }: Readonly<{
    children: React.ReactNode;
  }>) {
    useInitializeNativeCurrencyPrice();
  return (
    <>
      <div className={`flex flex-col min-h-screen `}>
        <Header />
        <main className="relative flex flex-col flex-1">{children}</main>
        <Footer />
      </div>
      <Toaster />
    </>
  )
}

