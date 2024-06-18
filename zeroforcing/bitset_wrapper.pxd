from sage.data_structures.bitset_base cimport (
    bitset_s,
    mp_bitcnt_t
)

cdef void custom_bitset_add(bitset_s bts, mp_bitcnt_t n) noexcept
cdef void custom_bitset_clear(bitset_s bts) noexcept
cdef void custom_bitset_copy(bitset_s dst, bitset_s src) noexcept
cdef void custom_bitset_difference(bitset_s r, bitset_s a, bitset_s b) noexcept
cdef bint custom_bitset_eq(bitset_s a, bitset_s b) noexcept
cdef void custom_bitset_free(bitset_s bts) noexcept
cdef bint custom_bitset_in(bitset_s bts, mp_bitcnt_t n) noexcept
cdef bint custom_bitset_init(bitset_s bts, mp_bitcnt_t size) except -1
cdef void custom_bitset_intersection(bitset_s r, bitset_s a, bitset_s b) noexcept nogil
cdef bint custom_bitset_isempty(bitset_s bts) noexcept nogil
cdef bint custom_bitset_issubset(bitset_s a, bitset_s b) noexcept nogil
cdef long custom_bitset_len(bitset_s bts) noexcept nogil
cdef long custom_bitset_next(bitset_s a, mp_bitcnt_t n) noexcept
cdef long custom_bitset_pop(bitset_s a) except -1
cdef bint custom_bitset_remove(bitset_s bts, mp_bitcnt_t n) except -1
cdef void custom_bitset_union(bitset_s r, bitset_s a, bitset_s b) noexcept nogil
