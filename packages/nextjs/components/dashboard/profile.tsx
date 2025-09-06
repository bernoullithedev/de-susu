import {
    Wallet,
    ConnectWallet,
    WalletDropdown,
    WalletDropdownDisconnect,
  } from '@coinbase/onchainkit/wallet';
  
  import {
    Identity,
    Avatar,
    Name,
    Address,
  } from '@coinbase/onchainkit/identity';
  
  export function WalletComponents() {
    return (
      <div className="flex justify-end">
        <Wallet>
          <ConnectWallet>
            <Avatar className="h-6 w-6" />
            <Name />
          </ConnectWallet>
          <WalletDropdown>
            <Identity className="px-4 pt-3 pb-2" hasCopyAddressOnClick>
              <Avatar />
              <Name />
              <Address />
            </Identity>
            <WalletDropdownDisconnect />
          </WalletDropdown>
        </Wallet>
      </div>
    );
  }
  