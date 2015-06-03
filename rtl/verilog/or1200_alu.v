//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's ALU                                                ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/project,or1k                       ////
////                                                              ////
////  Description                                                 ////
////  ALU                                                         ////
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
//
// $Log: or1200_alu.v,v $
// Revision 2.0  2010/06/30 11:00:00  ORSoC
// Minor update: 
// Defines added, flags are corrected. 

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_alu(
	a, b, mult_mac_result, macrc_op,
	alu_op, shrot_op, comp_op,
	cust5_op, cust5_limm,
	result, flagforw, flag_we,
	cyforw, cy_we, carry, flag
);

parameter width = `OR1200_OPERAND_WIDTH;

//
// I/O
//
input	[width-1:0]		a;
input	[width-1:0]		b;
input	[width-1:0]		mult_mac_result;
input				macrc_op;
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
input	[`OR1200_SHROTOP_WIDTH-1:0]	shrot_op;
input	[`OR1200_COMPOP_WIDTH-1:0]	comp_op;
input	[4:0]			cust5_op;
input	[5:0]			cust5_limm;
output	[width-1:0]		result;
output				flagforw;
output				flag_we;
output				cyforw;
output				cy_we;
input				carry;
input         flag;

//
// Internal wires and regs
//
reg	[width-1:0]		result;
reg	[width-1:0]		shifted_rotated;
reg				flagforw;
reg				flagcomp;
reg				flag_we;
reg				cy_we;
wire	[width-1:0]		comp_a;
wire	[width-1:0]		comp_b;

`ifdef OR1200_CUST5_IMPLEMENTED
reg	[width-1:0]		result_cust5;
`endif

`ifdef OR1200_IMPL_ALU_COMP1
wire				a_eq_b;
wire				a_lt_b;
`endif
wire	[width-1:0]		result_sum;
`ifdef OR1200_IMPL_ADDC
wire	[width-1:0]		result_csum;
wire				cy_csum;
`endif
wire	[width-1:0]		result_and;
wire				cy_sum;
`ifdef OR1200_IMPL_SUB
wire				cy_sub;
`endif
reg				cyforw;

//
// Combinatorial logic
//
assign comp_a = {a[width-1] ^ comp_op[3] , a[width-2:0]};
assign comp_b = {b[width-1] ^ comp_op[3] , b[width-2:0]};
`ifdef OR1200_IMPL_ALU_COMP1
assign a_eq_b = (comp_a == comp_b);
assign a_lt_b = (comp_a < comp_b);
`endif
`ifdef OR1200_IMPL_SUB
assign cy_sub = a < b;
`endif
assign {cy_sum, result_sum} = a + b;
`ifdef OR1200_IMPL_ADDC
assign {cy_csum, result_csum} = a + b + {`OR1200_OPERAND_WIDTH'd0, carry};
`endif
assign result_and = a & b;

//
// Simulation check for bad ALU behavior
//
`ifdef OR1200_WARNINGS
// synopsys translate_off
always @(result) begin
	if (result === 32'bx)
		$display("%t: WARNING: 32'bx detected on ALU result bus. Please check !", $time);
end
// synopsys translate_on
`endif

//
// Central part of the ALU
//
always @(alu_op or a or b or result_sum or result_and or macrc_op or shifted_rotated or mult_mac_result or flag or carry 
`ifdef OR1200_CUST5_IMPLEMENTED
          or result_cust5
`endif
`ifdef OR1200_IMPL_ADDC
          or result_csum
`endif
) begin
`ifdef OR1200_CASE_DEFAULT
	casex (alu_op)		// synopsys parallel_case
`else
	casex (alu_op)		// synopsys full_case parallel_case
`endif
// l.ff1: not defined in gcc/config/or32/or32.md
// obsolete:		`OR1200_ALUOP_FF1: begin
// obsolete:			result = a[0] ? 1 : a[1] ? 2 : a[2] ? 3 : a[3] ? 4 : a[4] ? 5 : a[5] ? 6 : a[6] ? 7 : a[7] ? 8 : a[8] ? 9 : a[9] ? 10 : a[10] ? 11 : a[11] ? 12 : a[12] ? 13 : a[13] ? 14 : a[14] ? 15 : a[15] ? 16 : a[16] ? 17 : a[17] ? 18 : a[18] ? 19 : a[19] ? 20 : a[20] ? 21 : a[21] ? 22 : a[22] ? 23 : a[23] ? 24 : a[24] ? 25 : a[25] ? 26 : a[26] ? 27 : a[27] ? 28 : a[28] ? 29 : a[29] ? 30 : a[30] ? 31 : a[31] ? 32 : 0;
// obsolete:		end
`ifdef OR1200_CUST5_IMPLEMENTED
		`OR1200_ALUOP_CUST5 : begin 
				result = result_cust5;
		end
`endif
		`OR1200_ALUOP_SHROT : begin 
				result = shifted_rotated;
		end
		`OR1200_ALUOP_ADD : begin
				result = result_sum;
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC : begin
				result = result_csum;
		end
`endif
`ifdef OR1200_IMPL_SUB
		`OR1200_ALUOP_SUB : begin
				result = a - b;
		end
`endif
		`OR1200_ALUOP_XOR : begin
				result = a ^ b;
		end
		`OR1200_ALUOP_OR  : begin
				result = a | b;
		end
		`OR1200_ALUOP_IMM : begin
				result = b;
		end
		`OR1200_ALUOP_MOVHI : begin
				if (macrc_op) begin
					result = mult_mac_result;
				end
				else begin
					result = b << 16;
				end
		end
`ifdef OR1200_MULT_IMPLEMENTED
`ifdef OR1200_DIV_IMPLEMENTED
		`OR1200_ALUOP_DIV,
		`OR1200_ALUOP_DIVU,
`endif
		`OR1200_ALUOP_MUL : begin
				result = mult_mac_result;
		end
`endif
		`OR1200_ALUOP_CMOV: begin
			result = flag ? a : b;
		end

`ifdef OR1200_CASE_DEFAULT
		default: begin
`else
		`OR1200_ALUOP_COMP, `OR1200_ALUOP_AND: begin
`endif
			result=result_and;
		end 
	endcase
end

//
// l.cust5 custom instructions
//
// Examples for move byte, set bit and clear bit
//
`ifdef OR1200_CUST5_IMPLEMENTED
always @(cust5_op or cust5_limm or a or b) begin
	casex (cust5_op)		// synopsys parallel_case
		5'h1 : begin 
			casex (cust5_limm[1:0])
				2'h0: result_cust5 = {a[31:8], b[7:0]};
				2'h1: result_cust5 = {a[31:16], b[7:0], a[7:0]};
				2'h2: result_cust5 = {a[31:24], b[7:0], a[15:0]};
				2'h3: result_cust5 = {b[7:0], a[23:0]};
			endcase
		end
		5'h2 :
			result_cust5 = a | (1 << cust5_limm);
		5'h3 :
			result_cust5 = a & (32'hffffffff ^ (1 << cust5_limm));
//
// *** Put here new l.cust5 custom instructions ***
//
		default: begin
			result_cust5 = a;
		end
	endcase
end
`endif

//
// Generate flag and flag write enable
//
always @(alu_op or result_sum or result_and or flagcomp
`ifdef OR1200_IMPL_ADDC
         or result_csum
`endif
) begin
	casex (alu_op)		// synopsys parallel_case
`ifdef OR1200_ADDITIONAL_FLAG_MODIFIERS
		`OR1200_ALUOP_ADD : begin
			flagforw = (result_sum == 32'h0000_0000);
			flag_we = 1'b1;
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC : begin
			flagforw = (result_csum == 32'h0000_0000);
			flag_we = 1'b1;
		end
`endif
		`OR1200_ALUOP_AND: begin
			flagforw = (result_and == 32'h0000_0000);
			flag_we = 1'b1;
		end
`endif
		`OR1200_ALUOP_COMP: begin
			flagforw = flagcomp;
			flag_we = 1'b1;
		end
		default: begin
			flagforw = flagcomp;
			flag_we = 1'b0;
		end
	endcase
end

//
// Generate SR[CY] write enable
//
always @(alu_op or cy_sum
`ifdef OR1200_IMPL_CY
`ifdef OR1200_IMPL_ADDC
	or cy_csum
`endif
`ifdef OR1200_IMPL_SUB
	or cy_sub
`endif
`endif
) begin
	casex (alu_op)		// synopsys parallel_case
`ifdef OR1200_IMPL_CY
		`OR1200_ALUOP_ADD : begin
			cyforw = cy_sum;
			cy_we = 1'b1;
		end
`ifdef OR1200_IMPL_ADDC
		`OR1200_ALUOP_ADDC: begin
			cyforw = cy_csum;
			cy_we = 1'b1;
		end
`endif
`ifdef OR1200_IMPL_SUB
		`OR1200_ALUOP_SUB: begin
			cyforw = cy_sub;
			cy_we = 1'b1;
		end
`endif
`endif
		default: begin
			cyforw = 1'b0;
			cy_we = 1'b0;
		end
	endcase
end

//
// Shifts and rotation
//
// WITHOUT_ROTATE_RIGHT:
// bs: Barrel Shifter
// bs_msb: the MSB for Shift Right Arithmetic
wire bs_msb;
wire bs_right;
assign bs_msb = shrot_op[`OR1200_SHROTOP_WIDTH-1] & a[width-1];
assign bs_right = |shrot_op; // ROR(11), SRA(10), SRL(01), SLL(00)
// assign bs_inport = a;
// assign bs_range = b[4:0];
always @(bs_msb or bs_right or a or b[4:0])
begin
    case ({bs_right, b[4:0]}) // synopsys parallel_case
        6'd32,                          // shift right with 0-bit (arithmetic/logic)
        6'd0:   shifted_rotated <=  a;  // shift left logic

        6'd1:   shifted_rotated <= {a[30:0], 1'b0};
        6'd2:   shifted_rotated <= {a[29:0], 2'b0};
        6'd3:   shifted_rotated <= {a[28:0], 3'b0};
        6'd4:   shifted_rotated <= {a[27:0], 4'b0};
        6'd5:   shifted_rotated <= {a[26:0], 5'b0};
        6'd6:   shifted_rotated <= {a[25:0], 6'b0};
        6'd7:   shifted_rotated <= {a[24:0], 7'b0};
        6'd8:   shifted_rotated <= {a[23:0], 8'b0};
        6'd9:   shifted_rotated <= {a[22:0], 9'b0};
        6'd10:  shifted_rotated <= {a[21:0], 10'b0};
        6'd11:  shifted_rotated <= {a[20:0], 11'b0};
        6'd12:  shifted_rotated <= {a[19:0], 12'b0};
        6'd13:  shifted_rotated <= {a[18:0], 13'b0};
        6'd14:  shifted_rotated <= {a[17:0], 14'b0};
        6'd15:  shifted_rotated <= {a[16:0], 15'b0};
        6'd16:  shifted_rotated <= {a[15:0], 16'b0};
        6'd17:  shifted_rotated <= {a[14:0], 17'b0};
        6'd18:  shifted_rotated <= {a[13:0], 18'b0};
        6'd19:  shifted_rotated <= {a[12:0], 19'b0};
        6'd20:  shifted_rotated <= {a[11:0], 20'b0};
        6'd21:  shifted_rotated <= {a[10:0], 21'b0};
        6'd22:  shifted_rotated <= {a[9:0],  22'b0};
        6'd23:  shifted_rotated <= {a[8:0],  23'b0};
        6'd24:  shifted_rotated <= {a[7:0],  24'b0};
        6'd25:  shifted_rotated <= {a[6:0],  25'b0};
        6'd26:  shifted_rotated <= {a[5:0],  26'b0};
        6'd27:  shifted_rotated <= {a[4:0],  27'b0};
        6'd28:  shifted_rotated <= {a[3:0],  28'b0};
        6'd29:  shifted_rotated <= {a[2:0],  29'b0};
        6'd30:  shifted_rotated <= {a[1:0],  30'b0};
        6'd31:  shifted_rotated <= {a[  0],  31'b0};

        // 32 ~ 63  // shift right arithmetic/logic
        6'd33:  shifted_rotated <= {    bs_msb,   a[31:1]};
        6'd34:  shifted_rotated <= {{ 2{bs_msb}}, a[31:2]};
        6'd35:  shifted_rotated <= {{ 3{bs_msb}}, a[31:3]};
        6'd36:  shifted_rotated <= {{ 4{bs_msb}}, a[31:4]};
        6'd37:  shifted_rotated <= {{ 5{bs_msb}}, a[31:5]};
        6'd38:  shifted_rotated <= {{ 6{bs_msb}}, a[31:6]};
        6'd39:  shifted_rotated <= {{ 7{bs_msb}}, a[31:7]};
        6'd40:  shifted_rotated <= {{ 8{bs_msb}}, a[31:8]};
        6'd41:  shifted_rotated <= {{ 9{bs_msb}}, a[31:9]};
        6'd42:  shifted_rotated <= {{10{bs_msb}}, a[31:10]};
        6'd43:  shifted_rotated <= {{11{bs_msb}}, a[31:11]};
        6'd44:  shifted_rotated <= {{12{bs_msb}}, a[31:12]};
        6'd45:  shifted_rotated <= {{13{bs_msb}}, a[31:13]};
        6'd46:  shifted_rotated <= {{14{bs_msb}}, a[31:14]};
        6'd47:  shifted_rotated <= {{15{bs_msb}}, a[31:15]};
        6'd48:  shifted_rotated <= {{16{bs_msb}}, a[31:16]};
        6'd49:  shifted_rotated <= {{17{bs_msb}}, a[31:17]};
        6'd50:  shifted_rotated <= {{18{bs_msb}}, a[31:18]};
        6'd51:  shifted_rotated <= {{19{bs_msb}}, a[31:19]};
        6'd52:  shifted_rotated <= {{20{bs_msb}}, a[31:20]};
        6'd53:  shifted_rotated <= {{21{bs_msb}}, a[31:21]};
        6'd54:  shifted_rotated <= {{22{bs_msb}}, a[31:22]};
        6'd55:  shifted_rotated <= {{23{bs_msb}}, a[31:23]};
        6'd56:  shifted_rotated <= {{24{bs_msb}}, a[31:24]};
        6'd57:  shifted_rotated <= {{25{bs_msb}}, a[31:25]};
        6'd58:  shifted_rotated <= {{26{bs_msb}}, a[31:26]};
        6'd59:  shifted_rotated <= {{27{bs_msb}}, a[31:27]};
        6'd60:  shifted_rotated <= {{28{bs_msb}}, a[31:28]};
        6'd61:  shifted_rotated <= {{29{bs_msb}}, a[31:29]};
        6'd62:  shifted_rotated <= {{30{bs_msb}}, a[31:30]};
        6'd63:  shifted_rotated <= {{31{bs_msb}}, a[31   ]};
        default: shifted_rotated <= 'bx;
    endcase
end // Barrel Shift

//
// First type of compare implementation
//
`ifdef OR1200_IMPL_ALU_COMP1
always @(comp_op or a_eq_b or a_lt_b) begin
	case(comp_op[2:0])	// synopsys parallel_case
		`OR1200_COP_SFEQ:
			flagcomp = a_eq_b;
		`OR1200_COP_SFNE:
			flagcomp = ~a_eq_b;
		`OR1200_COP_SFGT:
			flagcomp = ~(a_eq_b | a_lt_b);
		`OR1200_COP_SFGE:
			flagcomp = ~a_lt_b;
		`OR1200_COP_SFLT:
			flagcomp = a_lt_b;
		`OR1200_COP_SFLE:
			flagcomp = a_eq_b | a_lt_b;
		default:
			flagcomp = 1'b0;
	endcase
end
`endif

//larger area for FPGA: //
//larger area for FPGA: // Second type of compare implementation
//larger area for FPGA: //
//larger area for FPGA: `ifdef OR1200_IMPL_ALU_COMP2
//larger area for FPGA: always @(comp_op or comp_a or comp_b) begin
//larger area for FPGA: 	case(comp_op[2:0])	// synopsys parallel_case
//larger area for FPGA: 		`OR1200_COP_SFEQ:
//larger area for FPGA: 			flagcomp = (comp_a == comp_b);
//larger area for FPGA: 		`OR1200_COP_SFNE:
//larger area for FPGA: 			flagcomp = (comp_a != comp_b);
//larger area for FPGA: 		`OR1200_COP_SFGT:
//larger area for FPGA: 			flagcomp = (comp_a > comp_b);
//larger area for FPGA: 		`OR1200_COP_SFGE:
//larger area for FPGA: 			flagcomp = (comp_a >= comp_b);
//larger area for FPGA: 		`OR1200_COP_SFLT:
//larger area for FPGA: 			flagcomp = (comp_a < comp_b);
//larger area for FPGA: 		`OR1200_COP_SFLE:
//larger area for FPGA: 			flagcomp = (comp_a <= comp_b);
//larger area for FPGA: 		default:
//larger area for FPGA: 			flagcomp = 1'b0;
//larger area for FPGA: 	endcase
//larger area for FPGA: end
//larger area for FPGA: `endif

endmodule
