import { Dispatch, SetStateAction, useEffect, useState } from "react";
import { ContractInput } from "./ContractInput";
import { getFunctionInputKey, getInitialTupleFormState } from "./utilsContract";
import { replacer } from "~~/utils/scaffold-eth/common";
import { AbiParameterTuple } from "~~/utils/scaffold-eth/contract";

type TupleProps = {
  abiTupleParameter: AbiParameterTuple;
  setParentForm: Dispatch<SetStateAction<Record<string, any>>>;
  parentStateObjectKey: string;
  parentForm: Record<string, any> | undefined;
};

export const Tuple = ({ abiTupleParameter, setParentForm, parentStateObjectKey }: TupleProps) => {
  const [form, setForm] = useState<Record<string, any>>(() => getInitialTupleFormState(abiTupleParameter));

  useEffect(() => {
    const values = Object.values(form);
    const argsStruct: Record<string, any> = {};
    abiTupleParameter.components.forEach((component, componentIndex) => {
      argsStruct[component.name || `input_${componentIndex}_`] = values[componentIndex];
    });

    setParentForm(parentForm => ({ ...parentForm, [parentStateObjectKey]: JSON.stringify(argsStruct, replacer) }));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [JSON.stringify(form, replacer)]);

  return (
    <div>
      <div className="bg-gray-100 pl-4 py-1.5 border-2 border-gray-300">
        <details className="group">
          <summary className="flex items-center justify-between cursor-pointer p-0 hover:bg-gray-200 transition-colors group-open:mb-2 text-gray-600">
            <p className="m-0 p-0 text-[1rem]">{abiTupleParameter.internalType}</p>
            <span className="group-open:rotate-180 transition-transform duration-200 mr-2">▼</span>
          </summary>
          <div className="ml-3 flex-col space-y-4 border-gray-400 border-l-2 pl-4">
          {abiTupleParameter?.components?.map((param, index) => {
            const key = getFunctionInputKey(abiTupleParameter.name || "tuple", param, index);
            return <ContractInput setForm={setForm} form={form} key={key} stateObjectKey={key} paramType={param} />;
          })}
          </div>
        </details>
      </div>
    </div>
  );
};
