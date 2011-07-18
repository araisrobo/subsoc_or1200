//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic 32x32 multiplier                                    ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Generic 32x32 multiplier with pipeline stages.              ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

// 35x35 multiplier, refer to Xilinx xapp467.pdf
// input: 32x32
// output: 64

`ifdef OR1200_FPGA_MULTP2_32X32

`define OR1200_W 32
`define OR1200_WW 64

module or1200_fmultp2_32x32 ( X, Y, CLK, RST, P );

input   [`OR1200_W-1:0]     X;
input   [`OR1200_W-1:0]     Y;
input                       CLK;
input                       RST;
output  [`OR1200_WW-1:0]    P;

wire    [`OR1200_WW-1:0]    p0;
wire    [`OR1200_W-1:0]     q0;
wire    [`OR1200_W-1:0]     r0;
wire    [`OR1200_W-1:0]     s0;
reg     [`OR1200_WW-1:0]    p1;
reg     [`OR1200_W-1:0]     q1;
wire    [`OR1200_WW-1:16]   r1;
reg     [`OR1200_WW-1:0]    p2;

//
// First multiply stage
//
assign p0[63:32] = X[31:16] * Y[31:16];
assign p0[31: 0] = X[15: 0] * Y[15: 0];
assign q0[31: 0] = X[31:16] * Y[15: 0];
assign r0[31: 0] = X[15: 0] * Y[31:16];
assign s0 = q0 + r0;

always @(posedge CLK or posedge RST)
    if (RST) begin
        p1 <=   0;
        q1 <=   0;
    end else begin
        p1 <=   p0;
        q1 <=   s0;
    end

//
// Second multiply stage
//
assign r1 = p1[63:16] + {16'b0,q1};    // 53-bit full adder
always @(posedge CLK or posedge RST)
    if (RST) 
        p2 <= 0;
    else
        p2 <= {r1, p1[15:0]};

assign P = p2[63:0];

endmodule

`endif
