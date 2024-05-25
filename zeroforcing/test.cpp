#include <iostream>
#include "test.h"

//static_assert(false, "Test!");

//typedef CythonBitsetS CppRawBitsetT[1];
//typedef std::array<CythonBitsetS, 1> CppArrBitsetT;

struct Test {
    int test;
};

//WrappedCppBitsetT::WrappedCppBitsetT() : converted_bts {  } {
WrappedCppBitsetT::WrappedCppBitsetT() : rawbts() {
//WrappedCppBitsetT::WrappedCppBitsetT() : bts {} {
    std::cout << "Constructing WrappedCppBitsetT\n";
    //this->raw_bitset = static_cast<CppRawBitsetT>(new CythonBitsetT);
    //this->rawbts = CppArrBitsetT();

    /*
    CppBitsetT::operator=(const CppBitsetT &other) {
        return *other;
    }
    */
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
/*
WrappedCppBitsetT::~WrappedCppBitsetT() {
    std::cout << "Destructing WrappedCppBitsetT\n";
    delete rawbts;
}
*/
auto a = WrappedCppBitsetT();
