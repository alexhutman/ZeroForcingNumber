from sage.data_structures.bitset_base cimport (
    bitset_add,
    bitset_clear,
    bitset_copy,
    bitset_difference,
    bitset_eq,
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
    bitset_s,
    bitset_t,
    bitset_union,
    mp_bitcnt_t
)

cdef void custom_bitset_add(bitset_s bts, mp_bitcnt_t n) noexcept:
    cdef bitset_t temp = [bts]
    bitset_add(temp, n)

cdef void custom_bitset_clear(bitset_s bts) noexcept:
    cdef bitset_t temp = [bts]
    bitset_clear(temp)

cdef void custom_bitset_copy(bitset_s dst, bitset_s src) noexcept:
    cdef bitset_t temp_dst = [dst]
    cdef bitset_t temp_src = [src]
    bitset_copy(temp_dst, temp_src)

cdef void custom_bitset_difference(bitset_s r, bitset_s a, bitset_s b) noexcept:
    cdef bitset_t temp_r = [r]
    cdef bitset_t temp_a = [a]
    cdef bitset_t temp_b = [b]
    bitset_difference(temp_r, temp_a, temp_b)

cdef bint custom_bitset_eq(bitset_s a, bitset_s b) noexcept:
    cdef bitset_t temp_a = [a]
    cdef bitset_t temp_b = [b]
    return bitset_eq(temp_a, temp_b)

cdef void custom_bitset_free(bitset_s bts) noexcept:
    cdef bitset_t temp_bts = [bts]
    bitset_free(temp_bts)

cdef bint custom_bitset_in(bitset_s bts, mp_bitcnt_t n) noexcept:
    cdef bitset_t temp_bts = [bts]
    return bitset_in(temp_bts, n)

cdef bint custom_bitset_init(bitset_s bts, mp_bitcnt_t size) except -1:
    cdef bitset_t temp_bts = [bts]
    return bitset_init(temp_bts, size)

cdef void custom_bitset_intersection(bitset_s r, bitset_s a, bitset_s b) noexcept nogil:
    cdef bitset_t temp_r = [r]
    cdef bitset_t temp_a = [a]
    cdef bitset_t temp_b = [b]
    bitset_intersection(temp_r, temp_a, temp_b)

cdef bint custom_bitset_isempty(bitset_s bts) noexcept nogil:
    cdef bitset_t temp_bts = [bts]
    return bitset_isempty(temp_bts)

cdef bint custom_bitset_issubset(bitset_s a, bitset_s b) noexcept nogil:
    cdef bitset_t temp_a = [a]
    cdef bitset_t temp_b = [b]
    return bitset_issubset(temp_a, temp_b)

cdef long custom_bitset_len(bitset_s bts) noexcept nogil:
    cdef bitset_t temp_bts = [bts]
    return bitset_len(temp_bts)

cdef long custom_bitset_next(bitset_s a, mp_bitcnt_t n) noexcept:
    cdef bitset_t temp_a = [a]
    return bitset_next(temp_a, n)

cdef long custom_bitset_pop(bitset_s a) except -1:
    cdef bitset_t temp_a = [a]
    return bitset_pop(temp_a)

cdef bint custom_bitset_remove(bitset_s bts, mp_bitcnt_t n) except -1:
    cdef bitset_t temp_bts = [bts]
    return bitset_remove(temp_bts, n)

cdef void custom_bitset_union(bitset_s r, bitset_s a, bitset_s b) noexcept nogil:
    cdef bitset_t temp_r = [r]
    cdef bitset_t temp_a = [a]
    cdef bitset_t temp_b = [b]
    bitset_union(temp_r, temp_a, temp_b)
