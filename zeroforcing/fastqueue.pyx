from libcpp.utility cimport move
#from zeroforcing.fastqueue cimport WrappedCppBitsetT

cimport cython
import heapq

"""
cdef class Testerson:
    def __cinit__(self):
        WrappedCppBitsetT()
"""

cdef class FastQueueForBFS:
    #@cython.boundscheck(False)
    #@cython.wraparound(False)
    cdef void push(self, NodePrio new_item):
        try:
            self.queue[new_item.first].push_back(new_item.second)
        except IndexError:
            self.queue[new_item.first] = QueueAtPrio()
            self.queue[new_item.first].push_back(new_item.second)

        if self.queue[new_item.first].size() == 1:
            heapq.heappush(self.priority_heap, new_item.first)

    #cdef Node pop(self):
        #cdef:
            #size_t priority_to_return = self.priority_heap[0]
            #Node item_to_return = self.queue[priority_to_return].front()

        #self.queue[priority_to_return].pop_front()
        #if self.queue[item_to_return.first].size() == 0:
            #heapq.heappop(self.priority_heap)

        #return item_to_return

        #return self.pop_and_get_priority().second

    #@cython.boundscheck(False)
    #@cython.wraparound(False)
    cdef NodePrio pop_and_get_priority(self):
        cdef size_t priority_to_return = self.priority_heap[0]
        cdef Node item_to_return = move(self.queue[priority_to_return].front())

        self.queue[priority_to_return].pop_front()
        if self.queue[priority_to_return].size() == 0:
            heapq.heappop(self.priority_heap)

        return NodePrio(priority_to_return, item_to_return)
