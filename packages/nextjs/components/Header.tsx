"use client";

import React, { useRef } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { hardhat } from "viem/chains";
import { Bars3Icon, BugAntIcon } from "@heroicons/react/24/outline";
import { FaucetButton, RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { useOutsideClick, useTargetNetwork } from "~~/hooks/scaffold-eth";

type HeaderMenuLink = {
  label: string;
  href: string;
  icon?: React.ReactNode;
};

export const menuLinks: HeaderMenuLink[] = [
  {
    label: "Home",
    href: "/",
  },
  {
    label: "Debug Contracts",
    href: "/debug",
    icon: <BugAntIcon className="h-4 w-4" />,
  },
];

export const HeaderMenuLinks = () => {
  const pathname = usePathname();

  return (
    <>
      {menuLinks.map(({ label, href, icon }) => {
        const isActive = pathname === href;
        return (
          <li key={href}>
            <Link
              href={href}
              passHref
              className={`${
                isActive ? "bg-blue-100 shadow-md" : ""
              } hover:bg-blue-100 hover:shadow-md focus:bg-blue-100 active:text-gray-900 py-1.5 px-3 text-sm rounded-full gap-2 flex items-center`}
            >
              {icon}
              <span>{label}</span>
            </Link>
          </li>
        );
      })}
    </>
  );
};

/**
 * Site header
 */
export const Header = () => {
  const { targetNetwork } = useTargetNetwork();
  const isLocalNetwork = targetNetwork.id === hardhat.id;

  const burgerMenuRef = useRef<HTMLDetailsElement>(null);
  useOutsideClick(burgerMenuRef, () => {
    burgerMenuRef?.current?.removeAttribute("open");
  });

  return (
    <div className="sticky lg:static top-0 flex items-center justify-between  min-h-0 shrink-0 z-20 shadow-md px-0 sm:px-2">
      <div className="flex items-center w-auto lg:w-1/2">
        <details className="relative ml-1 lg:hidden" ref={burgerMenuRef}>
          <summary className="flex items-center justify-center p-2 rounded-lg hover:bg-gray-100 dark:bg-gray-600 transition-colors cursor-pointer">
            <Bars3Icon className="h-1/2" />
          </summary>
          <ul
            className="absolute left-0 top-full mt-2 p-2 shadow-lg  rounded-lg w-52 flex flex-col gap-1 z-50"
            onClick={() => {
              burgerMenuRef?.current?.removeAttribute("open");
            }}
          >
            <HeaderMenuLinks />
          </ul>
        </details>
        <Link href="/" passHref className="hidden lg:flex items-center gap-2 ml-4 mr-6 shrink-0">
          <div className="flex relative w-10 h-10">
            <Image alt="SE2 logo" className="cursor-pointer" fill src="/logo.svg" />
          </div>
          <div className="flex flex-col">
            <span className="font-bold leading-tight">Scaffold-ETH</span>
            <span className="text-xs">Ethereum dev stack</span>
          </div>
        </Link>
        <ul className="hidden lg:flex lg:flex-nowrap px-1 gap-2">
          <HeaderMenuLinks />
        </ul>
      </div>
      <div className="flex items-center grow justify-end mr-4">
        <RainbowKitCustomConnectButton />
        {isLocalNetwork && <FaucetButton />}
      </div>
    </div>
  );
};
