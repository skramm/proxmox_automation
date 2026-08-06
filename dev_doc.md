# Development notes

 (WIP)
 
## Variables
- `NB_NODES`: holds the number of nodes, set from the number of lines of file `data_nodes.csv`
- `TAGAARR`: associative array holding the number of VM and templates for a given tag
- `TAGARR`: array holding all the tags
- `GROUPARR`:
- `DO_MIGRATE`: set to 'Y' (true) at the top, so that the created VM are evenly distributed on all the nodes of the cluster

## Functions

- `FetchData()`: gathers all the information on the cluster.
Calls `ProcessNode()` on each node.
- `ApiCall`: does the HTTP API call through `curl`

