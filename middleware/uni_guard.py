import os
import time
import json
import re
import subprocess
import requests
import ipaddress  
from web3 import Web3

# --- CONFIGURATION ---
BIRD_SOCKET = "/var/run/bird/bird.ctl"
BLOCKLIST_FILE = "/etc/bird/blocklist.conf"
CHECK_INTERVAL = 10 

# Track tuples of (Prefix, Malicious_Neighbor)
blocked_routes = set() 

# --- BLOCKCHAIN SETUP ---
rpc_url = os.getenv('WEB3_PROVIDER', 'http://172.18.0.101:8545')
w3 = Web3(Web3.HTTPProvider(rpc_url))

print("\n--- INITIALIZING UNI-GUARD (SURGICAL PEER FILTERING) ---")

# 1. Wait for Blockchain to Boot
while True:
    try:
        if w3.is_connected():
            print("✅ Connected to Blockchain Node!")
            break
    except requests.exceptions.ConnectionError:
        pass 
    except Exception as e:
        pass 
    time.sleep(5)

# 2. Wait for Contract Address
contract_addr_raw = os.getenv('CONTRACT_ADDRESS')
while not contract_addr_raw:
    time.sleep(5)
    contract_addr_raw = os.getenv('CONTRACT_ADDRESS')

contract_addr = w3.to_checksum_address(contract_addr_raw)

# 3. Load ABI
try:
    with open('abi.json') as f: 
        abi = json.load(f)
except FileNotFoundError:
    print("❌ CRITICAL: abi.json missing!")
    exit(1)

contract = w3.eth.contract(address=contract_addr, abi=abi)
print(f"✅ Smart Contract loaded at {contract_addr}")


# --- SURGICAL FILTERING LOGIC (UPGRADED) ---
def update_blocklist(prefix, neighbor):
    """
    Writes a dynamic BIRD function to filter specific prefixes FROM specific neighbors.
    """
    if (prefix, neighbor) in blocked_routes:
        return 

    blocked_routes.add((prefix, neighbor))
    
    # Build the BIRD function
    file_content = "function check_blocklist() {\n"
    for p, n in blocked_routes:
        # bgp_path.first checks the immediate neighbor ASN that sent the route!
        file_content += f"    if (net = {p} && bgp_path.first = {n}) then return true;\n"
    file_content += "    return false;\n}\n"
    
    try:
        with open(BLOCKLIST_FILE, "w") as f:
            f.write(file_content)
            
        print(f"🔄 Reloading BIRD router configuration...")
        os.system(f"birdc -s {BIRD_SOCKET} configure")
        print(f"🛡️  SUCCESS: {prefix} from AS{neighbor} has been surgically filtered!")
        
    except Exception as e:
        print(f"❌ Error updating blocklist file: {e}")


# --- BGP PARSING ---
def get_bird_routes():
    routes = []
    cmd = ["birdc", "-s", BIRD_SOCKET, "show", "route", "all"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        return []

    current_prefix = None
    current_neighbor = None
    prefix_pattern = re.compile(r"^(\d+\.\d+\.\d+\.\d+/\d+)\s+.*\[(AS\d+)\s+")
    path_pattern = re.compile(r"\s+BGP.as_path:\s+(.*)")

    for line in result.stdout.splitlines():
        pref_match = prefix_pattern.search(line)
        if pref_match:
            current_prefix = pref_match.group(1)
            current_neighbor = int(pref_match.group(2).replace("AS", ""))
            continue

        path_match = path_pattern.search(line)
        if path_match and current_prefix:
            as_path_str = path_match.group(1).strip()
            try:
                as_path = [int(x) for x in as_path_str.split() if x.isdigit()]
                if as_path:
                    origin_asn = as_path[-1] 
                    routes.append({
                        'prefix': current_prefix,
                        'neighbor': current_neighbor,
                        'origin': origin_asn,
                        'full_path': as_path
                    })
            except ValueError:
                pass
            current_prefix = None 

    return routes


# --- MAIN SECURITY LOOP ---
def mitigate():
    print("\n--- 🔍 SURGICAL ASPA & ORIGIN CHECK ---")
    current_routes = get_bird_routes()
    
    if not current_routes:
        print("ℹ️  No BGP routes found.")
        return

    for route in current_routes:
        prefix = route['prefix']
        neighbor = route['neighbor']
        origin = route['origin']
        path = route['full_path']

        # Skip if already blocked
        if (prefix, neighbor) in blocked_routes:
            continue

        # --- STEP 1: ASPA CHECK (Full Path Validation via Blockchain) ---
        aspa_valid = True
        if len(path) > 1:
            for i in range(len(path) - 1):
                provider_asn = path[i]     
                customer_asn = path[i+1]   
                
                try:
                    is_pair_valid = contract.functions.isPathPairValid(customer_asn, provider_asn).call()
                    if not is_pair_valid:
                        print(f"🚨 ASPA VIOLATION: AS{provider_asn} is NOT an authorized provider for AS{customer_asn}!")
                        aspa_valid = False
                        break 
                except Exception as e:
                    print(f"⚠️ Blockchain Error during ASPA check: {e}")

        if not aspa_valid:
            print(f"🛡️  ACTION: Filtering origin_attack route {prefix} strictly from AS{neighbor}...")
            update_blocklist(prefix, neighbor)
            continue 

        # --- STEP 2: DYNAMIC ROA CHECK (Subprefix & Origin Validation) ---
        try:
            adv_net = ipaddress.ip_network(prefix, strict=False)
            roa_status = "NOT_FOUND"

            # 1. Check if the exact prefix is registered
            exact_owner = contract.functions.prefixRegistry(prefix).call()
            
            if exact_owner != 0:
                if exact_owner == origin:
                    roa_status = "VALID"
                else:
                    roa_status = "INVALID"
                    print(f"🚨 ROA HIJACK: {prefix} belongs to AS{exact_owner}, NOT AS{origin}!")
            else:
                # 2. Subprefix Check: Walk up the tree to find a parent (e.g., check /31 down to /8)
                for plen in range(adv_net.prefixlen - 1, 7, -1):
                    parent_net = str(adv_net.supernet(new_prefix=plen))
                    parent_owner = contract.functions.prefixRegistry(parent_net).call()
                    
                    if parent_owner != 0:
                        # We found a parent prefix! Since the exact child wasn't registered, it's an unauthorized subprefix
                        roa_status = "INVALID"
                        print(f"🚨 SUBPREFIX HIJACK: {prefix} (AS{origin}) is an unauthorized subprefix of {parent_net} (AS{parent_owner})!")
                        break

            # 3. Apply Policy
            if roa_status == "VALID":
                print(f"✅ SECURE: {prefix} | Path: {path} | ASPA: OK | ROA: OK")
            elif roa_status == "NOT_FOUND":
                print(f"✅ ALLOWED (Unregistered): {prefix} | Path: {path} | ASPA: OK | ROA: NOT FOUND")
            else:
                print(f"🛡️  ACTION: Filtering malicious route {prefix} strictly from AS{neighbor}...")
                update_blocklist(prefix, neighbor)

        except Exception as e:
            print(f"⚠️ Validation Error for {prefix}: {e}")


if __name__ == "__main__":
    print(f"\n🛡️ Uni-Guard Active. Monitoring BGP Table every {CHECK_INTERVAL} seconds...")
    
    # Initialize with an empty function
    with open(BLOCKLIST_FILE, "w") as f:
        f.write("function check_blocklist() {\n    return false;\n}\n")
    
    while True:
        mitigate()
        time.sleep(CHECK_INTERVAL)