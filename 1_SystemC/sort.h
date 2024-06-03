#ifndef SORT_H
#define SORT_H

#include <systemc.h>

SC_MODULE(stable_sort_6_value) {
    // Input signals
    sc_in<sc_uint<48>> in_Aid_all;
    sc_in<sc_uint<48>> in_CNT_all;

    // Output signals
    sc_out<sc_uint<48>> out_Aid_all;
    sc_out<sc_uint<48>> out_CNT_all;

    // Internal signals
    sc_uint<8> in_Aid[6];
    sc_uint<8> in_CNT[6];
    sc_uint<48> Aid_out;
    sc_uint<48> CNT_out;

    // Process Declaration
    void sort();

    // Constructor
    SC_CTOR(stable_sort_6_value) {
        SC_METHOD(sort);
        sensitive << in_Aid_all << in_CNT_all;
    }
};
#endif