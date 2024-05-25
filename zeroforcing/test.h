#include <array>
#include "fastqueue.h"

//typedef std::array<CythonBitsetS, 1> CppBitsetT;
class WrappedCppBitsetT {
    private:
        //CythonBitsetT bts;
        CythonBitsetS *rawbts;
    public:
        WrappedCppBitsetT();
        ~WrappedCppBitsetT();
        WrappedCppBitsetT(const WrappedCppBitsetT&);
};
