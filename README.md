## Service Endpoints

* **RPC Node:** `http://localhost:8545`
* **Quorum Explorer:** `http://localhost:25000`
* **Prometheus:** `http://localhost:9090`
* **Grafana:** `http://localhost:3000`

## Logs
Logs are mapped to the `./logs` directory on your host machine.

Check status of a particular container
docker ps -a --filter "name=your_container_name" --format "{{.Status}}"
docker ps -a --filter "name=uni-guard" --format "{{.Status}}"


For AS400 to work:
docker exec as400 sh -c "echo 'function check_blocklist() { return false; }' > /etc/bird/blocklist.conf"

command to show bird.conf of running router:
docker exec as400 cat /etc/bird/bird.conf

command to show blocked invalid routes:
docker exec as400 cat /etc/bird/blocklist.conf

show neighbors:
docker exec as400 grep -E "neighbor|router id" /etc/bird/bird.conf


identify all neighbors by name routing sources details:
docker exec as400 birdc -s /var/run/bird/bird.ctl show protocols

Show specific neigbor detail:
docker exec as400 birdc -s /var/run/bird/bird.ctl show protocols <neighbor_name>
docker exec as400 birdc -s /var/run/bird/bird.ctl show protocols AS500


show specific route in the routing table:
docker exec as400 birdc -s /var/run/bird/bird.ctl show route for 10.100.0.1/32
docker exec as400 birdc -s /var/run/bird/bird.ctl show route | grep -E "10.100.0.1"

show more details on why specific routes choosen:
docker exec as400 birdc -s /var/run/bird/bird.ctl show route for 10.100.0.1/32 all

Filter Variations: Depending on what you are looking for, you can use these variations:

All paths (not just primary):	show route 10.1.0.0/24
The best path only:				show route primary 10.1.0.0/24
Routes from a specific peer:	show route protocol <neighbor_name>
Where an IP belongs:			show route for 10.1.0.5 (BIRD finds the matching subnet)


Enable a disabled neighbor:
docker exec as400 birdc -s /var/run/bird/bird.ctl enable <neighbor_name>
docker exec as400 birdc -s /var/run/bird/bird.ctl enable AS500

Perform reload:
docker exec as400 birdc -s /var/run/bird/bird.ctl configure

soft reconfigure:
docker exec as400 birdc -s /var/run/bird/bird.ctl reload all

Docker
docker compose stop AS500
docker compose build -d AS500

Strictly enforce valid upstream neigbors for AS400 as AS300: on uni-guard
VALID_UPSTREAMS = [300]
this blocks all routes received from AS500.

AS400 to accept AS500's legitimate routes but block AS500's hijacked routes (like 10.100.0.1/32), simply add 500 to AS400 trusted neighbors list in uni_guard.py:
VALID_UPSTREAMS = [300, 500]
docker compose stop uni-guard
docker compose build uni-guard


Testing attack simulation:

1. Stop Uni-Guard: First, shut down python security container so it stops monitoring the BGP network:
docker compose stop uni-guard

2. Reset the AS400 Blocklist
Even with the bot stopped, BIRD will continue enforcing the last configuration it was given. manually empty the blocklist.conf file and tell the router to apply the blank slate

docker exec as400 sh -c "echo 'define BAD_PREFIXES = [ 127.0.0.1/32 ];' > /etc/bird/blocklist.conf && birdc -s /var/run/bird/bird.ctl configure"

3. Verify the Hijack Propagation
when the filters are cleared and the guard is sleeping, AS400 will blindly trust the routes advertised by AS500.
docker exec as400 birdc show route

show routes exported to a particular neighbor:
docker exec as400 birdc -s /var/run/bird/bird.ctl show route export AS300



The complete automated control panel for the demonstration using these four commands:

1. Start the Attack: ./attack.sh
(Shows the hijack entering AS600, but being blocked by Uni-Guard on AS400).

2. Show the Vulnerability: ./stop_guard.sh
(Uni-Guard goes to sleep. The hijack instantly propagates into AS400. Pings from client-user will fail).

3. Defense: ./start_guard.sh
(Uni-Guard wakes up, scans the table, sees the hijack, and dynamically filters it. Pings from client-user restore).

4. End the Scenario: ./stop_attack.sh
(The attacker stops advertising the malicious route, returning the whole network to peace).



Ensure Uni-Guard is running: Use ./start_guard.sh to ensure the bot is actively scanning.

Launch the Attack: Run ./attack.sh.

Check Unprotected AS600: Run docker exec as600 birdc -s /var/run/bird/bird.ctl show route. You will see it has accepted both poisoned routes.

Check Protected AS400: Watch the Uni-Guard logs (docker logs -f uni-guard). You will see it identify the fake ROA origin, identify the spoofed ASPA path, and slam the door on both of them!
