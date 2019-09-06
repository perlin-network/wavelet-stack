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
  2. `WAVELET_GENESIS` - Wavelet Genesis block descriptor
  3. `WAVELET_KEYS` - CSV list of private keys and public keys
  4. `WAVELET_NODES` - Number of Wavelet nodes to run (defaults to `3`)
  5. `WAVELET_RICH_WALLETS` - Number of Rich wallets to create if generating the Genesis block (that is, if `WAVELET_GENEISIS` is not supplied; defaults to `3`)
  6. `WAVELET_SNOWBALL_K` - Wavelet Snowball K
  7. `WAVELET_SNOWBALL_BETA` - Wavelet Snowball Beta
  8. `WAVELET_MEMORY_MAX` - Max amount of memory to terminate the node after
  9. `WAVELET_NO_RPC` - Boolean to indicate whether not RPC ports are exposed
  10. `WAVELET_TAG` - Tag of the wavelet image to pull down (defaults to `latest`)
  11. `WAVELET_CLEAN_VOLUMES` - Boolean to indicate whether or not the volumes are removed on `stop`
  12. `WAVELET_API_HOST` - Hostname, if supplied, HTTPS support is enabled on port 443/tcp
  13. `WAVELET_API_ACME_ACCOUNT_KEY` - PEM encoded ACME account key for autocert.  Generally if `WAVELET_API_HOST` is provided, this should be provided also.
  14. `WAVELET_BACKUP_DB` - Boolean to indicate whether database backups are automatically taken for wavelet nodes

```
Usage: manage-stack [-s <stackName>] {stop|start|update|restart|status}
       manage-stack [-s <stackName>] {benchmark|nobenchmark}
       manage-stack [-s <stackName>] {attach|shell|logs} <nodeId>
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
