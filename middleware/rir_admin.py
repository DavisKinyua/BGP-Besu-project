import os
import json
import time
from web3 import Web3

# --- CONFIGURATION ---
RPC_URL = os.getenv('WEB3_PROVIDER', 'http://172.18.0.101:8545')
CONTRACT_ADDR_RAW = os.getenv('CONTRACT_ADDRESS')

# The Genesis Private Key (RIR Admin)
ADMIN_PRIVATE_KEY = os.getenv('PRIVATE_KEY', '0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63')

# --- PHASE 1: ROA DATA (Prefixes) ---
# Format: (Prefix, ASN)
ROUTES_TO_REGISTER = [
    ("10.1.0.0/24", 100),
    ("10.100.0.0/24", 100),
    ("10.2.0.0/24", 200),
    ("10.3.0.0/24", 300),
    ("10.4.0.0/24", 400), # Client User
    ("10.5.0.0/24", 500), # Attacker
    ("10.6.0.0/24", 600)  # Client Control
]

# --- PHASE 2: ASPA DATA (Topology) ---
# Format: (Customer AS, Provider AS)
#Customer AS authorizes Provider AS to transit its routes
ASPA_RECORDS = [
    (400, 300), # Example: AS400 trusts AS300 as an upstream provider
    (100, 200),
    (200, 300),
    (500, 600),
    (600, 300)
]

def wait_for_connection(w3):
    print("⏳ Connecting to Besu Node...")
    while not w3.is_connected():
        time.sleep(2)
        print("... waiting for provider ...")
    print("✅ Connected to Blockchain!")

# --- NEW FUNCTION: Wait for contract bytecode ---
def wait_for_contract(w3, contract_address):
    print(f"⏳ Waiting for Smart Contract to be deployed at {contract_address}...")
    while True:
        try:
            # get_code returns the compiled bytecode. If empty, it's not deployed yet.
            contract_code = w3.eth.get_code(contract_address)
            if contract_code != b'' and contract_code != b'\x00':
                print("✅ Contract is deployed and ready!")
                break
        except Exception as e:
            pass # Ignore connection/sync errors while booting
            
        print("... contract not found yet, retrying in 5 seconds ...")
        time.sleep(5)

def main():
    if not CONTRACT_ADDR_RAW:
        print("❌ ERROR: CONTRACT_ADDRESS env var is missing. Exiting.")
        return

    w3 = Web3(Web3.HTTPProvider(RPC_URL))
    
    # 1. Wait for HTTP Port
    wait_for_connection(w3)
    
    # Fix checksum address formatting
    CONTRACT_ADDR = w3.to_checksum_address(CONTRACT_ADDR_RAW)

    # 2. Wait for Contract Deployment
    wait_for_contract(w3, CONTRACT_ADDR)

    # Load ABI
    try:
        with open('abi.json') as f:
            abi = json.load(f)
    except FileNotFoundError:
        print("ERROR: abi.json not found in /app directory.")
        return

    contract = w3.eth.contract(address=CONTRACT_ADDR, abi=abi)
    account = w3.eth.account.from_key(ADMIN_PRIVATE_KEY)
    
    print(f"Admin Account: {account.address}")
    
    # Get initial nonce
    nonce = w3.eth.get_transaction_count(account.address)

    print("\n---  PHASE 1: Route Registration (ROA) ---")

    for prefix, asn in ROUTES_TO_REGISTER:
        try:
            existing_owner = contract.functions.prefixRegistry(prefix).call()
            
            if existing_owner == asn:
                print(f"🔹 {prefix} is already registered to AS{asn}. Skipping.")
                continue

            print(f"📝 Registering {prefix} -> AS{asn}...", end=" ")
            
            tx = contract.functions.registerPrefix(prefix, asn).build_transaction({
                'chainId': 1337,
                'gas': 300000,
                'gasPrice': 0,
                'nonce': nonce,
                'from': account.address
            })

            signed_tx = w3.eth.account.sign_transaction(tx, private_key=ADMIN_PRIVATE_KEY)
            tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
            
            w3.eth.wait_for_transaction_receipt(tx_hash)
            print(f"✅ Sent! (Hash: {tx_hash.hex()[:10]}...)")
            
            nonce += 1
            time.sleep(0.5)

        except Exception as e:
            print(f"\n❌ Failed to register {prefix}: {e}")
            nonce = w3.eth.get_transaction_count(account.address)


    print("\n--- PHASE 2: Provider Authorization (ASPA) ---")
    
    for customer, provider in ASPA_RECORDS:
        try:
            # 1. Check if already authorized (Using your Solidity mapping name)
            is_authorized = contract.functions.authorizedProviders(customer, provider).call()
            
            if is_authorized:
                print(f"🔹 AS{customer} already authorizes AS{provider}. Skipping.")
                continue

            # 2. Build Transaction
            print(f"📝 Authorizing Customer AS{customer} -> Provider AS{provider}...", end=" ")
            
            tx = contract.functions.authorizeProvider(customer, provider).build_transaction({
                'chainId': 1337,
                'gas': 300000,
                'gasPrice': 0, 
                'nonce': nonce,
                'from': account.address
            })

            # 3. Sign and Send
            signed_tx = w3.eth.account.sign_transaction(tx, private_key=ADMIN_PRIVATE_KEY)
            tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
            
            # Wait for receipt
            w3.eth.wait_for_transaction_receipt(tx_hash)
            print(f"✅ Sent! (Hash: {tx_hash.hex()[:10]}...)")
            
            nonce += 1
            time.sleep(0.5)

        except Exception as e:
            print(f"\n❌ Failed to authorize ASPA record: {e}")
            nonce = w3.eth.get_transaction_count(account.address)

    print("\n--- 🏁 All Registrations Complete. Exiting. ---")

if __name__ == "__main__":
    main()