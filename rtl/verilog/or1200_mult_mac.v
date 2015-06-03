//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Top level multiplier, divider and MAC              ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://opencores.org/project,or1k                           ////
////                                                              ////
////  Description                                                 ////
////  Multiplier is 32x32 however multiply instructions only      ////
////  use lower 32 bits of the result. MAC is 32x32=64+64.        ////
////                                                              ////
////  To Do:                                                      ////
////   - make signed division better, w/o negating the operands   ////
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
//
// CVS Revision History
//
// $Log: or1200_mult_mac.v,v $
// Revision 2.0  2010/06/30 11:00:00  ORSoC
// Minor update: 
// Bugs fixed. 
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_mult_mac(
	// Clock and reset
	clk, rst,

	// Multiplier/MAC interface
	ex_freeze, id_macrc_op, id_spr_op, macrc_op, a, b, mac_op, alu_op, result, mac_stall_r,

	// SPR interface
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o
);

parameter width = `OR1200_OPERAND_WIDTH;

//
// I/O
//

//
// Clock and reset
//
input				clk;
input				rst;

//
// Multiplier/MAC interface
//
input				ex_freeze;
input				id_macrc_op;
input				id_spr_op;
input				macrc_op;
input	[width-1:0]		a;
input	[width-1:0]		b;
input	[`OR1200_MACOP_WIDTH-1:0]	mac_op;
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
output	[width-1:0]		result;
output				mac_stall_r;

//
// SPR interface
//
input				spr_cs;
input				spr_write;
input	[31:0]			spr_addr;
input	[31:0]			spr_dat_i;
output	[31:0]			spr_dat_o;

//
// Internal wires and regs
//
wire	[2*width-1:0]		mul_prod;
wire	[`OR1200_MACOP_WIDTH-1:0]	mac_op;
reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r1;
// reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r2;
// reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r3;
reg				mac_stall_r;
wire    [2*width-1:0]		mac_r;
wire                            spr_mac_we;
wire				spr_maclo_we;
wire				spr_machi_we;

wire                            acc_rst;    /* reset accumulator to 0 */
wire                            acc_hi_we;  /* write-enable signal for mac_r[63:32] */
wire                            acc_lo_we;  /* write-enable signal for mac_r[31: 0] */
reg                             acc_sub;    /* acc_sub: add(0), sub(1) */
reg                             acc_sel;    /* acc_sel: from_spr(0), accumulator(1) */

//
// Combinatorial logic
//
assign spr_mac_we   = spr_cs & spr_write & (spr_addr[`OR1200_SPR_GROUP_BITS] == `OR1200_SPR_GROUP_MAC);
assign spr_maclo_we = spr_mac_we & spr_addr[`OR1200_MAC_ADDR];
assign spr_machi_we = spr_mac_we & !spr_addr[`OR1200_MAC_ADDR];
assign spr_dat_o = spr_addr[`OR1200_MAC_ADDR] ? mac_r[31:0] : mac_r[63:32];

//
// Select result of current ALU operation to be forwarded
// to next instruction and to WB stage
//
assign result = (alu_op == `OR1200_ALUOP_MUL) ? mul_prod[31:0] : mac_r[31:0];

//
// Instantiation of the multiplier
//

MULT35X35_PARALLEL_PIPE or1200_sp6_mult35x35
(
    .CLK            (clk),
    .RST            (rst),

    /* interface for 35x35 multiplier */
    .A_IN           ({a[31],a[31],a[31],a}),
    .B_IN           ({b[31],b[31],b[31],b}),
    .PROD_OUT       (mul_prod),

    /* interface for 64-bits accumulator */
    .spr_dat_i      (spr_dat_i),    /* SPR data to write into accumulator */
    .acc_rst_i      (acc_rst),      /* reset accumulator to 0 */
    .acc_hi_we_i    (acc_hi_we),    /* write-enable signal for mac_r[63:32] */
    .acc_lo_we_i    (acc_lo_we),    /* write-enable signal for mac_r[31: 0] */
    .acc_sub_i      (acc_sub),      /* acc_sub: add(0), sub(1) */
    .acc_sel_i      (acc_sel),      /* acc_sel: from_spr(0), accumulator(1) */
    .acc_o          (mac_r)         /* output of accumulator */
);

//
// Propagation of l.mac opcode
//
always @(posedge clk or posedge rst)
	if (rst)
		mac_op_r1 <=  `OR1200_MACOP_WIDTH'b0;
	else
		mac_op_r1 <=  mac_op;

//TODO: //
//TODO: // Propagation of l.mac opcode
//TODO: //
//TODO: always @(posedge clk or posedge rst)
//TODO: 	if (rst)
//TODO: 		mac_op_r2 <=  `OR1200_MACOP_WIDTH'b0;
//TODO: 	else
//TODO: 		mac_op_r2 <=  mac_op_r1;

//TODO: //
//TODO: // Propagation of l.mac opcode
//TODO: //
//TODO: always @(posedge clk or posedge rst)
//TODO: 	if (rst)
//TODO: 		mac_op_r3 <=  `OR1200_MACOP_WIDTH'b0;
//TODO: 	else
//TODO: 		mac_op_r3 <=  mac_op_r2;

//
// Implementation of MAC
//

//TODO: assign 
//TODO: always @(posedge rst or posedge clk)
//TODO: 	if (rst | (macrc_op && !ex_freeze)) begin
//TODO: 		rst_mac_r <=  64'h0000_0000_0000_0000;
//TODO:         end
//TODO: 	else if (spr_maclo_we)
//TODO: 		mac_r[31:0] <=  spr_dat_i;
//TODO: 	else if (spr_machi_we)
//TODO: 		mac_r[63:32] <=  spr_dat_i;
//TODO: 	else if ((mac_op_r3 == `OR1200_MACOP_MAC) | (mac_op_r3 == `OR1200_MACOP_MSB))
//TODO: 		mac_r <=  mac_r + mul_prod;

//
// Stall CPU if l.macrc/l.mfspr/l.mtspr is in ID and MAC still has to process l.mac instructions
// in EX stage (e.g. inside multiplier)
//
always @(posedge rst or posedge clk)
	if (rst)
		mac_stall_r <=  1'b0;
	else
		mac_stall_r <=  ((|mac_op) | (|mac_op_r1)) & (id_macrc_op | id_spr_op);

// Combinational Logic for Accumulator (DSP48) 
assign acc_rst = rst | (macrc_op && !ex_freeze);
assign acc_hi_we = spr_machi_we | (|mac_op_r1);
assign acc_lo_we = spr_maclo_we | (|mac_op_r1);

always @ (*)
begin
    // acc: accumulator
    casez ({spr_mac_we, mac_op_r1}) // synopsys parallel_case
        {1'b1,`OR1200_MACOP_NOP}:   begin
                                    acc_sub     <= 0; /* acc_sub: add(0), sub(1) */
                                    acc_sel     <= 0; /* acc_sel: from_spr(0), accumulator(1) */
                                    end
        {1'b0,`OR1200_MACOP_MAC}:   begin
                                    acc_sub     <= 0; /* acc_sub: add(0), sub(1) */
                                    acc_sel     <= 1; /* acc_sel: from_spr(0), accumulator(1) */
                                    end
        {1'b0,`OR1200_MACOP_MSB}:   begin
                                    acc_sub     <= 1; /* acc_sub: add(0), sub(1) */
                                    acc_sel     <= 1; /* acc_sel: from_spr(0), accumulator(1) */
                                    end
        default:                    begin
                                    acc_sub     <= 0; /* acc_sub: add(0), sub(1) */
                                    acc_sel     <= 0; /* acc_sel: from_spr(0), accumulator(1) */
                                    end
    endcase
end

endmodule
