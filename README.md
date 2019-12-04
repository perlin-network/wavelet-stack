# Wavelet Stack and Swarm Manager
## Introduction
Wavelet Stack and Swarm manager lets you run Wavelet Stacks on
Docker Swarms.  Additionally, it helps manage Docker swarms using
Docker Machine.

There are three provided tools:

  1. `manage-swarm` - Manage Docker Swarm instances
  2. `manage-stack` - Manage Wavelet Stack on a Docker Swarm
  3. `build-all-nodes` - Builds all the nodes required to run a stack

These tools will look at configuration files in the `config/` directory
as well as on `/etc/wavelet-stack` on remote Docker Machine hosts.

The configuration files are:

  1. `config/default` - Always loaded;  Useful for setting "`stackName`" to set the default stack
  2. `config/swarm/<swarmName>` - Loaded when using a particular swarm
  3. `config/stack/<stackName>` - Loaded when using a particular stack, should not be used for remote stacks because other developers may not have the same configuration.  It is usually better to use `manage-stack edit-config` to edit this.

## manage-swarm
The `manage-swarm` tool helps create and manage remote Docker swarms using
Docker Machine.

### manage-swarm create
`manage-swarm create <provider> <swarmName> ...`

Creates a new Swarm.  Currently the only provider supported is
digitalocean.  The Swarm will be named _<swarmName>_.  This name
will be the basis of serveral [docker machine](https://docs.docker.com/machine/)
hosts added to the local system.

`manage-swarm create digitalocean <swarmName> <apiToken> [--count <n>] [--size <n>] [--region <name>]`

Creates a new Swarm on DigitalOcean using the specified [API Token](https://www.digitalocean.com/docs/api/create-personal-access-token/).
The `--count` argument specifies the number of hosts to create.  The `--size`
argument specifies the DigitalOcean droplet size to use for each host.  The
`--region` argument specifies the DigitalOcean region name to place all the
droplets in.  You may specify the value "`ask`" for the arguments `--size`
and `--region` to be interactively prompted for a list of options.

### manage-swarm import
`manage-swarm import <ip>`

Import the configuration for a swarm by SSHing into one of the machines
managed.  Another administrative user must have already added your SSH
key to the machine's `~/.ssh/authorized_keys` file.  This can be done
using `docker-machine ssh` to login to the system.

### manage-swarm expand
`manage-swarm expand <swarmName> [<count> [...]]`

Expands a swarm by _<count>_ hosts (default 1).  Takes the same arguments as
`manage-swarm create` for the provider the swarm was created on.

### manage-swarm destroy
`manage-swarm destroy <swarmName>`

Destroy a swarm -- USE WITH EXTREME CAUTION.

### manage-swarm status <swarmName>
`manage-swarm status <swarmName>`

Get the status of a swarm.

### manage-swarm list
`manage-swarm list`

List known swarms from the local configuration database.

## manage-stack
The `manage-stack` tool is the most commonly used tool.  It helps manage a specified
stack.

Stack configurations are stored in `./config/stacks/` locally, or in `/etc/wavelet-stack`
on the Docker Machine host if using a Swarm.

Configuration options are:

  1. `REGISTRY` - Docker Registry to use (defaults to `localhost:5000`)
  2. `WAVELET_GENESIS` - Wavelet Genesis block descriptor
  3. `WAVELET_KEYS` - CSV list of private keys and public keys
  4. `WAVELET_NODES` - Number of Wavelet nodes to run (defaults to `3`)
  5. `WAVELET_RICH_WALLETS` - Number of Rich wallets to create if generating the Genesis block (that is, if `WAVELET_GENEISIS` is not supplied; defaults to `3`)
  6. `WAVELET_SNOWBALL_K` - Wavelet Snowball K
  7. `WAVELET_SNOWBALL_BETA` - Wavelet Snowball Beta
  8. `WAVELET_MEMORY_MAX` - Max amount of memory to terminate the node after (in MiB)
  9. `WAVELET_NO_RPC` - Boolean to indicate whether not RPC ports are exposed (if not specified as true, random port)
  10. `WAVELET_RPC_PORT` - Port to listen for the first node for RPC requests
  11. `WAVELET_TAG` - Tag of the wavelet image to pull down (defaults to `latest`)
  12. `WAVELET_CLEAN_VOLUMES` - Boolean to indicate whether or not the volumes are removed on `stop` or `reset`
  13. `WAVELET_API_HOST` - Hostname, if supplied, HTTPS support is enabled on port 443/tcp
  14. `WAVELET_API_PORT` - Port to listen on for API requests (HTTP-only) (if not specified, random port)
  15. `WAVELET_API_ACME_ACCOUNT_KEY` - PEM encoded ACME account key for autocert.  Generally if `WAVELET_API_HOST` is provided, this should be provided also.
  16. `WAVELET_BACKUP_DB` - Boolean to indicate whether database backups are automatically taken for wavelet nodes
  17. `WAVELET_BUILD_DIR` - Directory to rebuild the "wavelet" container from when building all images using `build-all-nodes`
  18. `WAVELET_RESTART_ON_PEER_CHANGE` - Boolean to indicate whether wavelet should be restarted if peers change (defaults to true)
  19. `WAVELET_REBUILD_ON_START` - Indicate that the `build-all-nodes` script should be run for the given stack when it is started (defaults to false)

```
Usage: manage-stack [-s <stackName>] {stop|start|update|restart-wavelet|reset|status}
       manage-stack [-s <stackName>] benchmark [<count>]
       manage-stack [-s <stackName>] nobenchmark
       manage-stack [-s <stackName>] {attach|shell|logs|debug-wavelet} <nodeId>
       manage-stack [-s <stackName>] {config|edit-config}
       manage-stack [-s <stackName>] dump-db <nodeId> <outputFile>
       manage-stack [-s <stackName>] cp <src>... <dest>
       manage-stack [-s <stackName>] duplicate-stack <newStackName>
```

### manage-stack stop
`manage-stack stop`

Stops the given stack -- this will not cleanup the volumes unless the
stack configuration option `WAVELET_CLEAN_VOLUMES` is set to the value
`yes`.

### manage-stack start
`manage-stack start`

Starts the given stack.

### manage-stack update
`manage-stack update`

Updates the stack using any changed parameters.

### manage-stack restart-wavelet
`manage-stack restart-wavelet`

Restart the wavelet process on all nodes

### manage-stack reset
`manage-stack restart [--hard]`

Restarts (stops, then starts) a given stack.  If `--hard` is specified then the stack's
database volumes are wiped before starting up, even if `WAVELET_CLEAN_VOLUMES` is not
specified as `yes`.

### manage-stack status
`manage-stack status`

Dumps the stack status to stdout.

### manage-stack benchmark
`manage-stack benchmark [<count>]`
`manage-stack nobenchmark`

Starts (or stops, in the case of `nobenchmark`) the benchmarking node.  If `<count>` is specified
the that number of benchmarking nodes will be started, if not specified then one benchmarking
node will be started.

### manage-stack attach
`manage-stack attach <nodeId>`

Attach to the console of the specified node.  Node IDs are numeric to indicate which Wavelet
node to attach to, or can be "`sync`", "`loadbalancer`", or "`benchmark`" to specify that the
"sync" node, the "loadbalancer" node, or the "benchmark" node should be attached to, respectively.

If multiple benchmark nodes are running you can append the "`<nodeId>`" with a dot and index.  For
example:

    manage-stack attach benchmark.2

### manage-stack shell
`manage-stack shell <nodeId> [<cmd...>]`

Execute a command or shell on a given node.  See `manage-stack attach` for the format of the
nodeId parameter.

### manage-stack logs
`manage-stack logs <nodeId> [<args...>]`

Get the logs for a given node.  See `manage-stack attach` for the format of the
nodeId parameter.

### manage-stack debug-wavelet
`manage-stack debug-wavelet <nodeId>`

Attach the "delve" debugger to the wavelet process of a given node.  See `manage-stack attach`
for the format of the nodeId parameter.

### manage-stack config
`manage-stack config`

Dump the configuration for a given stack to stdout.

### manage-stack edit-config
`manage-stack edit-config`

Edits the given stack's configuration using the editor specified by the environment
variable `VISUAL` (defaulting to `vi`).

### manage-stack dump-db
`manage-stack dump-db <nodeId> <outputFile>`

Creates a local tarball named `<outputFile>` with the database configuration of the specific
numeric `<nodeId>`.

### manage-stack cp
`manage-stack cp <src>... <dest>`

Copies files either to or from a remote container.  Only one remote container can be
specified (that is, you cannot copy to AND from a remote container).  Containers are
identified by their nodeId (see `manage-stack attach` for the format of nodeIds).

Example:

    $ manage-stack cp 1:/tmp/test local-test

### manage-stack duplicate-stack
`manage-stack duplicate-stack <newStackName>`

Duplicates the given stack to the specified `<newStackName>`.  This includes the configuration
and database for the current stack.

## build-all-nodes
`build-all-nodes [<stackName>]`

Builds all the node images (`wavelet-stack-lb`, and `wavelet-stack-node`) if needed, and
pushes them to the remote registry.  If a `<stackName>` is provided then the configuration
(`REGISTRY` and `WAVELET_TAG`) for that stack are used to build the images.

That is `REGISTRY/wavelet-stack-lb:latest` will be created from the files in the
`nodes/wavelet-stack-lb` directory and `REGISTRY/wavelet-stack-node:WAVELET_TAG`
will be crated from `REGISTRY/wavelet:WAVELET_TAG` and the files in the
`nodes/wavelet-stack-node` directory.

If `WAVELET_TAG` is not specified it will default to `latest`.

## Examples
### Create a new Swarm

The following example creates a Docker Swarm on 3 newly provisioned Droplets on DigitalOcean.  It prompts
the user for the size of those droplets and which region they will be provisioned in.

```
$ ./manage-swarm create digitalocean demoswarm <apiKey> --size ask --region ask --count 3
Loading...
Please select one of the following for the size:
1) 1gb             6) c-2           11) m-1vcpu-8gb   16) s-2vcpu-2gb
2) 2gb             7) c-4           12) m-2vcpu-16gb  17) s-2vcpu-4gb
3) 4gb             8) g-2vcpu-8gb   13) s-1vcpu-1gb   18) s-3vcpu-1gb
4) 512mb           9) gd-2vcpu-8gb  14) s-1vcpu-2gb   19) s-4vcpu-8gb
5) 8gb            10) m-16gb        15) s-1vcpu-3gb   20) s-6vcpu-16gb
#? 17
Loading...
Please select one of the following for the region:
1) ams3  3) fra1  5) nyc1  7) sfo2  9) tor1
2) blr1  4) lon1  6) nyc3  8) sgp1
#? 5
Creating machine...
Creating machine...
Creating machine...
...
Complete !
$
```

### Create a new Stack

The following example creates a Stack named "`demoswarm-demostack`" on the Swarm named "`demoswarm`".  By default,
Stacks are created on Swarms named before the first dash (`-`).  This can be changed by creating a local stack configuration
in `config/stacks/<stackName>` but every user of the stack will need that local configuration so it is not recommended.

```
$ ./manage-stack -s demoswarm-demostack edit-config
REGISTRY=rkeene
WAVELET_BUILD_DIR=/home/rkeene/devel/perlin-dev/wavelet-clean
WAVELET_REBUILD_ON_START=yes
WAVELET_CLEAN_VOLUMES=no
WAVELET_MEMORY_MAX=2048
WAVELET_NODES=3
WAVELET_NO_RPC=true
WAVELET_SNOWBALL_BETA=150
WAVELET_SNOWBALL_K=2
WAVELET_TAG=benchmark
:wq
$ docker login
$ ./manage-stack -s demoswarm-demostack start
...
Creating network demoswarm-demostack_default
Creating service demoswarm-demostack_wavelet
Creating service demoswarm-demostack_benchmark
Creating service demoswarm-demostack_sync
Creating service demoswarm-demostack_loadbalancer
$ ./manage-stack -s demoswarm-demostack status
demoswarm-demostack (on demoswarm):
  - RUNNING
  - VOLUMES
  - API (main): http://<ip>:30000/
  - API (all): http://<ip>:30001/
  - RPC: disabled
----
ID                  NAME                                 IMAGE                                 NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
than2lo5h0jk        demoswarm-demostack_loadbalancer.1   rkeene/wavelet-stack-lb:latest        demoswarm-2         Running             Running 40 seconds ago
xzlxbn18rvul        demoswarm-demostack_sync.1           elcolio/etcd:latest                   demoswarm-1         Running             Running 47 seconds ago
pj6rx1eznf0g        demoswarm-demostack_wavelet.1        rkeene/wavelet-stack-node:benchmark   demoswarm-2         Running             Running 14 seconds ago
jwbjqznbqyh6        demoswarm-demostack_wavelet.2        rkeene/wavelet-stack-node:benchmark   demoswarm-3         Running             Running 13 seconds ago
khog9vro233v        demoswarm-demostack_wavelet.3        rkeene/wavelet-stack-node:benchmark   demoswarm-1         Running             Running 18 seconds ago
$
```

(n.b., if you see the error "scp: /etc/wavelet-stack/demoswarm-demostack: No such file or directory" when creating your first stack on a swarm, it may be safely ignored.)

### Run a Benchmark

The following example runs a single benchmark instance and then stops it:

```
$ ./manage-stack -s demoswarm-demostack benchmark
demoswarm-demostack_benchmark scaled to 1
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
11:03PM INF Benchmarking... accepted_tps: 0.1942050180078577 downloaded_tps: 0 gossiped_tps: 0 queried_bps: 0.08597350826813725 query_latency_max_ms: 6 query_latency_mean_ms: 0.3055822267509728 query_latency_min_ms: 0 received_tps: 0
11:03PM INF Benchmarking... accepted_tps: 0.28440662295239344 downloaded_tps: 0 gossiped_tps: 0 queried_bps: 0.091853589683795 query_latency_max_ms: 6 query_latency_mean_ms: 0.3169363319066148 query_latency_min_ms: 0 received_tps: 0    
^C
$ ./manage-stack -s demoswarm-demostack nobenchmark
demoswarm-demostack_benchmark scaled to 0
overall progress: 0 out of 0 tasks
verify: Service converged
$ 
```

### Update Wavelet on a Stack

Example 1: Update to include any changes from a local checkout of Wavelet
```
$ ./manage-stack -s demoswarm-demostack edit-config
REGISTRY=rkeene
WAVELET_TAG=benchmark
WAVELET_BUILD_DIR=/home/rkeene/devel/perlin-dev/wavelet-clean
WAVELET_REBUILD_ON_START=yes
...
:wq
$ ( cd /home/rkeene/devel/perlin-dev/wavelet-clean && git update/pull/etc )
$ docker login
$ ./manage-stack -s demoswarm-demostack update
$ ./manage-stack -s demoswarm-demostack status watch
```

Example 2: Update a Stack to run a specific tag -- in this case `perlin/*:v0.3.0`
```
$ ./manage-stack -s demoswarm-demostack edit-config
REGISTRY=perlin
WAVELET_TAG=v0.3.0
WAVELET_BUILD_DIR=/home/rkeene/devel/perlin-dev/wavelet-clean
WAVELET_REBUILD_ON_START=no
...
:wq
$ ./manage-stack -s demoswarm-demostack update
$ ./manage-stack -s demoswarm-demostack status watch
```

Example 3: Create a group of Docker images with a particular tag from a particular source tree
```
$ docker login
$ REGISTRY=perlin \
      WAVELET_TAG=v0.3.0 \
      WAVELET_BUILD_DIR=/home/rkeene/devel/perlin-dev/wavelet-clean \
      ./build-all-nodes
```

### Import an existing Swarm

The following example imports a Swarm by SSH'ing as root the the IP specified and downloading the configuration
into the user's home directory for Docker Machine as well creating `config/swarms/<swarmName>`.  Another user
of the swarm must have previously configured the SSH `~/.ssh/authorized_keys` on the host before it can be imported.

```
$ ./manage-swarm import <ip>
wavelet-swarm.tar.gz                                                                            100%   15KB 244.4KB/s   00:00    
$ ./manage-swarm list
demoswarm
testnet
tradenet
$ ./manage-swarm status demoswarm
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
uq5lc5qh9iahucmlrlz96kudo *   demoswarm-1         Ready               Active              Leader              19.03.5
p61qvckkxyp6cgqs4xvs36c50     demoswarm-2         Ready               Active                                  19.03.5
pm3rzbv5qlzy4l6tpxlqd3b22     demoswarm-3         Ready               Active                                  19.03.5
NAME                  SERVICES            ORCHESTRATOR
demoswarm-demostack   4                   Swarm
$
```

### Create a Geographically Diverse Swarm

The following example creates a Docker Swarm that has Docker hosts in 9 different DigitalOcean regions.
This is useful for testing Wavelet with a wide array of latencies.

```
$ ./manage-swarm create digitalocean bignet <apiKey> --count 1 --region nyc1 --size s-4vcpu-8gb
for region in sgp1 lon1 nyc3 ams3 fra1 tor1 sfo2 blr1; do
        ./manage-swarm expand bignet 1 --region "${region}"
done
```

### Duplicating a Stack

The following example duplicates an existing running Stack's configuration
and database into a new Stack named "`demoswarm-duplistack`"

```
$ ./manage-stack -s demoswarm-demostack duplicate-stack demoswarm-duplistack
...
$ ./manage-stack -s demoswarm-duplistack status
demoswarm-duplistack (on demoswarm):
  - RUNNING
  - VOLUMES
  - API (main): http://<ip>:30097/
  - API (all): http://<ip>:30098/
  - RPC: <ip>:30146
----
ID                  NAME                                  IMAGE                                 NODE                DESIRED STATE       CURRENT STATE                ERROR               PORTS
o57biard8uwu        demoswarm-duplistack_loadbalancer.1   rkeene/wavelet-stack-lb:latest        demoswarm-1         Running             Running about a minute ago
n07rpaayhy6b        demoswarm-duplistack_sync.1           elcolio/etcd:latest                   demoswarm-3         Running             Running about a minute ago
yn3n0fve6fbs        demoswarm-duplistack_wavelet.1        rkeene/wavelet-stack-node:benchmark   demoswarm-3         Running             Running 39 seconds ago
m99xow4evz85        demoswarm-duplistack_wavelet.2        rkeene/wavelet-stack-node:benchmark   demoswarm-2         Running             Running 36 seconds ago
ypq5dk7lv4rf        demoswarm-duplistack_wavelet.3        rkeene/wavelet-stack-node:benchmark   demoswarm-1         Running             Running 37 seconds ago
```

### Rebuilding a Stack from a Backup

The following example recreates a stack from a database backup (taken from `manage-stack dump-db`) and configuration
(taken from `manage-stack config`).

First we make the backup and destroy the existing stack.

```
$ ./manage-stack -s demoswarm-demostack dump-db 1 backups/demo-backup-db.tar.gz
$ ./manage-stack -s demoswarm-demostack config
REGISTRY=rkeene
WAVELET_CLEAN_VOLUMES=no
WAVELET_MEMORY_MAX=2048
WAVELET_NODES=3
WAVELET_NO_RPC=true
WAVELET_SNOWBALL_BETA=150
WAVELET_SNOWBALL_K=2
WAVELET_TAG=benchmark
$ ./manage-stack -s demoswarm-demostack stop
...
Nothing found in stack: demoswarm-demostack
$ ./manage-stack -s demoswarm-demostack cleanVolumes --force
demoswarm-demostack_wavelet_wavelet_db_instance_1
demoswarm-demostack_sync_wavelet_db_instance_1
demoswarm-demostack_wavelet_wavelet_db_instance_2
demoswarm-demostack_wavelet_wavelet_db_instance_3
$
```

Second we rebuild the Stack using the previous configuration:

```
$ ./manage-stack -s demoswarm-copystack edit-config
<Insert Config Here>
### Note the number of nodes, temporarily change it to 1 so we only have
### to upload the DB once
WAVELET_NODES=1
:wq
$ ./manage-stack -s demoswarm-copystack start
Creating network demoswarm-copystack_default
Creating service demoswarm-copystack_benchmark
Creating service demoswarm-copystack_sync
Creating service demoswarm-copystack_loadbalancer
Creating service demoswarm-copystack_wavelet
$ ./manage-stack -s demoswarm-copystack cp backups/demo-backup-db.tar.gz 1:/tmp
$ ./manage-stack -s demoswarm-copystack shell 1
bash-4.4# cd /db
bash-4.4# ls
000001.log       CURRENT          LOCK             LOG              MANIFEST-000000
bash-4.4# mkdir x
bash-4.4# cd x
bash-4.4# gzip -dc /tmp/demo-backup-db.tar.gz | tar -xf -
bash-4.4# cd ..
bash-4.4# rm -f *; mv x/* .; rmdir x; pkill -9 -x /wavelet
rm: 'x' is a directory
bash-4.4# ls
000003.ldb       000005.log       CURRENT.bak      LOG
000004.ldb       CURRENT          LOCK             MANIFEST-000006
bash-4.4# exit
$ ./manage-stack -s demoswarm-copystack edit-config
<Exiting Config Here>
WAVELET_NODES=<NumberOfNodesFromPreviousStep>
:wq
$ ./manage-stack -s demoswarm-copystack update
Updating service demoswarm-copystack_benchmark (id: w8gin0o6aeisap86hsyagjrcy)
Updating service demoswarm-copystack_sync (id: yx3quhjpukhosmzgn3rp2m82i)
Updating service demoswarm-copystack_loadbalancer (id: nnbvghcw4rhr8sy4tqenlel5k)
Updating service demoswarm-copystack_wavelet (id: qqgh8663rgt0q1k9gvl1alu1d)
$ ./manage-stack -s demoswarm-copystack attach 1
l
11:31PM INF Here is the current status of your node. balance: 9999999999999529446 block_height: 48 block_id: 0552dc9c6b4141d2f8e257cfd6da134cfea9d26995e87dfc0040688c7ea437ce client_block: 48 num_accounts_in_store: 0 num_missing_tx: 0 num_tx: 0 num_tx_in_store: 0 peers: ["10.0.3.14:3001[68a5f19ea9c5e1e61836a189175a159f36dc273c07eb9e58448b3529957e3218]","10.0.3.15:3002[ce55ce8e451272e042683766f02165b8ca18ce1aa989c77f48b87ff4fc29fcfa]"] preferred_block_id: N/A preferred_votes: 0 reward: 268888 stake: 201666 sync_status: "Node is fully synced" user_id: e919a3626df31b6114ec79567726e9a31c600a5d192e871de1b862412ae8e4c0     
```

## Theory of Operation
### Introduction
The two main components of this suite of tools are:
  1. `manage-swarm`
  2. `manage-stack`

### `manage-swarm`
Manage Swarm is relatively simple and creates, destroys, imports, modifies, or examines a [Docker Swarm](https://docs.docker.com/engine/swarm/) on
external providers using [Docker Machine](https://docs.docker.com/machine/).

Currently there is only one provider:
  1. `digitalocean`
  
Further providers can be added by modifying `manage-swarm` to add the following functions named after that provider:
  1. `create_<provider>()` which must create new Docker Swarm nodes, including a master, on the specified provider using `docker-machine` and join them to the same Docker Swarm using the commands returned by "`docker swarm init`" command run on the master node.
  2. `expand_<provider>()` which must create new Docker Swarm nodes on the specified provider using `docker-machine` and join them to an existing Swarm

The Docker Machine configuration is stored on every host in the Swarm, which can then be used to import the Swarm onto new systems
using the `manage-swarm import` command.

The IP of any host in the swarm can be used with the `manage-swarm import` command.
The `manage-swarm import` command will SSH into the IP specified and download the swarm configuration into the user's Docker Machine
directory as well as place the Docker Machine information into `config/swarms/<swarmName>` so that the swarm can be used by
`manage-stack` when appropriate.

Swarms may also be destroyed using `manage-swarm destroy`, which uses `docker-machine` to deprovision the backing virtual machines
and releases all resources.  This should be used with care.

### `manage-stack`
The main utility in this suite is called `manage-stack` and it can create, configure, reconfigure, start, stop, update, attach,
and various other actions to a Wavelet Stack.  A Wavelet Stack is a [Docker Stack](https://docs.docker.com/engine/reference/commandline/stack/)
for running [Wavelet](https://github.com/perlin/wavelet/) in a managed way on a [Docker Swarm](https://docs.docker.com/engine/swarm/).  It
handles things like gracefully upgrading between releases based on [Docker Images](https://docs.docker.com/engine/reference/commandline/images/),
extending the number of Wavelet instances in a cluster, ensuring that nodes within a Wavelet cluster are communicating with
each other, and configuring services so that the cluster can be accessed externally via either the HTTP/HTTPS API or via the
gRPC RPC interface.

The main components of a Wavelet Stack are:
   1. loadbalancer
   2. sync
   3. wavelet
   4. benchmark
   
The definition for these services within the Docker Stack live in the [docker-compose.yml](https://docs.docker.com/compose/compose-file/) file
in the top-level directory for `wavelet-stack`.

The `loadbalancer` node is a container running HAProxy that acts as the frontend for all communications to the cluster.  It
then proxies requests to the correct destination.

The `sync` node is a container based on etcd that acts as a way for the Wavelet nodes to advertise their address and port
to each other as well as to the `loadbalancer` node.

The `wavelet` node is a container that runs Wavelet.  It reaches out to the `sync` node to register the RPC port it will listen
on as well as pulls in from the `sync` node the RPC IP and RPC port that are exposed externally, as these need to be specified
by the listening node.  Many instances of this container may be run in a stack and they will coordinate (via the `sync` node)
their activities to ensure that they are communicating.

The `benchmark` node is a container that runs the `benchmark` command from Wavelet.  Many instaces of this node may be run
simultaneously and they will each interact with a different Wavelet instance from the `wavelet` component over the HTTP API.

Stack configuration is managed as a set of key-value pairs, identified in an early section.  The stack configuration file is kept
on the Swarm host in the `/etc` directory.  This is so that the configuration may be shared among multiple users of a stack.

Once a configuration for a stack has been created (refer to examples and references above) using the `manage-stack edit-config`
command the stack may be started using the `manage-stack start` command.

If the configuration is updated, again using the `manage-stack edit-config` command, the `manage-stack update` command may be
used.  Both `start` and `update` perform the same action and they are synonyms.

Wavelet instances store their data in [Docker Volumes](https://docs.docker.com/storage/volumes/) which are backed by host storage.
Each instance in a stack gets their own volume.  As long as the stack and host are running, Docker maintains an affinity for
the container on the host holding its storage so nodes will be restarted attached to their database when updating.  If the
container is stopped (e.g., using `manage-stack stop` or `manage-stack reset`) then this affinity is lost and when the node
containers are restarted they may not be on the same host and thus may not get the same volume as before they were stopped or
reset.  To avoid this case it is usually best to avoid using `manage-stack stop` or `manage-stack reset` unless the data
is no longer needed.

By default the volumes are not deleted when the Wavelet Stack is stopped.  This behavior can be changed by setting the
`WAVELET_CLEAN_VOLUMES` variable to a true value in the stack configuration.  Volumes will also be removed when using
`manage-stack reset --hard`.  Volumes can also be manually cleaned up for a stopped stack using the command
`manage-stack cleanVolumes --force`.
