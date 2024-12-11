# ERC20 workshop with RemixIDE

## Requirements

- [ ] Up and running a Besu node in local listening 8545 for JSON/RPC.
- [ ] Account created in [Remix IDE](https://remix.ethereum.org/)

# Preparing Metamask

1. Open Metamask in your navigator.
2. Click in the network dropdown (top left corner); click in the button *+ Add network*, *Add a network manually*.
   1. *Network name*: Localhost 8545
   2. *New RPC URL*: http://localhost:8545
   3. *Chain Id*: 1337
   4. *Chain symnbol*: ETH
   5. *URL Direction of block explorer*: http://localhost:25000/explorer/nodes
3. Import accounts:
   1. Click in the accounts dropdown (top center) and then click *+ Add account or hardware wallet*.
   2. Select *Import account*.
   4. Use *import* button.
   3. This private key `0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63`. This imports an account with the address `0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73`.
   5. Repeat from 1-4 pasting `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3`. Address: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`.
   6. Repeat from 1-4 pasting `0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f`. Address: ``0xf17f52151EbEF6C7334FAD080c5704D77216b732`.
4. Click in the network dropdown (top left corner) and select *Localhost 8545*.
5. Click in the accounts dropdown (top center) and select the account with address *0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73*. 

# Preparing workspace

1. Go to the Remix IDE through the link https://remix.ethereum.org/.
2. In the *FILE EXPLORER* search for _contracts_ folder and create if it does not exist.
3. Inside _contracts_:
   1. Create a file called `ERC20.sol` and copy the content of [ERC20.sol](./ERC20.sol).
   2. Leave open `ERC20.sol`.
4. Change to *SOLIDITY COMPILER*, set compiler version _0.6.0_ (EVM VERSION _istanbul_) and use the button *Compile ERC20.sol*.

# Connecting Remix to Besu

1. Open Metamask and connect the 3 imported accounts with *Localhost 8545* to RemixIDE
   1. Open Metamask
   2. Select RemixIDE icon in the top right of Metamask.
   3. Click in _Connect account_ button.
   4. Select the 3 imported accounts and click in _Next_ button.
   5. Click in _Confirm_.
2. In Remix, change to *DEPLOY & RUN TRANSACTIONS* tab.
3. Click in the selector of *ENVIRONMENT* and select *Injected Provider - MetaMask*.
4. In the list of the accounts, select `0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73`.
5. To deploy the contract, introduce the parámeters: `"BESU WORKSHOP,"B",2`
   1. *_NAME*: *"BESU WORKSHOP"* is the name of the token. 
   2. *_SYMBOL*: *"B"* is the symbol of the represented tokes.
   3. *_DECIMALS_*: *2* is the number of decimals represented in the token, ex: 10,82 -> 1_082 B
6. Once is executed, the new deployed contract will appear at the bottom left menu, including the list of methods to interact with it:
   1. *mint*: We will assign balance to an account.
      1. *to*: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
      2. *amount*: `10000000`
      3. Click in *transact*
      4. Look for the transaction in the list of transaction and review Transfer event.
   5. *balanceOf*: Asking for the balance of an account.
      1. *address*: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
      2. Click in *call*
      3. The result is `10000000`
      4. *address*: `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
      5. Click in *call*
      6. The result is `0`.
   6. Change in Metamask the account to `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`.
   7. *transfer*: We will transfer balance between accounts.
      1. *to*: `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
      2. *amount*: `5000000`
      3. Click in *transact*
      4. Look for the transaction in the list of transaction and review Transfer event.
   8. *balanceOf*: Asking for the balance of an account.
      1. *address*: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
      2. Click in *call*
      3. The result is `5000000`
      4. *address*: `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
      5. Click in *call*
      6. The result is `5000000`.
