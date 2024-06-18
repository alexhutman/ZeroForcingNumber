from libcpp.pair cimport pair
from libcpp.deque cimport deque
from libcpp.unordered_map cimport unordered_map

from sage.data_structures.bitset_base cimport bitset_s


ctypedef pair[size_t, bitset_s] Node # vx_to_make_force, forced_metavx
ctypedef pair[size_t, Node] NodePrio # prio, Node
ctypedef deque[Node] QueueAtPrio
ctypedef unordered_map[size_t, QueueAtPrio] Queue

cdef class FastQueueForBFS:
    cdef:
        Queue queue
        list priority_heap

        void push(self, NodePrio)
        NodePrio pop_and_get_priority(self)
