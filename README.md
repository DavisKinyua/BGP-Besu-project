# Iob Besu Network Workshop

## Table of Contents

- [Iob Besu Network Workshop]
  - [Exercise 1: Configure and run a private QBFT (POA) Besu Network]
  - [Exercise 2: Deploy a new validator node and join the Network]
  - [Exercise 3: Deploy and explore analytics tools]

## Prerequisites

To run these tutorials, you must have the following installed:

- [Docker and Docker-compose](https://docs.docker.com/compose/install/)


## Exercise 1: Configure and run a private QBFT (POA) Besu Network
This exercise is designed to give you hands-on experience with setting up a permissioned blockchain network. By the end, you’ll understand the key steps involved in deploying a private network, establishing consensus rules, and connecting nodes securely and efficiently.

In this exercise, you will:

**Configure the Network Genesis File**: We’ll start by setting up a genesis file to define the network's parameters, such as chain ID and consensus algorithm, and establish the initial state of the blockchain.

**Set up Validator Nodes**: Next, you’ll configure nodes to act as validators, the designated participants responsible for producing new blocks. In a PoA network, these nodes are pivotal in maintaining the blockchain’s integrity.

**Start and Connect Nodes**: You’ll bring up the nodes and connect them within the private network, ensuring that communication is established between validators.

**Verify Network Connectivity and Block Production**: Finally, we’ll verify that the network is successfully producing blocks and maintaining connectivity between nodes.

### Step by step:

Start services and the network:
1. Run script `./run.sh`
    ```
    *************************************
    Iob Besu Network Quickstart
    *************************************
    Start network
    --------------------
    Starting network...
    [+] Running 13/13
     ✔ Network iob-besu-network                 Created                                                                                                                                                                                                                        0.1s 
     ✔ Volume "iob-besu-network_grafana"        Created                                                                                                                                                                                                                        0.0s 
     ✔ Volume "iob-besu-network_prometheus"     Created                                                                                                                                                                                                                        0.0s 
     ✔ Container iob-besu-network-validator1-1  Started                                                                                                                                                                                                                        0.9s 
     ✔ Container iob-besu-network-loki-1        Started                                                                                                                                                                                                                        1.0s 
     ✔ Container iob-besu-network-promtail-1    Started                                                                                                                                                                                                                        0.7s 
     ✔ Container iob-besu-network-grafana-1     Started                                                                                                                                                                                                                        0.9s 
     ✔ Container iob-besu-network-prometheus-1  Started                                                                                                                                                                                                                        0.5s 
     ✔ Container iob-besu-network-validator2-1  Started                                                                                                                                                                                                                        1.6s 
     ✔ Container iob-besu-network-validator4-1  Started                                                                                                                                                                                                                        1.3s 
     ✔ Container iob-besu-network-validator3-1  Started                                                                                                                                                                                                                        1.2s 
     ✔ Container rpcnode                        Started                                                                                                                                                                                                                        1.5s 
     ✔ Container iob-besu-network-explorer-1    Started                                                                                                                                                                                                                        1.9s 
    *************************************
    Iob Besu Network Quickstart 
    *************************************
    ----------------------------------
    List endpoints and services
    ----------------------------------
    JSON-RPC HTTP service endpoint                 : http://localhost:8545
    JSON-RPC WebSocket service endpoint            : ws://localhost:8546
    Web block explorer address                     : http://localhost:25000/explorer/nodes
    Prometheus address                             : http://localhost:9090/graph
    Grafana address                                : http://localhost:3000/d/XE4V0WGZz/besu-overview?orgId=1&refresh=10s&from=now-30m&to=now&var-system=All
    Collated logs using Grafana and Loki           : http://localhost:3000/d/Ak6eXLsPxFemKYKEXfcH/quorum-logs-loki?orgId=1&var-app=besu&var-search=
    
    For more information on the endpoints and services, refer to README.md in the installation directory.
    ```

## Exercise 2: Deploy a new validator node and join the Network
In this next part of our workshop, we’ll be taking the private Besu network you configured in Exercise 1 and expanding it by deploying an additional node and connecting it to the network.

In this exercise, you will:

**Deploy and Configure a New Validator Node**: Start by setting up a new Besu node, preparing it with the necessary configuration files to ensure it aligns with the existing network.

**Set Up Node Connectivity Parameters**: Configure the new node’s network settings so it can find and communicate with existing nodes in the network.

**Join the Node to the Network**: Establish a connection between the new node and the network by syncing it with the current state of the blockchain. We’ll cover any specific requirements for permissioned nodes and how to securely integrate them.

**Verify Node Synchronization and Connectivity**: Finally, ensure that the new node is properly connected, synchronized, and participating in block validation. You’ll also learn techniques for troubleshooting connectivity issues in case any arise.


### Step by step:

1. Following the deployed network on Exercise 1, in the docker-compose.yml file uncomment:
   * x-besu-def-attach-node: definition of custom toml without `node-private-key-file` param enabled, this will create node keys when node starts
   * validator5: definition of the new validator
   * network2: validator5 will strart in a diferent network (network2)
2. Run `docker compose up -d` to update current network with new validator5
    ````
       ✔ Container iob-besu-network-validator1-1  Running
       ✔ Container iob-besu-network-prometheus-1  Running
       ✔ Container iob-besu-network-validator4-1  Running
       ✔ Container iob-besu-network-loki-1        Running
       ✔ Container iob-besu-network-grafana-1     Running
       ✔ Container rpcnode                        Running
       ✔ Container iob-besu-network-validator3-1  Running
       ✔ Container iob-besu-network-explorer-1    Running
       ✔ Container iob-besu-network-validator2-1  Running
       ✔ Container iob-besu-network-promtail-1    Running
       ✔ Container iob-besu-network-validator5-1  Started
    ````
3. Retrieve validator5 **enode**  and add permissions to validators and rpc node using `perm_addNodesToAllowlist` method:
    ```bash
    #Validators
    curl -X POST --data '{"jsonrpc":"2.0","method":"perm_addNodesToAllowlist","params":[["<ENODE_VALIDATOR_5>"]], "id":1}' http://localhost:21001
    curl -X POST --data '{"jsonrpc":"2.0","method":"perm_addNodesToAllowlist","params":[["<ENODE_VALIDATOR_5>"]], "id":1}' http://localhost:21002
    curl -X POST --data '{"jsonrpc":"2.0","method":"perm_addNodesToAllowlist","params":[["<ENODE_VALIDATOR_5>"]], "id":1}' http://localhost:21003
    curl -X POST --data '{"jsonrpc":"2.0","method":"perm_addNodesToAllowlist","params":[["<ENODE_VALIDATOR_5>"]], "id":1}' http://localhost:21004
    #RCP Node
    curl -X POST --data '{"jsonrpc":"2.0","method":"perm_addNodesToAllowlist","params":[["<ENODE_VALIDATOR_5>"]], "id":1}' http://localhost:8545
    ```
4. Verifiy that validator1 `peerCount`, for example, has changed from 4 to 5
    ```bash
    curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1} localhost:21001'
    ```
## Exercise 3: Deploy and explore analytics tools
In this exercise, we’ll shift focus from network configuration to monitoring and analytics, adding visibility into the blockchain's performance and activity. Here, you’ll deploy analytics tools that enable you to gain deeper insights into your Besu network, track key metrics, and troubleshoot issues effectively.

In this exercise, you will:

**Deploy Monitoring Tools**: Begin by setting up key monitoring and analytics tools, such as Prometheus and Grafana, to capture and visualize blockchain metrics. These tools are widely used for monitoring distributed systems, offering flexibility in tracking a range of metrics.

**Configure Metrics Collection in Besu:** You’ll configure your Besu nodes to export relevant metrics to the analytics tools. This includes configuring endpoints for data export and setting up dashboards to display key indicators like block times, peer connectivity, and resource consumption.

**Explore Real-Time Network Data**: Once the analytics tools are connected, you’ll explore the dashboards, interpret different metrics, and understand what they reveal about your network’s status and performance.

### Step by step:

1. In the docker-compose.yml file, uncomment the following services and run `docker compose up -d`:
   * explorer: A tool for browsing blockchain data, including blocks, transactions, and addresses.
   * prometheus: An open-source system for collecting and storing real-time application and infrastructure metrics.
   * loki: A log aggregation tool for efficiently collecting and managing log data from multiple sources.
   * grafana: A visualization platform for creating dashboards to monitor and analyze metrics in real-time.
   * promtail: A log collector that sends logs to Loki for centralized management and search.
    ````
       ✔ Container iob-besu-network-validator1-1  Running 
       ✔ Container iob-besu-network-validator4-1  Running
       ✔ Container rpcnode                        Running   
       ✔ Container iob-besu-network-validator3-1  Running
       ✔ Container iob-besu-network-validator5-1  Running  
       ✔ Container iob-besu-network-validator2-1  Running
       ✔ Container iob-besu-network-explorer-1    Started
       ✔ Container iob-besu-network-prometheus-1  Started
       ✔ Container iob-besu-network-loki-1        Started
       ✔ Container iob-besu-network-grafana-1     Started  
       ✔ Container iob-besu-network-promtail-1    Started
    ````
2. Explore Grafana Besu Dashboard: http://localhost:3000/d/XE4V0WGZz/besu-overview?orgId=1&refresh=10s&from=now-30m&to=now&var-system=All
3. Explore Logs: http://localhost:3000/d/Ak6eXLsPxFemKYKEXfcH/quorum-logs-loki?orgId=1&var-app=besu&var-search=
4. Explore blocks and transactions: http://localhost:25000/explorer/nodes