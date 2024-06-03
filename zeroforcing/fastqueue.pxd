from libcpp.pair cimport pair
from libcpp.deque cimport deque
from libcpp.unordered_map cimport unordered_map
#from libcpp.map cimport map as cppmap
from sage.data_structures.bitset_base cimport bitset_t, bitset_s

#ctypedef public bitset_t CythonBitsetT
#ctypedef public bitset_s CythonBitsetS

#cdef public class Test(object)[type ClassType, object ClassObj]:
    #cdef bitset_t jef

#cdef extern from "test.h":
#cdef extern from "fastqueue.h":
cdef extern from *:
    r"""
    #include <iostream>

    #include "gmp.h"

    struct CppBitsetS {
        mp_bitcnt_t size;
        mp_size_t limbs;
        mp_limb_t *bits;
    };

    class WrappedCppBitsetT {
        private:
            CppBitsetS *rawbts;
        public:
            WrappedCppBitsetT();
            WrappedCppBitsetT(const WrappedCppBitsetT&);
    };

    WrappedCppBitsetT::WrappedCppBitsetT() : rawbts() {
        std::cout << "Constructing WrappedCppBitsetT\n";
    }

    WrappedCppBitsetT::WrappedCppBitsetT(size_t capacity) : rawbts() {
        std::cout << "Constructing WrappedCppBitsetT with capacity " << capacity << "\n";

        // TODO: Somehow call bitset_init()...
    }

    WrappedCppBitsetT::~WrappedCppBitsetT() {
        std::cout << "Destructing WrappedCppBitsetT\n";
        
        // TODO: Somehow call bitset_free()...
    }

    // Copy constructor
    WrappedCppBitsetT::WrappedCppBitsetT(const WrappedCppBitsetT& src) : rawbts() {
        std::cout << "Copy constructing WrappedCppBitsetT\n";
        this->rawbts->size = src.rawbts->size;
        this->rawbts->limbs = src.rawbts->limbs;

        // TODO: Loop through limbs, create new limb, and copy
        this->rawbts->bits = src.rawbts->bits;
    }

    // Move constructor
    WrappedCppBitsetT::WrappedCppBitsetT(WrappedCppBitsetT &&src) {
        std::cout << "Move constructing WrappedCppBitsetT\n";
        this->rawbts->size = src.rawbts->size;
        this->rawbts->limbs = src.rawbts->limbs;
        this->rawbts->bits = src.rawbts->bits;

        src.rawbts->size = 0;
        src.rawbts->limbs = 0;
        src.rawbts->bits = nullptr;
    }

    // Copy assignment constructor
    WrappedCppBitsetT::WrappedCppBitsetT& operator=(const WrappedCppBitsetT &rhs) {
        std::cout << "Copy assigning WrappedCppBitsetT\n";
        if (&rhs == this) return *this;

        if (this.rawbts->limbs < rhs.rawbts->limbs) {
            const mp_size_t limb_delta = rhs.rawbts->limbs - this.rawbts->limbs;
            // TODO: Allocate extra limbs
        } else {
            const mp_size_t limb_delta = this.rawbts->limbs = rhs.rawbts->limbs;
            // TODO: Zero out extra limbs
        }
        // TODO: Copy all limbs from rhs to this

        return *this;
    }

    // Move assignment constructor
    WrappedCppBitsetT::WrappedCppBitsetT& operator=(WrappedCppBitsetT &&rhs) {
        std::cout << "Move assigning WrappedCppBitsetT\n";
        this.rawbts = std::move(rhs.rawbts);
        return *this;
    }
    """
    #cdef bitset_t& operator=(bitset_t&& other):
        #return other
    #cdef CppNode& operator=(const CppNode&)
    #cdef CppNodePrio& operator=(const CppNodePrio&)
    cdef cppclass WrappedCppBitsetT:
        WrappedCppBitsetT() except +
        WrappedCppBitsetT& operator=(const WrappedCppBitsetT&)
        #CppBitsetT& operator=(const CppBitsetT&)

ctypedef pair[size_t, WrappedCppBitsetT] Node # vx_to_make_force, forced_metavx

#ctypedef pair[size_t, bitset_t] Node # vx_to_make_force, forced_metavx

ctypedef pair[size_t, Node] NodePrio # prio, Node

#ctypedef public pair[size_t, CppBitset] CppNode
#ctypedef public Node CppNode
#ctypedef public NodePrio CppNodePrio

#ctypedef vector[Node] QueueAtPrio # TODO: try deque too

ctypedef deque[Node] QueueAtPrio
ctypedef unordered_map[size_t, QueueAtPrio] Queue

#ctypedef cppmap[size_t, QueueAtPrio] Queue

"""
cdef class Testerson:
    cdef WrappedCppBitsetT bts
"""

cdef class FastQueueForBFS:
    cdef:
        Queue queue
        list priority_heap

        void push(self, NodePrio)
        #Node pop(self)
        NodePrio pop_and_get_priority(self)
