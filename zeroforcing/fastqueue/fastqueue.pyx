cdef class FastQueueForBFS:
    def __init__(self, max_priority):
        self.array_list = []
        self.smallest_nonempty_priority = 0
        self.max_possible_priority = 0

        for i in range(max_priority+1):
            self.array_list.append( list([]) )
        self.max_possible_priority = max_priority
        self.smallest_nonempty_priority = max_priority + 1
    
    def __len__(self):
        total_length = 0
        for i in range(self.max_possible_priority+1):
            total_length += len(self.array_list[i])
        return total_length
    
    cdef pop(self):
        if self.smallest_nonempty_priority > self.max_possible_priority:
            return None
        else:
            item_to_return = self.array_list[self.smallest_nonempty_priority].pop()
        
        while self.smallest_nonempty_priority <= self.max_possible_priority:
            if len(self.array_list[self.smallest_nonempty_priority]) == 0:
                self.smallest_nonempty_priority += 1
            else:
                break
        return item_to_return
    
    cdef tuple pop_and_get_priority(self):
        if self.smallest_nonempty_priority > self.max_possible_priority:
            return None
        else:
            item_to_return = self.array_list[self.smallest_nonempty_priority].pop()
            priority_to_return = self.smallest_nonempty_priority
        
        while self.smallest_nonempty_priority <= self.max_possible_priority:
            if len(self.array_list[self.smallest_nonempty_priority]) == 0:
                self.smallest_nonempty_priority += 1
            else:
                break
        return priority_to_return, item_to_return

    cdef push(self, int priority_for_new_item, tuple new_item):
        self.array_list[priority_for_new_item].append(new_item)
        
        if priority_for_new_item < self.smallest_nonempty_priority:
            self.smallest_nonempty_priority = priority_for_new_item
