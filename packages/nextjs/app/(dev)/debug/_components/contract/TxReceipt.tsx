import { TransactionReceipt } from "viem";
import { CheckCircleIcon, DocumentDuplicateIcon } from "@heroicons/react/24/outline";
import { ObjectFieldDisplay } from "~~/app/(dev)/debug/_components/contract";
import { useCopyToClipboard } from "~~/hooks/scaffold-eth/useCopyToClipboard";
import { replacer } from "~~/utils/scaffold-eth/common";

export const TxReceipt = ({ txResult }: { txResult: TransactionReceipt }) => {
  const { copyToClipboard: copyTxResultToClipboard, isCopiedToClipboard: isTxResultCopiedToClipboard } =
    useCopyToClipboard();

  return (
    <div className="flex text-sm rounded-3xl min-h-0 bg-gray-100 dark:bg-gray-800 py-0">
      <div className="mt-1 pl-2">
        {isTxResultCopiedToClipboard ? (
          <CheckCircleIcon
            className="ml-1.5 text-xl font-normal text-gray-900 dark:text-gray-100 h-5 w-5 cursor-pointer"
            aria-hidden="true"
          />
        ) : (
          <DocumentDuplicateIcon
            className="ml-1.5 text-xl font-normal h-5 w-5 cursor-pointer hover:text-gray-600 dark:hover:text-gray-400"
            aria-hidden="true"
            onClick={() => copyTxResultToClipboard(JSON.stringify(txResult, replacer, 2))}
          />
        )}
      </div>
      <div className="flex-1">
        <details className="group">
          <summary className="flex items-center justify-between cursor-pointer text-sm py-1.5 pl-1 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors rounded-l-3xl">
            <strong>Transaction Receipt</strong>
            <span className="group-open:rotate-180 transition-transform duration-200 mr-2">▼</span>
          </summary>
          <div className="overflow-auto bg-gray-100 dark:bg-gray-800 rounded-t-none rounded-3xl pl-0!">
          <pre className="text-xs">
            {Object.entries(txResult).map(([k, v]) => (
              <ObjectFieldDisplay name={k} value={v} size="xs" leftPad={false} key={k} />
            ))}
          </pre>
          </div>
        </details>
      </div>
    </div>
  );
};
