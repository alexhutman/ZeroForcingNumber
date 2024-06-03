from libcpp.pair cimport pair
from libcpp.deque cimport deque
from libcpp.unordered_map cimport unordered_map
#from libcpp.map cimport map as cppmap
from sage.data_structures.bitset_base cimport bitset_t, bitset_s

from sage.libs.gmp.types cimport *

#ctypedef public bitset_t CythonBitsetT
#ctypedef public bitset_s CythonBitsetS
#ctypedef public struct CythonBitsetS:
    #mp_bitcnt_t size
    #mp_size_t limbs
    #mp_limb_t *bits



#cdef public class Test(object)[type ClassType, object ClassObj]:
    #cdef bitset_t jef

#cdef extern from "test.h":
#cdef extern from "fastqueue.h":
cdef extern from *:
    r"""
    #include <iostream>

    #include "gmp.h"

    // TODO: How to not redefine this as to not break things if bitset_s happened to change...
    struct CppBitsetS {
        private:
            mp_bitcnt_t size = 0;
            mp_size_t limbs = 0;
            mp_limb_t *bits = nullptr;

        public:
            CppBitsetS() {
                std::cout << "Constructing empty CppBitsetS\n";
                // Do nothing. Handle initialization in Cythonland
            }


            ~CppBitsetS() {
                std::cout << "Destructing CppBitsetS\n";
                // Do nothing. Handle destruction in Cython side
            }

            // Copy constructor
            CppBitsetS(const CppBitsetS& src) {
                std::cout << "Copy constructing CppBitsetS\n";
                this->size = src.size;
                this->limbs = src.limbs;

                // TODO: Loop through limbs, create new limb, and copy
                this->bits = src.bits;
            }

            // Move constructor
            CppBitsetS(CppBitsetS &&src) {
                std::cout << "Move constructing CppBitsetS\n";
                src.swap(*this);

                /*
                this->size = src.size;
                this->limbs = src.limbs;
                this->bits = src.bits;

                src.size = 0;
                src.limbs = 0;
                src.bits = nullptr;
                */
            }

            // Copy assignment constructor
            CppBitsetS& operator=(const CppBitsetS &rhs) {
                std::cout << "Copy assigning CppBitsetS\n";
                if (&rhs == this) return *this;

                if (this->limbs < rhs.limbs) {
                    const mp_size_t limb_delta = rhs.limbs - this->limbs;
                    // TODO: Allocate extra limbs
                } else {
                    const mp_size_t limb_delta = this->limbs = rhs.limbs;
                    // TODO: Zero out extra limbs
                }
                // TODO: Copy all limbs from rhs to this

                return *this;
            }

            void swap(CppBitsetS &other) {
                std::swap(size, other.size);
                std::swap(limbs, other.limbs);
                std::swap(bits, other.bits);
            }

            // Move assignment constructor
            CppBitsetS& operator=(CppBitsetS &&rhs) {
                std::cout << "Move assigning CppBitsetS\n";
                CppBitsetS temp(std::move(rhs));
                temp.swap(*this);
                return *this;
            }
    };
    """
    #cdef bitset_t& operator=(bitset_t&& other):
        #return other
    #cdef CppNode& operator=(const CppNode&)
    #cdef CppNodePrio& operator=(const CppNodePrio&)
    cdef cppclass CppBitsetS:
        CppBitsetS() except +
        #~CppBitsetS()
        CppBitsetS(const CppBitsetS&)
        CppBitsetS(CppBitsetS&&)
        CppBitsetS& operator=(const CppBitsetS&)
        CppBitsetS& operator=(CppBitsetS&&)
        #CppBitsetT& operator=(const CppBitsetT&)

ctypedef pair[size_t, CppBitsetS] Node # vx_to_make_force, forced_metavx

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
