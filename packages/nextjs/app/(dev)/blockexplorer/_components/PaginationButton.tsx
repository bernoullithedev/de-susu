import { ArrowLeftIcon, ArrowRightIcon } from "@heroicons/react/24/outline";

type PaginationButtonProps = {
  currentPage: number;
  totalItems: number;
  setCurrentPage: (page: number) => void;
};

const ITEMS_PER_PAGE = 20;

export const PaginationButton = ({ currentPage, totalItems, setCurrentPage }: PaginationButtonProps) => {
  const isPrevButtonDisabled = currentPage === 0;
  const isNextButtonDisabled = currentPage + 1 >= Math.ceil(totalItems / ITEMS_PER_PAGE);

  const prevButtonClass = isPrevButtonDisabled ? "opacity-50 cursor-not-allowed" : "bg-blue-600 text-white hover:bg-blue-700";
  const nextButtonClass = isNextButtonDisabled ? "opacity-50 cursor-not-allowed" : "bg-blue-600 text-white hover:bg-blue-700";

  if (isNextButtonDisabled && isPrevButtonDisabled) return null;

  return (
    <div className="mt-5 justify-end flex gap-3 mx-5">
      <button
        className={`inline-flex items-center px-2 py-1 text-sm font-medium rounded-lg transition-colors ${prevButtonClass}`}
        disabled={isPrevButtonDisabled}
        onClick={() => setCurrentPage(currentPage - 1)}
      >
        <ArrowLeftIcon className="h-4 w-4" />
      </button>
      <span className="self-center text-gray-900 font-medium">Page {currentPage + 1}</span>
      <button
        className={`inline-flex items-center px-2 py-1 text-sm font-medium rounded-lg transition-colors ${nextButtonClass}`}
        disabled={isNextButtonDisabled}
        onClick={() => setCurrentPage(currentPage + 1)}
      >
        <ArrowRightIcon className="h-4 w-4" />
      </button>
    </div>
  );
};
