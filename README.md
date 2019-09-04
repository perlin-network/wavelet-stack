# Wavelet Stack and Swarm Manager
## Introduction
Wavelet Stack and Swarm manager lets you run Wavelet Stacks on
Docker Swarms.  Additionally, it helps manage Docker swarms using
Docker Machine.

There are three provided tools:

    1. `manage-swarm` - Manage Docker Swarm instances
    2. `manage-stack` - Manage Wavelet Stack on a Docker Swarm
    3. `build-all-nodes` - Builds all the nodes required to run a stack

## manage-swarm
The `manage-swarm` tool helps create and manage remote Docker swarms using
Docker Machine.

### manage-swarm create
`manage-swarm create <provider> <swarmName> ...

Creates a new Swarm.  Currently the only provider supported is
digitalocean.

### manage-swarm import
`manage-swarm import <ip>`

Import the configuration for a swarm by SSHing into one of the machines
managed.

### manage-swarm destroy
`manage-swarm destroy <swarmName>`

Destroy a swarm -- USE WITH EXTREME CAUTION.

### manage-swarm status <swarmName>
`manage-swarm status <swarmName>`

Get the status of a swarm.

### manage-swarm list
`manage-swarm list`

List known swarms.

## manage-stack
The `manage-stack` tool is the most useful tool.  It helps manage a specified
stack.

Stack configurations are stored in `./config/stacks/` locally, or in `/etc/wavelet-stack`
on the Docker Machine host if using a remote Swarm.

Configuration options are:

    1. `REGISTRY` - Docker Registry to use (defaults to `localhost:5000`)
    3. `WAVELET\_GENESIS` - Wavelet Genesis block descriptor
    4. `WAVELET\_KEYS` - CSV list of private keys and public keys
    5. `WAVELET\_NODES` - Number of Wavelet nodes to run (defaults to `3`)
    6. `WAVELET\_RICH\_WALLETS` - Number of Rich wallets to create if generating the Genesis block (that is, if `WAVELET\_GENEISIS` is not supplied; defaults to `3`)
    7. `WAVELET\_SNOWBALL\_K` - Wavelet Snowball K
    8. `WAVELET\_SNOWBALL\_BETA` - Wavelet Snowball Beta
    9. `WAVELET\_MEMORY\_MAX` - Max amount of memory to terminate the node after
    10. `WAVELET\_NO\_RPC` - Boolean to indicate whether not RPC ports are exposed
    11. `WAVELET\_TAG` - Tag of the wavelet image to pull down (defaults to `latest`)
    12. `WAVELET\_CLEAN\_VOLUMES` - Boolean to indicate whether or not the volumes are removed on `stop`

```
Usage: manage-stack [-s <stackName>] {stop|start|update|restart|status}
       manage-stack [-s <stackName>] {benchmark|nobenchmark}
       manage-stack [-s <stackName>] {attach|shell|logs} <nodeId>
       manage-stack [-s <stackName>] {config|edit-config}
       manage-stack [-s <stackName>] dump-db <nodeId> <outputFile>
       manage-stack [-s <stackName>] duplicate-stack <newStackName>
```

### manage-stack stop
`manage-stack stop`

Stops the given stack -- this will not cleanup the volumes unless the
stack configuration option `WAVELET\_CLEAN\_VOLUMES` is set to the value
`yes`.

### manage-stack start
`manage-stack start`

Starts the given stack.

### manage-stack update
`manage-stack update`

Updates the stack using any changed parameters.

### manage-stack restart
`manage-stack restart [--hard]`

Restarts (stops, then starts) a given stack.  If `--hard` is specified then the stack's
database volumes are wiped before starting up, even if `WAVELET_CLEAN_VOLUMES` is not
specified as `yes`.

### manage-stack status
`manage-stack status`

Dumps the stack status to stdout.

### manage-stack benchmark
`manage-stack benchmark`
`manage-stack nobenchmark`

Starts (or stops, in the case of `nobenchmark`) the benchmarking node.

### manage-stack attach
`manage-stack attach <nodeId>`

Attach to the console of the specified node.  Node IDs are numeric to indicate which Wavelet
node to attach to, or can be "`sync`" or "`loadbalancer`" to specify that the "sync" node or
"loadbalancer" node should be attached to, respectively.

### manage-stack shell
`manage-stack shell <nodeId> [<cmd...>]`

Execute a command or shell on a given node.  See `manage-stack attach` for the format of the
nodeId parameter.

### manage-stack logs
`manage-stack logs <nodeId> [<args...>]`

Get the logs for a given node.  See `manage-stack attach` for the format of the
nodeId parameter.

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

### manage-stack duplicate-stack
`manage-stack duplicate-stack <newStackName>`

Duplicates the given stack to the specified `<newStackName>`.  This includes the configuration
and database for the current stack.
