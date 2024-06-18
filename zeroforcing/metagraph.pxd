from sage.data_structures.bitset cimport Bitset, FrozenBitset
from sage.data_structures.bitset_base cimport bitset_s
from libcpp.unordered_map cimport unordered_map
#from libcpp.map cimport map as cppmap
from libcpp.unordered_set cimport unordered_set
from libcpp.vector cimport vector

from zeroforcing.fastqueue cimport FastQueueForBFS, Node


ctypedef unordered_map[bitset_s, Node] DijkstraDict
#ctypedef cppmap[bitset_s, Node] DijkstraDict

cdef class ExtendClosureBitsets:
    cdef:
        bitset_s initially_filled_subset
        bitset_s vxs_to_add
        bitset_s filled_set
        bitset_s vertices_to_check
        bitset_s vertices_to_recheck
        bitset_s filled_neighbors
        bitset_s unfilled_neighbors
        bitset_s filled_neighbors_of_vx_to_fill

        void clear_all(self)

cdef class ZFSearchMetagraph:
    @staticmethod
    cdef void shortest(FrozenBitset, FrozenBitset, vector[Node], DijkstraDict)

    cdef:
        size_t num_vertices, vertex_to_fill
        #dict orig_to_relabeled_verts, relabeled_to_orig_verts
        set vertices_set
        bitset_s *neighborhood_array
        bitset_s *neighbors_dict
        bitset_s *closed_neighborhood_list
        ExtendClosureBitsets ec_bitsets

        void initialize_neighbors(self, object)
        void initialize_neighborhood_array(self, object)
        FrozenBitset extend_closure(self, bitset_s, bitset_s)
        void neighbors_with_edges_add_to_queue(self, FastQueueForBFS, Node)
        unordered_set[size_t] build_zf_set(self, vector[Node])

        object __to_orig_metavertex_iter(self, object)
        object __to_relabeled_metavertex_iter(self, object)

    cpdef set dijkstra(self, frozenset, frozenset)

    cpdef frozenset to_orig_metavertex(self, object)
    cpdef frozenset to_relabeled_metavertex(self, object)
    cpdef object to_orig_vertex(self, size_t)
    cpdef size_t to_relabeled_vertex(self, object)
