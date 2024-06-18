from libcpp.utility cimport move

import heapq


cdef class FastQueueForBFS:
    cdef void push(self, NodePrio new_item):
        if self.queue.count(new_item.first) == 0:
            self.queue[new_item.first] = QueueAtPrio()
        #self.queue[new_item.first].push_back(new_item.second)
        self.queue[new_item.first].push_back(move(new_item.second))

        if self.queue[new_item.first].size() == 1:
            heapq.heappush(self.priority_heap, new_item.first)

    cdef NodePrio pop_and_get_priority(self):
        cdef size_t priority_to_return = self.priority_heap[0]
        cdef Node item_to_return = move(self.queue[priority_to_return].front())
        #cdef Node item_to_return = self.queue[priority_to_return].front()

        self.queue[priority_to_return].pop_front()
        if self.queue[priority_to_return].size() == 0:
            heapq.heappop(self.priority_heap)

        return NodePrio(priority_to_return, item_to_return)
