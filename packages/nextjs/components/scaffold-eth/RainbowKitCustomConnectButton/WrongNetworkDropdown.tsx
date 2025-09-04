import { NetworkOptions } from "./NetworkOptions";
import { useDisconnect } from "wagmi";
import { ArrowLeftOnRectangleIcon, ChevronDownIcon } from "@heroicons/react/24/outline";

export const WrongNetworkDropdown = () => {
  const { disconnect } = useDisconnect();

  return (
    <div className="relative mr-2">
      <label tabIndex={0} className="inline-flex items-center px-3 py-1 text-sm font-medium bg-red-600 text-white rounded-lg gap-1 cursor-pointer hover:bg-red-700 transition-colors">
        <span>Wrong network</span>
        <ChevronDownIcon className="h-6 w-4 ml-2 sm:ml-0" />
      </label>
      <ul
        tabIndex={0}
        className="absolute right-0 top-full z-50 p-2 mt-1 shadow-lg bg-gray-100 dark:bg-gray-700/50 rounded-lg flex flex-col gap-1 w-64"
      >
        <NetworkOptions />
        <li>
          <button
            className="h-8 px-3 py-2 rounded-lg flex gap-3 hover:bg-gray-200 dark:bg-gray-700/50 transition-colors text-red-500"
            type="button"
            onClick={() => disconnect()}
          >
            <ArrowLeftOnRectangleIcon className="h-6 w-4 ml-2 sm:ml-0" />
            <span>Disconnect</span>
          </button>
        </li>
      </ul>
    </div>
  );
};
