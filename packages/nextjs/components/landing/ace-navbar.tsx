import {
  Navbar,
  NavBody,
  NavItems,
  NavbarLogo,
} from "@/components/ui/resizable-navbar";
// import BaseAccountConnectButton from "./loginButton";
import MobileNavigation from "./mobile-nav";
import { WalletComponents } from "../dashboard/profile";


export function NavbarDemo() {
  const navItems = [
    {
      name: "Dashboard",
      link: "/dashboard",
    },
    {
      name: "Block Eplorer",
      link: "/blockexplorer",
    },
    {
      name: "Debug",
      link: "/debug",
    },
  ];
  return (
    <div className="relative w-full">
      <Navbar>
        {/* Desktop Navigation */}
        <NavBody>
          <NavbarLogo />
          <NavItems items={navItems} />
          <div className="flex items-center gap-4">
            {/* <BaseAccountConnectButton /> */}
            <WalletComponents />
          </div>
        </NavBody>

        {/* Mobile Navigation */}
       <MobileNavigation navItems={navItems}/>
      </Navbar>

      {/* Navbar */}
    </div>
  );
}

