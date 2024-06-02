#include <iostream>

#include "gmp.h"

#include "test.h"

struct CythonBitsetS {
    mp_bitcnt_t size;
    mp_size_t limbs;
    mp_limb_t *bits;
};

class WrappedCppBitsetT {
    private:
        CythonBitsetS *rawbts;
    public:
        WrappedCppBitsetT();
        WrappedCppBitsetT(const WrappedCppBitsetT&);
};

WrappedCppBitsetT::WrappedCppBitsetT() : rawbts() {
    std::cout << "Constructing WrappedCppBitsetT\n";
}

WrappedCppBitsetT::WrappedCppBitsetT(const WrappedCppBitsetT& other) : rawbts() {
    std::cout << "Copying WrappedCppBitsetT\n";
    this->rawbts->size = other.rawbts->size;
    this->rawbts->limbs = other.rawbts->limbs;
    this->rawbts->bits = other.rawbts->bits;

    other.rawbts->size = 0;
    other.rawbts->limbs = 0;
    other.rawbts->bits = nullptr;
}
