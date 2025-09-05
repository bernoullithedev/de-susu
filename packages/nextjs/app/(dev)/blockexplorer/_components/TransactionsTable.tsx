import { TransactionHash } from "./TransactionHash";
import { formatEther } from "viem";
import { Address } from "~~/components/scaffold-eth";
import { useTargetNetwork } from "~~/hooks/scaffold-eth/useTargetNetwork";
import { TransactionWithFunction } from "~~/utils/scaffold-eth";
import { TransactionsTableProps } from "~~/utils/scaffold-eth/";

export const TransactionsTable = ({ blocks, transactionReceipts }: TransactionsTableProps) => {
  const { targetNetwork } = useTargetNetwork();

  return (
    <div className="flex justify-center px-4 md:px-0">
      <div className="overflow-x-auto w-full shadow-2xl rounded-xl">
        <table className="w-full text-xl bg-gray-200 dark:bg-gray-800/50 border-collapse">
          <thead>
            <tr className="rounded-xl text-sm  bg-blue-600 text-white">
              <th className="p-4 text-left">Transaction Hash</th>
              <th className="p-4 text-left">Function Called</th>
              <th className="p-4 text-left">Block Number</th>
              <th className="p-4 text-left">Time Mined</th>
              <th className="p-4 text-left">From</th>
              <th className="p-4 text-left">To</th>
              <th className="p-4 text-right">Value ({targetNetwork.nativeCurrency.symbol})</th>
            </tr>
          </thead>
          <tbody>
            {blocks.map(block =>
              (block.transactions as TransactionWithFunction[]).map(tx => {
                const receipt = transactionReceipts[tx.hash];
                const timeMined = new Date(Number(block.timestamp) * 1000).toLocaleString();
                const functionCalled = tx.input.substring(0, 10);

                return (
                  <tr key={tx.hash} className="hover:bg-gray-50 dark:hover:bg-gray-700/50 text-sm border-b border-gray-200">
                    <td className="w-1/12 p-4">
                      <TransactionHash hash={tx.hash} />
                    </td>
                    <td className="w-2/12 p-4">
                      {tx.functionName === "0x" ? "" : <span className="mr-1">{tx.functionName}</span>}
                      {functionCalled !== "0x" && (
                        <span className="inline-flex items-center px-2 py-1 text-xs font-bold bg-blue-600 text-white rounded-full">{functionCalled}</span>
                      )}
                    </td>
                    <td className="w-1/12 p-4">{block.number?.toString()}</td>
                    <td className="w-2/12 p-4">{timeMined}</td>
                    <td className="w-2/12 p-4">
                      <Address address={tx.from} size="sm" onlyEnsOrAddress />
                    </td>
                    <td className="w-2/12 p-4">
                      {!receipt?.contractAddress ? (
                        tx.to && <Address address={tx.to} size="sm" onlyEnsOrAddress />
                      ) : (
                        <div className="relative">
                          <Address address={receipt.contractAddress} size="sm" onlyEnsOrAddress />
                          <small className="absolute top-4 left-4">(Contract Creation)</small>
                        </div>
                      )}
                    </td>
                    <td className="text-right p-4">
                      {formatEther(tx.value)} {targetNetwork.nativeCurrency.symbol}
                    </td>
                  </tr>
                );
              }),
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
