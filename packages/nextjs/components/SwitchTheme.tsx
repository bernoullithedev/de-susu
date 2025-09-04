"use client";

import { useEffect, useState } from "react";
import { useTheme } from "next-themes";
import { MoonIcon, SunIcon } from "@heroicons/react/24/outline";

export const SwitchTheme = ({ className }: { className?: string }) => {
  const { setTheme, resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  const isDarkMode = resolvedTheme === "dark";

  const handleToggle = () => {
    if (isDarkMode) {
      setTheme("light");
      return;
    }
    setTheme("dark");
  };

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  return (
    <div className={`flex space-x-2 h-8 items-center justify-center text-sm ${className}`}>
      <input
        id="theme-toggle"
        type="checkbox"
        className="w-12 h-6 bg-gray-300 rounded-full appearance-none cursor-pointer checked:bg-blue-600 hover:bg-blue-500 transition-all duration-300 before:content-[''] before:w-4 before:h-4 before:bg-white before:rounded-full before:absolute before:top-1 before:left-1 before:transition-transform checked:before:translate-x-6 relative"
        onChange={handleToggle}
        checked={isDarkMode}
      />
      <label htmlFor="theme-toggle" className={`cursor-pointer transition-transform duration-300 ${!isDarkMode ? "rotate-0" : "rotate-180"}`}>
        <SunIcon className={`h-5 w-5 ${!isDarkMode ? "block" : "hidden"}`} />
        <MoonIcon className={`h-5 w-5 ${isDarkMode ? "block" : "hidden"}`} />
      </label>
    </div>
  );
};
