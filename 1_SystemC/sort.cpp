#include "sort.h"

void stable_sort_6_value::sort(){
    // sc_uint<8> in_Aid[6];
    // sc_uint<8> in_CNT[6];

    /* read the input */
    in_Aid[0] = in_Aid_all.read().range(7,0);
    in_Aid[1] = in_Aid_all.read().range(15,8);
    in_Aid[2] = in_Aid_all.read().range(23,16);
    in_Aid[3] = in_Aid_all.read().range(31,24);
    in_Aid[4] = in_Aid_all.read().range(39,32);
    in_Aid[5] = in_Aid_all.read().range(47,40);
    in_CNT[0] = in_CNT_all.read().range(7,0);
    in_CNT[1] = in_CNT_all.read().range(15,8);
    in_CNT[2] = in_CNT_all.read().range(23,16);
    in_CNT[3] = in_CNT_all.read().range(31,24);
    in_CNT[4] = in_CNT_all.read().range(39,32);
    in_CNT[5] = in_CNT_all.read().range(47,40);

    /* bubble sort (stable) */
    sc_uint<8> Aid_tmp;
    sc_uint<8> CNT_tmp;
    for (int i = 0; i < 6; i = i + 1) {
        for (int j = 0; j < 5 - i; j = j + 1) {
            if (in_CNT[j] > in_CNT[j + 1]) {
                Aid_tmp = in_Aid[j];
                in_Aid[j] = in_Aid[j + 1];
                in_Aid[j + 1] = Aid_tmp;

                CNT_tmp = in_CNT[j];
                in_CNT[j] = in_CNT[j + 1];
                in_CNT[j + 1] = CNT_tmp;
            }
        }
    }

    Aid_out = (in_Aid[5], in_Aid[4], in_Aid[3], in_Aid[2], in_Aid[1], in_Aid[0]);
    CNT_out = (in_CNT[5], in_CNT[4], in_CNT[3], in_CNT[2], in_CNT[1], in_CNT[0]);

    /* write the output */
    out_Aid_all.write(Aid_out);
    out_CNT_all.write(CNT_out);
}