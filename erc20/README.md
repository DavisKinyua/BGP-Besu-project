# ERC20 workshop with RemixIDE

## Requirements

- [ ] Up and running a Besu node in local listening 8585 for JSON/RPC.
- [ ] Account created in [Remix IDE](https://remix.ethereum.org/)

# Preparing Metamask

1. Open Metamask in your navigator.
2. In the list of network, use the button *Add a custom network*.
   1. *Name of the network*: Localhost 8545
   2. *RPC URL by default*: http://localhost:8545
   3. *ChainId*: 1337
   4. *Chain symnbol*: ETH
   5. *URL Direction of block explorer*: http://localhost:25000/explorer/nodes
3. In the list of accounts, import this private keys:
   1. Selected the list of accounts, push *Add a new account or physical wallet*.
   2. Select *Import account*.
   3. Paste on it `0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` -> `0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73`.
   4. Use *import* button.
   5. Retry from 1-4 with `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` -> `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`.
   6. Retry from 1-4 with `0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` -> `0xf17f52151EbEF6C7334FAD080c5704D77216b732`.
4. In the list of networks, select *Localhost 8545*.
5. In the list of accounts, select the account with address *0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73*. 

# Preparing workspace

1. Access to Remix IDE through the link https://remix.ethereum.org/
2. In the *FILE EXPLORER* search for _contracts_ folder. If not exists, create it.
3. Inside _contracts_:
   1. Create a file called `IERC20.sol` and copy the content of [IERC20.sol](./IERC20.sol).
   2. Create a file called `ERC20.sol` and copy the content of [ERC20.sol](./ERC20.sol).
   3. Leave open `ERC20.sol`.
4. Change to *SOLIDITY COMPILER* and use the button *Compile ERC20.sol*.

# Connecting Remix to Besu

1. Open Metamask and connect the 3 imported accounts with *Localhost 8545* to RemixIDE
   1. Open Metamask
   2. Select RemixIDE icon in the top right of Metamask.
   3. Click on edit the accounts and select the 3 imported accounts.
   4. Click on edit the network and select *Localhost 8545*.
2. In remix, change to *DEPLOY & RUN TRANSACTIONS* tab.
3. Select the selector of *ENVIRONMENT* and select *Injected Provider - MetaMask*.
4. In the list of the accounts, select `0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73`.
5. To deploy the contract, introduce the parámeters: `"BESU WORKSHOP,"B",2`
   1. *_NAME*: *"BESU WORKSHOP"* is the name of the token. 
   2. *_SYMBOL*: *"B"* is the symbol of the represented tokes.
   3. *_DECIMALS_*: *2* is the number of decimals represented in the token, ex: 10,82 -> 1_082 B
6. Once is executed, appears in Remix the new deployed contract and the list of methods to interact with:
   1. *mint*: We will assign balance to an account.
      1. *to*: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
      2. *amount*: `10_000_000`
      3. Push on *transact*
      4. Look for the transaction in the list of transaction and review Transfer event.
   5. *balanceOf*: Asking for the balance of an account.
      1. *address*: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
      2. Push on *call*
      3. The result is `10_000_000`
      4. *address*: `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
      5. Push on *call*
      6. The result is `0`.
   6. Change in Metamask the account to `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`.
   7. *transfer*: We will transfer balance between accounts.
      1. *to*: `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
      2. *amount*: `5_000_000`
      3. Push on *transact*
      4. Look for the transaction in the list of transaction and review Transfer event.
   8. *balanceOf*: Asking for the balance of an account.
      1. *address*: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`
      2. Push on *call*
      3. The result is `5_000_000`
      4. *address*: `0xf17f52151EbEF6C7334FAD080c5704D77216b732`
      5. Push on *call*
      6. The result is `5_000_000`.
