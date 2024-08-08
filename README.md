# zeroforcing

### Purpose.

This software provides very fast calculation of zero forcing parameters.  Currently, it is able to compute only the “original” zero forcing parameter, namely the **zero forcing number of a finite simple graph**, originally defined by the “Special Graphs Working Group” that formed during a workshop at the American Institute of Mathematics (AIM) in 2006 in:

<ul>
AIM Minimum Rank – Special Graphs Work Group. Zero forcing sets and the minimum rank of graphs. <i>Linear Algebra and its Applications</i>, 428(7):1628–1648 (2008). (<a href="https://doi.org/10.1016/j.laa.2007.10.009">https://doi.org/10.1016/j.laa.2007.10.009</a>)
</ul>

### Definition.

Given a finite graph, choose some vertices to be “filled” and then apply this rule repeatedly until it cannot be applied further: If any filled vertex has exactly one unfilled neighbor, then that neighbor becomes filled.  (We say that the first vertex “forces” its neighbor.)  The smallest number of vertices that can be initially filled so that all vertices become filled eventually is the **zero forcing number** of the graph.

### Method.

The algorithm applied finds the least weight of a path in a directed, weighted “metagraph” in which each vertex represents a subset of vertices in the primal graph *G* (the one whose zero forcing number is desired) with the property that, when this subset is precisely the set of filled vertices, no vertex can force.  An arc of weight *w* is present from *X* to *Y* when it is possible to add *w* vertices to the initially filled set that produced *X* to obtain an initially filled set that produces *Y*.  (That is, it is possible to expand the size of the ultimately filled set from *X* to *Y* at the “cost” of filling *w* additional vertices at the beginning.)  Then the smallest total weight of a directed path from &empty; to *V(G)* in this metagraph is the zero forcing number of *G*.

### Capabilities and limitations.

The software is able to compute the zero forcing number very efficiently for most simple graphs.  Some graphs, such as stars, represent a weakness for the algorithm and may produce longer running times.  In addition, memory usage can be prodigious for very large graphs.  Steps are planned to address both of these limitations in the future.  For now, the algorithm is very quick for most graphs.  For example, for the Paley graph on 101 vertices, it is possible to compute the zero forcing number in a matter of seconds.

---

## Usage:
### Build:
`sage --python3 setup.py build_ext`

### Test:
`sage --python3 -m pytest [-x]`
* `-x` flag makes pytest stop after the first failure
* `-h` flag will show a section called `Zero forcing options:`

### Clean:
`sage --python3 setup.py clean`

### Help:
`sage --python3 setup.py -h`
(You can also use the `-h` flag in subcommands. i.e. `sage --python3 setup.py build_ext -h`

## Running in Docker
1. Download Docker from the [Docker website](https://www.docker.com/)
2. Run `docker build -t zeroforcing .` in the directory this git repository is located in
    * You can specify `--build-arg ZF_BUILD_ARGS="--debug"` before the `-t` flag to build in debug mode
3. Run `docker run --rm -it zeroforcing`
4. Follow the "Usage" section
