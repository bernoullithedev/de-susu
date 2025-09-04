import { InformationCircleIcon } from "@heroicons/react/20/solid";

export const InheritanceTooltip = ({ inheritedFrom }: { inheritedFrom?: string }) => (
  <>
    {inheritedFrom && (
      <span
        className="relative px-2 md:break-normal"
        title={`Inherited from: ${inheritedFrom}`}
      >
        <InformationCircleIcon className="h-4 w-4" aria-hidden="true" />
      </span>
    )}
  </>
);
