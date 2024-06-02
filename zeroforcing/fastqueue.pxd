from libcpp.pair cimport pair
from libcpp.deque cimport deque
from libcpp.unordered_map cimport unordered_map
#from libcpp.map cimport map as cppmap
from sage.data_structures.bitset_base cimport bitset_t, bitset_s

#ctypedef public bitset_t CythonBitsetT
ctypedef public bitset_s CythonBitsetS

#cdef public class Test(object)[type ClassType, object ClassObj]:
    #cdef bitset_t jef

#cdef extern from "test.h":
#cdef extern from "fastqueue.h":
cdef extern from *:
    #cdef bitset_t& operator=(bitset_t&& other):
        #return other
    #cdef CppNode& operator=(const CppNode&)
    #cdef CppNodePrio& operator=(const CppNodePrio&)
    cdef cppclass WrappedCppBitsetT:
        WrappedCppBitsetT() except +
        WrappedCppBitsetT& operator=(const WrappedCppBitsetT&)
        #CppBitsetT& operator=(const CppBitsetT&)

#####ctypedef pair[size_t, CppBitsetT] Node # vx_to_make_force, forced_metavx

#ctypedef pair[size_t, bitset_t] Node # vx_to_make_force, forced_metavx

#####ctypedef pair[size_t, Node] NodePrio # prio, Node

#ctypedef public pair[size_t, CppBitset] CppNode
#ctypedef public Node CppNode
#ctypedef public NodePrio CppNodePrio

#ctypedef vector[Node] QueueAtPrio # TODO: try deque too

#####ctypedef deque[Node] QueueAtPrio
#####ctypedef unordered_map[size_t, QueueAtPrio] Queue

#ctypedef cppmap[size_t, QueueAtPrio] Queue

"""
cdef class Testerson:
    cdef WrappedCppBitsetT bts

cdef class FastQueueForBFS:
    cdef:
        Queue queue
        list priority_heap

        void push(self, NodePrio)
        #Node pop(self)
        NodePrio pop_and_get_priority(self)
"""
