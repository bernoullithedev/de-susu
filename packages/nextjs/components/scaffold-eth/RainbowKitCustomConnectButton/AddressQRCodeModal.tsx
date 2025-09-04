import { QRCodeSVG } from "qrcode.react";
import { Address as AddressType } from "viem";
import { Address } from "~~/components/scaffold-eth";

type AddressQRCodeModalProps = {
  address: AddressType;
  modalId: string;
};

export const AddressQRCodeModal = ({ address, modalId }: AddressQRCodeModalProps) => {
  return (
    <>
      <div>
        <input type="checkbox" id={`${modalId}`} className="hidden peer" />
        <div className="fixed inset-0 z-50 hidden peer-checked:flex items-center justify-center bg-black bg-opacity-50">
          <div className=" rounded-lg p-6 max-w-md w-full mx-4 relative">
            {/* dummy input to capture event onclick on modal box */}
            <input className="h-0 w-0 absolute top-0 left-0" />
            <label htmlFor={`${modalId}`} className="absolute right-3 top-3 w-8 h-8 flex items-center justify-center rounded-full bg-gray-200 hover:bg-gray-300 cursor-pointer">
              ✕
            </label>
            <div className="space-y-3 py-6">
              <div className="flex flex-col items-center gap-6">
                <QRCodeSVG value={address} size={256} />
                <Address address={address} format="long" disableAddressLink onlyEnsOrAddress />
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};
