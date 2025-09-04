import { Dispatch, SetStateAction, useEffect, useState } from "react";
import { ContractInput } from "./ContractInput";
import { getFunctionInputKey, getInitialTupleArrayFormState } from "./utilsContract";
import { replacer } from "~~/utils/scaffold-eth/common";
import { AbiParameterTuple } from "~~/utils/scaffold-eth/contract";

type TupleArrayProps = {
  abiTupleParameter: AbiParameterTuple & { isVirtual?: true };
  setParentForm: Dispatch<SetStateAction<Record<string, any>>>;
  parentStateObjectKey: string;
  parentForm: Record<string, any> | undefined;
};

export const TupleArray = ({ abiTupleParameter, setParentForm, parentStateObjectKey }: TupleArrayProps) => {
  const [form, setForm] = useState<Record<string, any>>(() => getInitialTupleArrayFormState(abiTupleParameter));
  const [additionalInputs, setAdditionalInputs] = useState<Array<typeof abiTupleParameter.components>>([
    abiTupleParameter.components,
  ]);

  const depth = (abiTupleParameter.type.match(/\[\]/g) || []).length;

  useEffect(() => {
    // Extract and group fields based on index prefix
    const groupedFields = Object.keys(form).reduce(
      (acc, key) => {
        const [indexPrefix, ...restArray] = key.split("_");
        const componentName = restArray.join("_");
        if (!acc[indexPrefix]) {
          acc[indexPrefix] = {};
        }
        acc[indexPrefix][componentName] = form[key];
        return acc;
      },
      {} as Record<string, Record<string, any>>,
    );

    let argsArray: Array<Record<string, any>> = [];

    Object.keys(groupedFields).forEach(key => {
      const currentKeyValues = Object.values(groupedFields[key]);

      const argsStruct: Record<string, any> = {};
      abiTupleParameter.components.forEach((component, componentIndex) => {
        argsStruct[component.name || `input_${componentIndex}_`] = currentKeyValues[componentIndex];
      });

      argsArray.push(argsStruct);
    });

    if (depth > 1) {
      argsArray = argsArray.map(args => {
        return args[abiTupleParameter.components[0].name || "tuple"];
      });
    }

    setParentForm(parentForm => {
      return { ...parentForm, [parentStateObjectKey]: JSON.stringify(argsArray, replacer) };
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [JSON.stringify(form, replacer)]);

  const addInput = () => {
    setAdditionalInputs(previousValue => {
      const newAdditionalInputs = [...previousValue, abiTupleParameter.components];

      // Add the new inputs to the form
      setForm(form => {
        const newForm = { ...form };
        abiTupleParameter.components.forEach((component, componentIndex) => {
          const key = getFunctionInputKey(
            `${newAdditionalInputs.length - 1}_${abiTupleParameter.name || "tuple"}`,
            component,
            componentIndex,
          );
          newForm[key] = "";
        });
        return newForm;
      });

      return newAdditionalInputs;
    });
  };

  const removeInput = () => {
    // Remove the last inputs from the form
    setForm(form => {
      const newForm = { ...form };
      abiTupleParameter.components.forEach((component, componentIndex) => {
        const key = getFunctionInputKey(
          `${additionalInputs.length - 1}_${abiTupleParameter.name || "tuple"}`,
          component,
          componentIndex,
        );
        delete newForm[key];
      });
      return newForm;
    });
    setAdditionalInputs(inputs => inputs.slice(0, -1));
  };

  return (
    <div>
      <div className="bg-gray-100 pl-4 py-1.5 border-2 border-gray-300">
        <details className="group">
          <summary className="flex items-center justify-between cursor-pointer p-0 hover:bg-gray-200 transition-colors group-open:mb-1 text-gray-600">
            <p className="m-0 text-[1rem]">{abiTupleParameter.internalType}</p>
            <span className="group-open:rotate-180 transition-transform duration-200 mr-2">▼</span>
          </summary>
          <div className="ml-3 flex-col space-y-2 border-gray-400 border-l-2 pl-4">
          {additionalInputs.map((additionalInput, additionalIndex) => (
            <div key={additionalIndex} className="space-y-1">
              <span className="inline-flex items-center px-2 py-1 text-xs font-medium bg-gray-200 text-gray-700 rounded-full">
                {depth > 1 ? `${additionalIndex}` : `tuple[${additionalIndex}]`}
              </span>
              <div className="space-y-4">
                {additionalInput.map((param, index) => {
                  const key = getFunctionInputKey(
                    `${additionalIndex}_${abiTupleParameter.name || "tuple"}`,
                    param,
                    index,
                  );
                  return (
                    <ContractInput setForm={setForm} form={form} key={key} stateObjectKey={key} paramType={param} />
                  );
                })}
              </div>
            </div>
          ))}
          </div>
          <div className="flex space-x-2">
            <button className="inline-flex items-center px-3 py-1 text-sm font-medium bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors" onClick={addInput}>
              +
            </button>
            {additionalInputs.length > 0 && (
              <button className="inline-flex items-center px-3 py-1 text-sm font-medium bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors" onClick={removeInput}>
                -
              </button>
            )}
          </div>
        </details>
      </div>
    </div>
  );
};
