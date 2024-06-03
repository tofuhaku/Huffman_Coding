`timescale 1ns/10ps
module huffman(
    clk,
    reset,
    gray_valid,
    gray_data,
    CNT_valid,
    CNT,
    code_valid,
    HC,
    M,
    in_Aid_all,
    in_CNT_all,
    out_Aid_all,
    out_CNT_all
);

input               clk;
input               reset;
input               gray_valid;
input       [7:0]   gray_data;

output reg          CNT_valid;
output reg  [47:0]  CNT;
output reg          code_valid;
output reg  [47:0]  HC;
output reg  [47:0]  M;

// ===============================================================
//      Reg & Wire Declaration
// ===============================================================
// reg [1:0] mode;
reg [2:0] state, next_state;    // FSM
reg [7:0] phase, next_phase;    // for which pair to combine
reg [7:0] mask [0:5];
reg [7:0] huff_code [0:5];
reg [3:0] ID [0:5];

localparam MAX = 8'd127;
localparam Aid_MAX = 8'd5;

// ===============================================================
//      SORT(6 input)
// ===============================================================
output reg [47:0]   in_Aid_all;
output reg [47:0]   in_CNT_all;

input      [47:0]   out_Aid_all;
input      [47:0]   out_CNT_all;

reg [7:0] in_Aid [5:0];
reg [7:0] in_CNT [5:0];

reg [7:0] out_Aid [5:0];
reg [7:0] out_CNT [5:0];

always @(*) begin
    in_Aid_all = {in_Aid[0], in_Aid[1], in_Aid[2], in_Aid[3], in_Aid[4], in_Aid[5]};
    in_CNT_all = {in_CNT[0], in_CNT[1], in_CNT[2], in_CNT[3], in_CNT[4], in_CNT[5]};
end

always @(*) begin
    {out_Aid[0], out_Aid[1], out_Aid[2], out_Aid[3], out_Aid[4], out_Aid[5]} = out_Aid_all;
    {out_CNT[0], out_CNT[1], out_CNT[2], out_CNT[3], out_CNT[4], out_CNT[5]} = out_CNT_all;
end

always @(*) begin
    CNT = {in_CNT[0], in_CNT[1], in_CNT[2], in_CNT[3], in_CNT[4], in_CNT[5]};
end

// ===============================================================
//      FSM state
// ===============================================================

//You can modify the FSM state
localparam IDLE     = 2'd0;
localparam SORTING  = 2'd1;
localparam CODING = 2'd2;
localparam OUT      = 2'd3;

//================================================================
//      FSM design
//================================================================
always @(posedge clk or posedge reset) begin
    if(reset)begin
        state <= IDLE;
        phase <= 'd0;
    end
    else begin
        state <= next_state;
        phase <= next_phase;
    end
end

always @(*) begin
    case(state)

        IDLE: begin
            if(gray_valid) begin
                next_state = SORTING;
            end
            else begin
                next_state = IDLE;
            end
            next_phase = 'd0;
        end

        SORTING: begin
            if(phase == 'd99) begin             // 100 cycle for sorting
                next_state = CODING;
                next_phase = 'd0;
            end
            else begin
                next_state = SORTING;
                next_phase = phase + 'd1;
            end
        end

        CODING: begin
            if(phase == 'd3) begin
                next_state = OUT;
                next_phase = 'd0;
            end
            else begin
                next_state = CODING;
                next_phase = phase + 'd1;
            end
        end

        OUT: begin
            next_state = IDLE;
            next_phase = 'd0;
        end

        default: begin
            next_state = state;
            next_phase = phase;
        end
    endcase
end

// ===============================================================
//      Design
// ===============================================================
/* count CNT */
always @(posedge clk or posedge reset) begin
    if(reset) begin
        in_CNT[0] <= 'd0;
        in_CNT[1] <= 'd0;
        in_CNT[2] <= 'd0;
        in_CNT[3] <= 'd0;
        in_CNT[4] <= 'd0;
        in_CNT[5] <= 'd0;
    end
    else if(next_state == SORTING) begin
        case(gray_data)
            'd1: in_CNT[0] <= in_CNT[0] + 'd1;
            'd2: in_CNT[1] <= in_CNT[1] + 'd1;
            'd3: in_CNT[2] <= in_CNT[2] + 'd1;
            'd4: in_CNT[3] <= in_CNT[3] + 'd1;
            'd5: in_CNT[4] <= in_CNT[4] + 'd1;
            'd6: in_CNT[5] <= in_CNT[5] + 'd1;
            default: ;
        endcase
    end
    else if(next_state == CODING || next_state == OUT) begin
        in_CNT[0] <= out_CNT[0];
        in_CNT[1] <= out_CNT[1];
        in_CNT[2] <= out_CNT[2];
        in_CNT[3] <= out_CNT[3];
        in_CNT[4] <= out_CNT[4] + out_CNT[5];
        in_CNT[5] <= MAX;
    end
    else if(state == OUT) begin
        in_CNT[0] <= 'd0;
        in_CNT[1] <= 'd0;
        in_CNT[2] <= 'd0;
        in_CNT[3] <= 'd0;
        in_CNT[4] <= 'd0;
        in_CNT[5] <= 'd0;
    end

    /*
        add other design here
    */

    else begin
        in_CNT[0] <= in_CNT[0];
        in_CNT[1] <= in_CNT[1];
        in_CNT[2] <= in_CNT[2];
        in_CNT[3] <= in_CNT[3];
        in_CNT[4] <= in_CNT[4];
        in_CNT[5] <= in_CNT[5];
    end
end

/* Aid control */
always @(posedge clk or posedge reset) begin
    if(reset) begin
        in_Aid[0] <= 'd5;
        in_Aid[1] <= 'd4;
        in_Aid[2] <= 'd3;
        in_Aid[3] <= 'd2;
        in_Aid[4] <= 'd1;
        in_Aid[5] <= 'd0;
    end
    else if(state == OUT) begin
        in_Aid[0] <= 'd5;
        in_Aid[1] <= 'd4;
        in_Aid[2] <= 'd3;
        in_Aid[3] <= 'd2;
        in_Aid[4] <= 'd1;
        in_Aid[5] <= 'd0;
    end

    /*
        add other design here
    */

    else if(next_state == CODING || next_state == OUT) begin
        in_Aid[0] <= out_Aid[0];
        in_Aid[1] <= out_Aid[1];
        in_Aid[2] <= out_Aid[2];
        in_Aid[3] <= out_Aid[3];
        in_Aid[4] <= Aid_MAX + next_phase + 1;
        in_Aid[5] <= MAX;
    end
end


/* ID changing */
reg [3:0] ID_MAX;
always @(posedge clk or posedge reset) begin
    if(reset) begin
        ID_MAX <= 'd6;
    end
    else if(next_state == CODING || next_state == OUT) begin
        if(ID_MAX == 'd10) begin
            ID_MAX <= 'd6;
        end
        else begin
            ID_MAX <= ID_MAX + 'd1;
        end
    end
    else begin
        ID_MAX <= ID_MAX;
    end
end

always @(posedge clk) begin
    if(next_state == CODING || next_state == OUT) begin
        if((ID[0] == out_Aid[5]) || (ID[0] == out_Aid[4])) ID[0] <= ID_MAX;
        else ID[0] <= ID[0];

        if((ID[1] == out_Aid[5]) || (ID[1] == out_Aid[4])) ID[1] <= ID_MAX;
        else ID[1] <= ID[1];

        if((ID[2] == out_Aid[5]) || (ID[2] == out_Aid[4])) ID[2] <= ID_MAX;
        else ID[2] <= ID[2];

        if((ID[3] == out_Aid[5]) || (ID[3] == out_Aid[4])) ID[3] <= ID_MAX;
        else ID[3] <= ID[3];

        if((ID[4] == out_Aid[5]) || (ID[4] == out_Aid[4])) ID[4] <= ID_MAX;
        else ID[4] <= ID[4];

        if((ID[5] == out_Aid[5]) || (ID[5] == out_Aid[4])) ID[5] <= ID_MAX;
        else ID[5] <= ID[5];
    end
    else begin
        ID[0] <= 'd5;
        ID[1] <= 'd4;
        ID[2] <= 'd3;
        ID[3] <= 'd2;
        ID[4] <= 'd1;
        ID[5] <= 'd0;
    end
end

/* mask control */
always @(posedge clk) begin
    if(next_state == CODING || next_state == OUT) begin
        if((ID[0] == out_Aid[5]) || (ID[0] == out_Aid[4])) mask[0] <= (mask[0] << 1) + 'd1;
        else mask[0] <= mask[0];

        if((ID[1] == out_Aid[5]) || (ID[1] == out_Aid[4])) mask[1] <= (mask[1] << 1) + 'd1;
        else mask[1] <= mask[1];

        if((ID[2] == out_Aid[5]) || (ID[2] == out_Aid[4])) mask[2] <= (mask[2] << 1) + 'd1;
        else mask[2] <= mask[2];

        if((ID[3] == out_Aid[5]) || (ID[3] == out_Aid[4])) mask[3] <= (mask[3] << 1) + 'd1;
        else mask[3] <= mask[3];

        if((ID[4] == out_Aid[5]) || (ID[4] == out_Aid[4])) mask[4] <= (mask[4] << 1) + 'd1;
        else mask[4] <= mask[4];

        if((ID[5] == out_Aid[5]) || (ID[5] == out_Aid[4])) mask[5] <= (mask[5] << 1) + 'd1;
        else mask[5] <= mask[5];
    end
    else begin
        mask[0] <= 'd0;
        mask[1] <= 'd0;
        mask[2] <= 'd0;
        mask[3] <= 'd0;
        mask[4] <= 'd0;
        mask[5] <= 'd0;
    end
end

/* huffman encoding */
reg [2:0] pointer[0:5];
always @(posedge clk) begin
    if(next_state == CODING || next_state == OUT) begin
        if((ID[0] == out_Aid[5]) || (ID[0] == out_Aid[4])) pointer[0] <= pointer[0] + 1;
        else pointer[0] <= pointer[0];

        if((ID[1] == out_Aid[5]) || (ID[1] == out_Aid[4])) pointer[1] <= pointer[1] + 1;
        else pointer[1] <= pointer[1];

        if((ID[2] == out_Aid[5]) || (ID[2] == out_Aid[4])) pointer[2] <= pointer[2] + 1;
        else pointer[2] <= pointer[2];

        if((ID[3] == out_Aid[5]) || (ID[3] == out_Aid[4])) pointer[3] <= pointer[3] + 1;
        else pointer[3] <= pointer[3];

        if((ID[4] == out_Aid[5]) || (ID[4] == out_Aid[4])) pointer[4] <= pointer[4] + 1;
        else pointer[4] <= pointer[4];

        if((ID[5] == out_Aid[5]) || (ID[5] == out_Aid[4])) pointer[5] <= pointer[5] + 1;
        else pointer[5] <= pointer[5];
    end
    else begin
        pointer[0] <= 'd0;
        pointer[1] <= 'd0;
        pointer[2] <= 'd0;
        pointer[3] <= 'd0;
        pointer[4] <= 'd0;
        pointer[5] <= 'd0;
    end
end

always @(posedge clk) begin
    if(next_state == CODING || next_state == OUT) begin
        if(ID[0] == out_Aid[5]) huff_code[0] <= huff_code[0] + ('d1 << pointer[0]);
        else huff_code[0] <= huff_code[0];

        if(ID[1] == out_Aid[5]) huff_code[1] <= huff_code[1] + ('d1 << pointer[1]);
        else huff_code[1] <= huff_code[1];

        if(ID[2] == out_Aid[5]) huff_code[2] <= huff_code[2] + ('d1 << pointer[2]);
        else huff_code[2] <= huff_code[2];

        if(ID[3] == out_Aid[5]) huff_code[3] <= huff_code[3] + ('d1 << pointer[3]);
        else huff_code[3] <= huff_code[3];

        if(ID[4] == out_Aid[5]) huff_code[4] <= huff_code[4] + ('d1 << pointer[4]);
        else huff_code[4] <= huff_code[4];

        if(ID[5] == out_Aid[5]) huff_code[5] <= huff_code[5] + ('d1 << pointer[5]);
        else huff_code[5] <= huff_code[5];
    end
    else begin
        huff_code[0] <= 'd0;
        huff_code[1] <= 'd0;
        huff_code[2] <= 'd0;
        huff_code[3] <= 'd0;
        huff_code[4] <= 'd0;
        huff_code[5] <= 'd0;
    end
end

/* CNT output */
always @(*) begin
    if(state == SORTING) begin
        if(phase == 'd99) begin
            CNT_valid = 1;
        end
        else begin
            CNT_valid = 0;
        end
    end
    else begin
        CNT_valid = 0;
    end
end


/* code and mask output */
always @(*) begin
    if(state == OUT) begin
        code_valid = 1;
        HC = {huff_code[0], huff_code[1], huff_code[2], huff_code[3], huff_code[4], huff_code[5]};
        M = {mask[0], mask[1], mask[2], mask[3], mask[4], mask[5]};
    end
    else begin
        code_valid = 0;
        HC = 'd0;
        M = 'd0;
    end
end

endmodule