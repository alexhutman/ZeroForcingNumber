import itertools

from cython.operator import dereference, preincrement
from libcpp.vector cimport vector
from libcpp.unordered_set cimport unordered_set

from sage.data_structures.bitset cimport (
    Bitset,
    FrozenBitset
)

from sage.data_structures.bitset_base cimport (
    bitset_add,
    bitset_clear,
    bitset_copy,
    bitset_difference,
    bitset_free,
    bitset_in,
    bitset_init,
    bitset_intersection,
    bitset_isempty,
    bitset_issubset,
    bitset_len,
    bitset_next,
    bitset_pop,
    bitset_remove,
    bitset_t,
    bitset_union
)

from sage.graphs.base.c_graph cimport CGraphBackend

from cpython.mem cimport (
    PyMem_Malloc,
    PyMem_Free
)

from zeroforcing.fastqueue cimport FastQueueForBFS, Node, NodePrio

cdef extern from "stdint.h":
    cdef size_t SIZE_MAX

cdef class ExtendClosureBitsets:
    def __cinit__(self, size_t num_vertices):
        # TODO: Figure out how to have less verbosity here?
        bitset_init(self.initially_filled_subset, num_vertices)
        bitset_init(self.vxs_to_add, num_vertices)
        bitset_init(self.filled_set, num_vertices)
        bitset_init(self.vertices_to_check, num_vertices)
        bitset_init(self.vertices_to_recheck, num_vertices)
        bitset_init(self.filled_neighbors, num_vertices)
        bitset_init(self.unfilled_neighbors, num_vertices)
        bitset_init(self.filled_neighbors_of_vx_to_fill, num_vertices)

    def __dealloc__(self):
        bitset_free(self.initially_filled_subset)
        bitset_free(self.vxs_to_add)
        bitset_free(self.filled_set)
        bitset_free(self.vertices_to_check)
        bitset_free(self.vertices_to_recheck)
        bitset_free(self.filled_neighbors)
        bitset_free(self.unfilled_neighbors)
        bitset_free(self.filled_neighbors_of_vx_to_fill)

    cdef void clear_all(self):
        bitset_clear(self.initially_filled_subset)
        bitset_clear(self.vxs_to_add)
        bitset_clear(self.filled_set)
        bitset_clear(self.vertices_to_check)
        bitset_clear(self.vertices_to_recheck)
        bitset_clear(self.filled_neighbors)
        bitset_clear(self.unfilled_neighbors)
        bitset_clear(self.filled_neighbors_of_vx_to_fill)


cdef class ZFSearchMetagraph:
    def __cinit__(self, object graph_for_zero_forcing not None):
        self.num_vertices = (<CGraphBackend>graph_for_zero_forcing._backend).cg().num_verts
        self.ec_bitsets = ExtendClosureBitsets(self.num_vertices)
        self.neighborhood_array = <bitset_t*> PyMem_Malloc(self.num_vertices*sizeof(bitset_t))

        #TODO: RENAME
        self.neighbors_dict = <bitset_t*> PyMem_Malloc(self.num_vertices*sizeof(bitset_t))
        self.closed_neighborhood_list = <bitset_t*> PyMem_Malloc(self.num_vertices*sizeof(bitset_t))

        if not self.neighborhood_array:
            raise MemoryError("Could not allocate neighborhood array")
        if not self.neighbors_dict:
            raise MemoryError("Could not allocate neighbors_dict")
        if not self.closed_neighborhood_list:
            raise MemoryError("Could not allocate closed_neighborhood_list")

        for vertex in range(self.num_vertices):
            bitset_init(self.neighborhood_array[vertex], self.num_vertices)
            bitset_init(self.neighbors_dict[vertex], self.num_vertices)
            bitset_init(self.closed_neighborhood_list[vertex], self.num_vertices)

    def __dealloc__(self):
        for vertex in range(self.num_vertices):
            bitset_free(self.neighborhood_array[vertex])
            bitset_free(self.neighbors_dict[vertex])
            bitset_free(self.closed_neighborhood_list[vertex])
        PyMem_Free(self.neighborhood_array)
        PyMem_Free(self.neighbors_dict)
        PyMem_Free(self.closed_neighborhood_list)

    def __init__(self, graph_for_zero_forcing not None):
        graph_copy = graph_for_zero_forcing.copy(immutable=False)
        self.orig_to_relabeled_verts = graph_copy.relabel(inplace=True, return_map=True)
        self.relabeled_to_orig_verts = {v: k for k,v in self.orig_to_relabeled_verts.items()}
        
        self.vertices_set = set(graph_copy.vertices(sort=False))
        self.initialize_neighbors(graph_copy)
        self.initialize_neighborhood_array(graph_copy)

    cdef void initialize_neighbors(self, graph_copy):
        cdef size_t i, neighbor
        for i in self.vertices_set:
            #TODO: Only so Dijkstra code doesn't break. Ideally want to remove this somehow
            neighbors = graph_copy.neighbors(i)

            for neighbor in neighbors:
                bitset_add(self.neighbors_dict[i], neighbor)
            bitset_copy(self.closed_neighborhood_list[i], self.neighbors_dict[i])
            bitset_add(self.closed_neighborhood_list[i], i)

    cdef void initialize_neighborhood_array(self, graph_copy):
        cdef size_t vertex, neighbor
        for vertex in range(self.num_vertices):
            for neighbor in graph_copy.neighbor_iterator(vertex):
                bitset_add(self.neighborhood_array[vertex], neighbor)

    cdef FrozenBitset extend_closure(self, bitset_t initially_filled_subset, bitset_t vxs_to_add):
        self.ec_bitsets.clear_all()

        bitset_copy(self.ec_bitsets.initially_filled_subset, initially_filled_subset)
        bitset_copy(self.ec_bitsets.vxs_to_add, vxs_to_add)

        bitset_copy(self.ec_bitsets.vertices_to_check, self.ec_bitsets.vxs_to_add)

        bitset_union(self.ec_bitsets.filled_set, self.ec_bitsets.initially_filled_subset, self.ec_bitsets.vxs_to_add)
        for v in range(self.num_vertices):
            if bitset_in(self.ec_bitsets.vxs_to_add, v):
                bitset_intersection(self.ec_bitsets.filled_neighbors, self.neighborhood_array[v], self.ec_bitsets.filled_set)
                bitset_union(self.ec_bitsets.vertices_to_check, self.ec_bitsets.vertices_to_check, self.ec_bitsets.filled_neighbors)
            
        bitset_clear(self.ec_bitsets.vertices_to_recheck)
        while not bitset_isempty(self.ec_bitsets.vertices_to_check):
            bitset_clear(self.ec_bitsets.vertices_to_recheck)
            for vertex in range(self.num_vertices):
                if bitset_in(self.ec_bitsets.vertices_to_check, vertex):
                    bitset_intersection(self.ec_bitsets.filled_neighbors, self.neighborhood_array[vertex], self.ec_bitsets.filled_set)
                    bitset_difference(self.ec_bitsets.unfilled_neighbors, self.neighborhood_array[vertex], self.ec_bitsets.filled_neighbors)
                    
                    if bitset_len(self.ec_bitsets.unfilled_neighbors) == 1:
                        self.vertex_to_fill = bitset_next(self.ec_bitsets.unfilled_neighbors, 0)
                        bitset_add(self.ec_bitsets.vertices_to_recheck, self.vertex_to_fill)
                        
                        bitset_intersection(self.ec_bitsets.filled_neighbors_of_vx_to_fill, self.neighborhood_array[self.vertex_to_fill], self.ec_bitsets.filled_set)
                        bitset_remove(self.ec_bitsets.filled_neighbors_of_vx_to_fill, vertex)
                        bitset_union(self.ec_bitsets.vertices_to_recheck, self.ec_bitsets.vertices_to_recheck, self.ec_bitsets.filled_neighbors_of_vx_to_fill)
                        
                        bitset_add(self.ec_bitsets.filled_set, self.vertex_to_fill)
            bitset_copy(self.ec_bitsets.vertices_to_check, self.ec_bitsets.vertices_to_recheck)

        set_to_return = FrozenBitset(capacity=self.num_vertices)
        bitset_copy(set_to_return._bitset, self.ec_bitsets.filled_set)
        return set_to_return
    

    #cdef void neighbors_with_edges_add_to_queue(self, FastQueueForBFS queue, FrozenBitset meta_vertex, size_t previous_cost):
    cdef void neighbors_with_edges_add_to_queue(self, FastQueueForBFS queue, Node metavertex):
        # verify that 'meta_vertex' is actually a subset of the vertices
        # of self.primal_graph, to be interpreted as the filled subset
        cdef size_t new_vx_to_make_force, cost, i, num_unfilled_neighbors

        for new_vx_to_make_force in self.vertices_set:
            bitset_copy(self.ec_bitsets.unfilled_neighbors, self.neighborhood_array[new_vx_to_make_force])
            bitset_difference(self.ec_bitsets.unfilled_neighbors, self.ec_bitsets.unfilled_neighbors, metavertex.second)
            num_unfilled_neighbors = bitset_len(self.ec_bitsets.unfilled_neighbors)

            cost = num_unfilled_neighbors
            if num_unfilled_neighbors > 0:
                cost -= 1

            if not bitset_in(metavertex.second, new_vx_to_make_force):
                cost += 1

            if cost > 0:
                metavertex.first = new_vx_to_make_force
                queue.push(NodePrio(metavertex.first + cost, metavertex))

    @staticmethod
    cdef void shortest(FrozenBitset start, FrozenBitset end, vector[Node] path_so_far, DijkstraDict predecessor_list):
        # Modifies path_so_far in-place

        cdef Node predecessor = predecessor_list[end._bitset]
        path_so_far.push_back(predecessor)
        
        while predecessor.second != start._bitset:
            predecessor = predecessor_list[predecessor.second]
            path_so_far.push_back(predecessor)
        # Remember to traverse path_so_far backwards!

    cdef unordered_set[size_t] build_zf_set(self, vector[Node] final_metavx_list):
        # Modifies zf_set in-place
        final_metavx_list.pop_back() #Do not need to do the last metavertex (everything is already filled)

        cdef:
            Node metavertex
            vector[Node].reverse_iterator it = final_metavx_list.rbegin()
            vector[Node].reverse_iterator end = final_metavx_list.rend()
    
        cdef bitset_t zf_set
        while it != end:
            metavertex = <Node>dereference(it)
            if not bitset_in(metavertex.second, metavertex.first): #If filled, don't need to add it to zf_set since it will already have been gotten for free
                bitset_add(zf_set, metavertex.first)

            zf_set = self.neighbors_dict[metavertex.first]
            bitset_difference(zf_set, zf_set, metavertex.second) #Find n unfilled neighbors of forcing vertex
        
            if bitset_len(zf_set) > 1:
                bitset_pop(zf_set) #Pick n-1 of them, the last will be gotten for free
            preincrement(it)

        cdef unordered_set[size_t] da_set
        while not bitset_isempty(zf_set):
            da_set.insert(bitset_pop(zf_set))
        return da_set

    cpdef set dijkstra(self, frozenset start, frozenset target):
        cdef:
            size_t current_distance
            Node unvisited_metavx

        cdef:
            FastQueueForBFS unvisited_queue = FastQueueForBFS()
            FrozenBitset start_metavertex = FrozenBitset(start, capacity=self.num_vertices)
            FrozenBitset target_metavertex = FrozenBitset(target, capacity=self.num_vertices)
            # Start us off
            bitset_t current = start_metavertex._bitset

            #TODO: REPLACE WITH UNORDERED MAP UGHGHHGHGHGH
            DijkstraDict previous
                    #current: (start_metavertex, None)

        previous[current] = Node(SIZE_MAX, start_metavertex._bitset) # SIZE_MAX is arbitrary, we break when we find start
        self.neighbors_with_edges_add_to_queue(unvisited_queue, Node(0, current))
        cdef NodePrio node_p
        while current != target_metavertex._bitset:
            #current_distance, unvisited_metavx = unvisited_queue.pop_and_get_priority()
            node_p = unvisited_queue.pop_and_get_priority()
            unvisited_metavx = node_p.second
            #parent, vx_to_force = unvisited_metavx # Previous closure, added vertex

            current = self.extend_closure(unvisited_metavx.second, self.closed_neighborhood_list[unvisited_metavx.first])._bitset
            if previous.count(current):
                continue

            previous[current] = unvisited_metavx
            unvisited_metavx.second = current
            self.neighbors_with_edges_add_to_queue(unvisited_queue, unvisited_metavx)
                
        # Can this be simpler by making this a linked list instead? It would be more like a graph imo
        cdef vector[Node] shortest_path
        shortest_path.push_back(Node(SIZE_MAX, target_metavertex._bitset))
        ZFSearchMetagraph.shortest(start_metavertex, target_metavertex, shortest_path, previous)

        zf_set_with_old_labels = map(self.to_orig_vertex, self.build_zf_set(shortest_path))
        return set(zf_set_with_old_labels)

    # TODO: Get rid of this crap, only have user call in terms of original vertices
    cpdef frozenset to_orig_metavertex(self, object relabeled_metavertex_iter):
        return frozenset(self.__to_orig_metavertex_iter(relabeled_metavertex_iter))

    cpdef frozenset to_relabeled_metavertex(self, object orig_vertex_iter):
        return frozenset(self.__to_relabeled_metavertex_iter(orig_vertex_iter))

    cpdef object to_orig_vertex(self, size_t relabeled_vertex):
        return self.relabeled_to_orig_verts[relabeled_vertex]

    cpdef size_t to_relabeled_vertex(self, object orig_vertex):
        return self.orig_to_relabeled_verts[orig_vertex]

    cdef object __to_orig_metavertex_iter(self, object relabeled_metavertex_iter):
        return map(self.to_orig_vertex, relabeled_metavertex_iter)

    cdef object __to_relabeled_metavertex_iter(self, object orig_vertex_iter):
        return map(self.to_relabeled_vertex, orig_vertex_iter)

