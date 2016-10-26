//------------------------------------------------------------------------------ 
// Copyright (c) 2004 Xilinx, Inc. 
// All Rights Reserved 
//------------------------------------------------------------------------------ 
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Author: Latha Pillai, Advanced Product Group, Xilinx, Inc.
//  \   \        Filename: MULT35X35_PARALLEL_PIPE 
//  /   /        Date Last Modified: JUNE 02, 2005 
// /___/   /\    Date Created: OCTOBER 05, 2004 
// \   \  /  \ 
//  \___\/\___\ 
// 
//
// Revision History: 
// $Log: $
//------------------------------------------------------------------------------ 
//
//     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
//     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
//     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
//     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
//     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS
//     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
//     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
//     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
//     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
//     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
//     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//     FOR A PARTICULAR PURPOSE.
//
//------------------------------------------------------------------------------ 
//
// Module: MULT35X35_PARALLEL_PIPE
//
// Description: Verilog instantiation template for 
// DSP48 embedded MAC blocks arranged as a pipelined
// 35 x 35 multiplier. The macro uses 4 DSP
// slices . Product[16:0] done in slice1, product[33:17
// done in slice3 and product[69:34] done in slice4.
//
// Device: Whitney Family
//
// Copyright (c) 2000 Xilinx, Inc.  All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////


module MULT35X35_PARALLEL_PIPE (
            CLK, RST, A_IN, B_IN, PROD_OUT, 
            spr_dat_i, acc_rst_i, acc_hi_we_i, acc_lo_we_i,
            acc_sub_i, acc_sel_i, acc_hi_sub_i, acc_hi_sel_i, acc_o
);
	
input           CLK, RST;
input   [34:0]  A_IN, B_IN;
output  [63:0]  PROD_OUT;

input   [31:0]  spr_dat_i;      /* SPR data to write into accumulator */
input           acc_rst_i;      /* reset accumulator to 0 */
input           acc_hi_we_i;    /* write-enable signal for mac_r[63:32] */
input           acc_lo_we_i;    /* write-enable signal for mac_r[31: 0] */
input           acc_sub_i;      /* acc_sub: add(0), sub(1) */
input           acc_sel_i;      /* acc_sel: from_spr(0), accumulator(1) */
input           acc_hi_sub_i;   /* mac_r[63:32]acc_sub: add(0), sub(1) */
input           acc_hi_sel_i;   /* mac_r[63:32]acc_sel: from_spr(0), accumulator(1) */
output  [63:0]  acc_o;          /* output of accumulator */

wire    [17:0]  BCOUT_1, BCOUT_3;
wire    [47:0]  PCOUT_2; 
wire    [47:0]  POUT_1, POUT_3, POUT_4;
wire    [47:0]  MAC_LO;
wire    [47:0]  MAC_HI;

//          
// Product[16:0] Instantiation block 1
//

//   DSP48A1   : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (DSP48A1_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

// DSP48A1: 48-bit Multi-Functional Arithmetic Block
//          Spartan-6
// Xilinx HDL Language Template, version 13.4

DSP48A1 #(
   .A0REG(0),              // First stage A input pipeline register (0/1)
   .A1REG(0),              // Second stage A input pipeline register (0/1)
   .B0REG(0),              // First stage B input pipeline register (0/1)
   .B1REG(0),              // Second stage B input pipeline register (0/1)
   .CARRYINREG(1),         // CARRYIN input pipeline register (0/1)
   .CARRYINSEL("OPMODE5"), // Specify carry-in source, "CARRYIN" or "OPMODE5" 
   .CARRYOUTREG(0),        // CARRYOUT output pipeline register (0/1)
   .CREG(0),               // C input pipeline register (0/1)
   .DREG(0),               // D pre-adder input pipeline register (0/1)
   .MREG(1),               // M pipeline register (0/1)
   .OPMODEREG(0),          // Enable=1/disable=0 OPMODE input pipeline registers
   .PREG(0),               // P output pipeline register (0/1)
   .RSTTYPE("SYNC")        // Specify reset type, "SYNC" or "ASYNC" 
)
DSP48A1_1 (
   // Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
   .BCOUT(BCOUT_1),         // 18-bit output: B port cascade output
   .PCOUT(),                // 48-bit output: P cascade output (if used, connect to PCIN of another DSP48A1)
   // Data Ports: 1-bit (each) output: Data input and output ports
   .CARRYOUT(),             // 1-bit output: carry output (if used, connect to CARRYIN pin of another DSP48A1)
   .CARRYOUTF(),            // 1-bit output: fabric carry output
   .M(),                    // 36-bit output: fabric multiplier data output
   .P(POUT_1),              // 48-bit output: data output
   // Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
   .PCIN(48'b0),            // 48-bit input: P cascade input (if used, connect to PCOUT of another DSP48A1)
   // Control Input Ports: 1-bit (each) input: Clocking and operation mode
   .CLK(CLK),               // 1-bit input: clock input
   .OPMODE(8'b00000001),    // 8-bit input: operation mode input
   // Data Ports: 18-bit (each) input: Data input and output ports
   .A({1'b0,A_IN[16:0]}),   // 18-bit input: A data input
   .B({1'b0,B_IN[16:0]}),   // 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
   .C(48'b0),               // 48-bit input: C data input
   .CARRYIN(1'b0),          // 1-bit input: carry input signal (if used, connect to CARRYOUT pin of another DSP48A1)
   .D(18'b0),               // 18-bit input: B pre-adder data input
   // Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
   .CEA(1'b0),              // 1-bit input: active high clock enable input for A registers
   .CEB(1'b0),              // 1-bit input: active high clock enable input for B registers
   .CEC(1'b0),              // 1-bit input: active high clock enable input for C registers
   .CECARRYIN(1'b0),        // 1-bit input: active high clock enable input for CARRYIN registers
   .CED(1'b0),              // 1-bit input: active high clock enable input for D registers
   .CEM(1'b1),              // 1-bit input: active high clock enable input for multiplier registers
   .CEOPMODE(1'b0),         // 1-bit input: active high clock enable input for OPMODE registers
   .CEP(1'b0),              // 1-bit input: active high clock enable input for P registers
   .RSTA(RST),              // 1-bit input: reset input for A pipeline registers
   .RSTB(RST),              // 1-bit input: reset input for B pipeline registers
   .RSTC(RST),              // 1-bit input: reset input for C pipeline registers
   .RSTCARRYIN(RST),        // 1-bit input: reset input for CARRYIN pipeline registers
   .RSTD(RST),              // 1-bit input: reset input for D pipeline registers
   .RSTM(RST),              // 1-bit input: reset input for M pipeline registers
   .RSTOPMODE(RST),         // 1-bit input: reset input for OPMODE pipeline registers
   .RSTP(RST)               // 1-bit input: reset input for P pipeline registers
);

// End of DSP48A1_inst instantiation

DSP48A1 #(
   .A0REG(0),              // First stage A input pipeline register (0/1)
   .A1REG(0),              // Second stage A input pipeline register (0/1)
   .B0REG(0),              // First stage B input pipeline register (0/1)
   .B1REG(0),              // Second stage B input pipeline register (0/1)
   .CARRYINREG(1),         // CARRYIN input pipeline register (0/1)
   .CARRYINSEL("OPMODE5"), // Specify carry-in source, "CARRYIN" or "OPMODE5" 
   .CARRYOUTREG(0),        // CARRYOUT output pipeline register (0/1)
   .CREG(0),               // C input pipeline register (0/1)
   .DREG(0),               // D pre-adder input pipeline register (0/1)
   .MREG(1),               // M pipeline register (0/1)
   .OPMODEREG(0),          // Enable=1/disable=0 OPMODE input pipeline registers
   .PREG(0),               // P output pipeline register (0/1)
   .RSTTYPE("SYNC")        // Specify reset type, "SYNC" or "ASYNC" 
)
DSP48A1_2 (
   // Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
   .BCOUT(),                // 18-bit output: B port cascade output
   .PCOUT(PCOUT_2),         // 48-bit output: P cascade output (if used, connect to PCIN of another DSP48A1)
   // Data Ports: 1-bit (each) output: Data input and output ports
   .CARRYOUT(),             // 1-bit output: carry output (if used, connect to CARRYIN pin of another DSP48A1)
   .CARRYOUTF(),            // 1-bit output: fabric carry output
   .M(),                    // 36-bit output: fabric multiplier data output
   .P(),                    // 48-bit output: data output
   // Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
   .PCIN(), // 48-bit input: P cascade input (if used, connect to PCOUT of another DSP48A1)
   // Control Input Ports: 1-bit (each) input: Clocking and operation mode
   .CLK(CLK),               // 1-bit input: clock input
   .OPMODE(8'b00001101),    // 8-bit input: operation mode input
   // Data Ports: 18-bit (each) input: Data input and output ports
   .A({A_IN[34:17]}),       // 18-bit input: A data input
   .B({BCOUT_1}),           // 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
   .C({17'b0,POUT_1[47:17]}),   // 48-bit input: C data input
   .CARRYIN(1'b0),          // 1-bit input: carry input signal (if used, connect to CARRYOUT pin of another DSP48A1)
   .D(),                    // 18-bit input: B pre-adder data input
   // Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
   .CEA(1'b0),              // 1-bit input: active high clock enable input for A registers
   .CEB(1'b0),              // 1-bit input: active high clock enable input for B registers
   .CEC(1'b0),              // 1-bit input: active high clock enable input for C registers
   .CECARRYIN(1'b0),        // 1-bit input: active high clock enable input for CARRYIN registers
   .CED(1'b0),              // 1-bit input: active high clock enable input for D registers
   .CEM(1'b1),              // 1-bit input: active high clock enable input for multiplier registers
   .CEOPMODE(1'b0),         // 1-bit input: active high clock enable input for OPMODE registers
   .CEP(1'b0),              // 1-bit input: active high clock enable input for P registers
   .RSTA(RST),              // 1-bit input: reset input for A pipeline registers
   .RSTB(RST),              // 1-bit input: reset input for B pipeline registers
   .RSTC(RST),              // 1-bit input: reset input for C pipeline registers
   .RSTCARRYIN(RST),        // 1-bit input: reset input for CARRYIN pipeline registers
   .RSTD(RST),              // 1-bit input: reset input for D pipeline registers
   .RSTM(RST),              // 1-bit input: reset input for M pipeline registers
   .RSTOPMODE(RST),         // 1-bit input: reset input for OPMODE pipeline registers
   .RSTP(RST)               // 1-bit input: reset input for P pipeline registers
);


assign PROD_OUT[16:0] = POUT_1[16:0]; 

//          
// Product[33:17] Instantiation block 3
//

DSP48A1 #(
   .A0REG(0),               // First stage A input pipeline register (0/1)
   .A1REG(0),               // Second stage A input pipeline register (0/1)
   .B0REG(0),               // First stage B input pipeline register (0/1)
   .B1REG(0),               // Second stage B input pipeline register (0/1)
   .CARRYINREG(1),          // CARRYIN input pipeline register (0/1)
   .CARRYINSEL("OPMODE5"),  // Specify carry-in source, "CARRYIN" or "OPMODE5" 
   .CARRYOUTREG(0),         // CARRYOUT output pipeline register (0/1)
   .CREG(0),                // C input pipeline register (0/1)
   .DREG(0),                // D pre-adder input pipeline register (0/1)
   .MREG(1),                // M pipeline register (0/1)
   .OPMODEREG(0),           // Enable=1/disable=0 OPMODE input pipeline registers
   .PREG(0),                // P output pipeline register (0/1)
   .RSTTYPE("SYNC")         // Specify reset type, "SYNC" or "ASYNC" 
)
DSP48A1_3 (
   // Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
   .BCOUT(BCOUT_3),         // 18-bit output: B port cascade output
   .PCOUT(),                // 48-bit output: P cascade output (if used, connect to PCIN of another DSP48A1)
   // Data Ports: 1-bit (each) output: Data input and output ports
   .CARRYOUT(),             // 1-bit output: carry output (if used, connect to CARRYIN pin of another DSP48A1)
   .CARRYOUTF(),            // 1-bit output: fabric carry output
   .M(),                    // 36-bit output: fabric multiplier data output
   .P(POUT_3),              // 48-bit output: data output
   // Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
   .PCIN(PCOUT_2),          // 48-bit input: P cascade input (if used, connect to PCOUT of another DSP48A1)
   // Control Input Ports: 1-bit (each) input: Clocking and operation mode
   .CLK(CLK),               // 1-bit input: clock input
   .OPMODE(8'b00000101),    // 8-bit input: operation mode input
   // Data Ports: 18-bit (each) input: Data input and output ports
   .A({1'b0,A_IN[16:0]}),   // 18-bit input: A data input
   .B({B_IN[34:17]}),       // 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
   .C(48'b0),               // 48-bit input: C data input
   .CARRYIN(1'b0),          // 1-bit input: carry input signal (if used, connect to CARRYOUT pin of another DSP48A1)
   .D(),                    // 18-bit input: B pre-adder data input
   // Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
   .CEA(1'b0),              // 1-bit input: active high clock enable input for A registers
   .CEB(1'b0),              // 1-bit input: active high clock enable input for B registers
   .CEC(1'b0),              // 1-bit input: active high clock enable input for C registers
   .CECARRYIN(1'b0),        // 1-bit input: active high clock enable input for CARRYIN registers
   .CED(1'b0),              // 1-bit input: active high clock enable input for D registers
   .CEM(1'b1),              // 1-bit input: active high clock enable input for multiplier registers
   .CEOPMODE(1'b0),         // 1-bit input: active high clock enable input for OPMODE registers
   .CEP(1'b0),              // 1-bit input: active high clock enable input for P registers
   .RSTA(RST),              // 1-bit input: reset input for A pipeline registers
   .RSTB(RST),              // 1-bit input: reset input for B pipeline registers
   .RSTC(RST),              // 1-bit input: reset input for C pipeline registers
   .RSTCARRYIN(RST),        // 1-bit input: reset input for CARRYIN pipeline registers
   .RSTD(RST),              // 1-bit input: reset input for D pipeline registers
   .RSTM(RST),              // 1-bit input: reset input for M pipeline registers
   .RSTOPMODE(RST),         // 1-bit input: reset input for OPMODE pipeline registers
   .RSTP(RST)               // 1-bit input: reset input for P pipeline registers
);

assign PROD_OUT[33:17] = POUT_3[16:0];

//          
// Product[69:34] Instantiation block 4
//

DSP48A1 #(
   .A0REG(0),              // First stage A input pipeline register (0/1)
   .A1REG(0),              // Second stage A input pipeline register (0/1)
   .B0REG(0),              // First stage B input pipeline register (0/1)
   .B1REG(0),              // Second stage B input pipeline register (0/1)
   .CARRYINREG(1),         // CARRYIN input pipeline register (0/1)
   .CARRYINSEL("OPMODE5"), // Specify carry-in source, "CARRYIN" or "OPMODE5" 
   .CARRYOUTREG(0),        // CARRYOUT output pipeline register (0/1)
   .CREG(0),               // C input pipeline register (0/1)
   .DREG(0),               // D pre-adder input pipeline register (0/1)
   .MREG(1),               // M pipeline register (0/1)
   .OPMODEREG(0),          // Enable=1/disable=0 OPMODE input pipeline registers
   .PREG(0),               // P output pipeline register (0/1)
   .RSTTYPE("SYNC")        // Specify reset type, "SYNC" or "ASYNC" 
)
DSP48A1_4 (
   // Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
   .BCOUT(),                // 18-bit output: B port cascade output
   .PCOUT(),         // 48-bit output: P cascade output (if used, connect to PCIN of another DSP48A1)
   // Data Ports: 1-bit (each) output: Data input and output ports
   .CARRYOUT(),             // 1-bit output: carry output (if used, connect to CARRYIN pin of another
                            // DSP48A1)

   .CARRYOUTF(),            // 1-bit output: fabric carry output
   .M(),                    // 36-bit output: fabric multiplier data output
   .P(POUT_4),              // 48-bit output: data output
   // Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
   .PCIN(), // 48-bit input: P cascade input (if used, connect to PCOUT of another DSP48A1)
   // Control Input Ports: 1-bit (each) input: Clocking and operation mode
   .CLK(CLK),               // 1-bit input: clock input
   .OPMODE(8'b00001101),    // 8-bit input: operation mode input
   // Data Ports: 18-bit (each) input: Data input and output ports
   .A({A_IN[34:17]}),       // 18-bit input: A data input
   .B({BCOUT_3}),           // 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
   .C({{17{POUT_3[47]}},POUT_3[47:17]}), // 48-bit input: C data input
   .CARRYIN(1'b0),          // 1-bit input: carry input signal (if used, connect to CARRYOUT pin of another
                            // DSP48A1)

   .D(),                    // 18-bit input: B pre-adder data input
   // Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
   .CEA(1'b0),              // 1-bit input: active high clock enable input for A registers
   .CEB(1'b0),              // 1-bit input: active high clock enable input for B registers
   .CEC(1'b0),              // 1-bit input: active high clock enable input for C registers
   .CECARRYIN(1'b0),        // 1-bit input: active high clock enable input for CARRYIN registers
   .CED(1'b0),              // 1-bit input: active high clock enable input for D registers
   .CEM(1'b1),              // 1-bit input: active high clock enable input for multiplier registers
   .CEOPMODE(1'b0),         // 1-bit input: active high clock enable input for OPMODE registers
   .CEP(1'b0),              // 1-bit input: active high clock enable input for P registers
   .RSTA(RST),              // 1-bit input: reset input for A pipeline registers
   .RSTB(RST),              // 1-bit input: reset input for B pipeline registers
   .RSTC(RST),              // 1-bit input: reset input for C pipeline registers
   .RSTCARRYIN(RST),        // 1-bit input: reset input for CARRYIN pipeline registers
   .RSTD(RST),              // 1-bit input: reset input for D pipeline registers
   .RSTM(RST),              // 1-bit input: reset input for M pipeline registers
   .RSTOPMODE(RST),         // 1-bit input: reset input for OPMODE pipeline registers
   .RSTP(RST)               // 1-bit input: reset input for P pipeline registers
);
 
assign PROD_OUT[63:34] = POUT_4[29:0];

//==============================================================================
// 64-bit Accumulator
//==============================================================================

DSP48A1 #(
   .A0REG(0),              // First stage A input pipeline register (0/1)
   .A1REG(0),              // Second stage A input pipeline register (0/1)
   .B0REG(0),              // First stage B input pipeline register (0/1)
   .B1REG(0),              // Second stage B input pipeline register (0/1)
   .CARRYINREG(1),         // CARRYIN input pipeline register (0/1)
   .CARRYINSEL("OPMODE5"), // Specify carry-in source, "CARRYIN" or "OPMODE5" 
   .CARRYOUTREG(0),        // CARRYOUT output pipeline register (0/1)
   .CREG(0),               // C input pipeline register (0/1)
   .DREG(0),               // D pre-adder input pipeline register (0/1)
   .MREG(0),               // M pipeline register (0/1)
   .OPMODEREG(0),          // Enable=1/disable=0 OPMODE input pipeline registers
   .PREG(1),               // P output pipeline register (0/1)
   .RSTTYPE("SYNC")        // Specify reset type, "SYNC" or "ASYNC" 
)
DSP48A1_mac_lo (
   // Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
   .BCOUT(),                // 18-bit output: B port cascade output
   .PCOUT(),                // 48-bit output: P cascade output (if used, connect to PCIN of another DSP48A1)
   // Data Ports: 1-bit (each) output: Data input and output ports
   .CARRYOUT(),             // 1-bit output: carry output (if used, connect to CARRYIN pin of another
                            // DSP48A1)

   .CARRYOUTF(),            // 1-bit output: fabric carry output
   .M(),                    // 36-bit output: fabric multiplier data output
   .P(MAC_LO),              // 48-bit output: data output
   // Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
   .PCIN(), // 48-bit input: P cascade input (if used, connect to PCOUT of another DSP48A1)
   // Control Input Ports: 1-bit (each) input: Clocking and operation mode
   .CLK(CLK),               // 1-bit input: clock input

   .OPMODE({acc_sub_i,1'b0,1'b0,1'b0,1'b1,~acc_sel_i,acc_sel_i,acc_sel_i}), // 8-bit input: operation mode input
   // Data Ports: 18-bit (each) input: Data input and output ports
   //orig: .A({4'b0,spr_dat_i[31:18]}), // 18-bit input: A data input
   //orig: .B(spr_dat_i[17:0]),         // 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
   .A({4'b0,POUT_3[14:1]}),         // 18-bit input: A data input
   .B({POUT_3[0],POUT_1[16:0]}),    // 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
   .C({16'b0,spr_dat_i[31:0]}),     // 48-bit input: C data input
   .CARRYIN(1'b0),                  // 1-bit input: carry input signal (if used, connect to CARRYOUT pin of another DSP48A1)
   .D(18'b0),                       // 18-bit input: B pre-adder data input
   // Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
   .CEA(1'b0),             // 1-bit input: active high clock enable input for A registers
   .CEB(1'b0),             // 1-bit input: active high clock enable input for B registers
   .CEC(1'b0),             // 1-bit input: active high clock enable input for C registers
   .CECARRYIN(1'b0),       // 1-bit input: active high clock enable input for CARRYIN registers
   .CED(1'b0),             // 1-bit input: active high clock enable input for D registers
   .CEM(1'b0),             // 1-bit input: active high clock enable input for multiplier registers
   .CEOPMODE(1'b0),        // 1-bit input: active high clock enable input for OPMODE registers
   .CEP(acc_lo_we_i),      // 1-bit input: active high clock enable input for P registers
   .RSTA(RST),             // 1-bit input: reset input for A pipeline registers
   .RSTB(RST),             // 1-bit input: reset input for B pipeline registers
   .RSTC(RST),             // 1-bit input: reset input for C pipeline registers
   .RSTCARRYIN(RST),       // 1-bit input: reset input for CARRYIN pipeline registers
   .RSTD(RST),             // 1-bit input: reset input for D pipeline registers
   .RSTM(RST),             // 1-bit input: reset input for M pipeline registers
   .RSTOPMODE(RST),        // 1-bit input: reset input for OPMODE pipeline registers
   .RSTP(acc_rst_i)        // 1-bit input: reset input for P pipeline registers
);


DSP48A1 #(
   .A0REG(0),              // First stage A input pipeline register (0/1)
   .A1REG(0),              // Second stage A input pipeline register (0/1)
   .B0REG(0),              // First stage B input pipeline register (0/1)
   .B1REG(0),              // Second stage B input pipeline register (0/1)
   .CARRYINREG(0),         // CARRYIN input pipeline register (0/1)
   .CARRYINSEL("OPMODE5"), // Specify carry-in source, "CARRYIN" or "OPMODE5" 
   .CARRYOUTREG(0),        // CARRYOUT output pipeline register (0/1)
   .CREG(0),               // C input pipeline register (0/1)
   .DREG(0),               // D pre-adder input pipeline register (0/1)
   .MREG(0),               // M pipeline register (0/1)
   .OPMODEREG(0),          // Enable=1/disable=0 OPMODE input pipeline registers
   .PREG(1),               // P output pipeline register (0/1)
   .RSTTYPE("SYNC")        // Specify reset type, "SYNC" or "ASYNC" 
)
DSP48A1_mac_hi (
   // Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
   .BCOUT(),                // 18-bit output: B port cascade output
   .PCOUT(),                // 48-bit output: P cascade output (if used, connect to PCIN of another DSP48A1)
   // Data Ports: 1-bit (each) output: Data input and output ports
   .CARRYOUT(),             // 1-bit output: carry output (if used, connect to CARRYIN pin of another
                            // DSP48A1)

   .CARRYOUTF(),            // 1-bit output: fabric carry output
   .M(),                    // 36-bit output: fabric multiplier data output
   .P(MAC_HI),              // 48-bit output: data output
   // Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
   .PCIN(),                 // 48-bit input: P cascade input (if used, connect to PCOUT of another DSP48A1)
   // Control Input Ports: 1-bit (each) input: Clocking and operation mode
   .CLK(CLK),               // 1-bit input: clock input
   //                     ,CARRY_IN  ,
   .OPMODE({acc_hi_sub_i,1'b0,MAC_LO[32],1'b0,1'b1,~acc_hi_sel_i,acc_hi_sel_i,acc_hi_sel_i}), // 8-bit input: operation mode input
   // Data Ports: 18-bit (each) input: Data input and output ports
   .A({4'b0,POUT_4[29:16]}),            // 18-bit input: A data input
   .B({POUT_4[15:0],POUT_3[16:15]}),    // 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
   .C({16'b0,spr_dat_i[31:0]}), // 48-bit input: C data input
   .CARRYIN(1'b0),              // 1-bit input: carry input signal (if used, connect to CARRYOUT pin of another
                                // DSP48A1)

   .D(18'b0),                   // 18-bit input: B pre-adder data input
   // Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
   .CEA(1'b0),             // 1-bit input: active high clock enable input for A registers
   .CEB(1'b0),             // 1-bit input: active high clock enable input for B registers
   .CEC(1'b0),             // 1-bit input: active high clock enable input for C registers
   .CECARRYIN(1'b0),       // 1-bit input: active high clock enable input for CARRYIN registers
   .CED(1'b0),             // 1-bit input: active high clock enable input for D registers
   .CEM(1'b0),             // 1-bit input: active high clock enable input for multiplier registers
   .CEOPMODE(1'b0),        // 1-bit input: active high clock enable input for OPMODE registers
   .CEP(acc_hi_we_i),      // 1-bit input: active high clock enable input for P registers
   .RSTA(RST),             // 1-bit input: reset input for A pipeline registers
   .RSTB(RST),             // 1-bit input: reset input for B pipeline registers
   .RSTC(RST),             // 1-bit input: reset input for C pipeline registers
   .RSTCARRYIN(RST),       // 1-bit input: reset input for CARRYIN pipeline registers
   .RSTD(RST),             // 1-bit input: reset input for D pipeline registers
   .RSTM(RST),             // 1-bit input: reset input for M pipeline registers
   .RSTOPMODE(RST),        // 1-bit input: reset input for OPMODE pipeline registers
   .RSTP(acc_rst_i)        // 1-bit input: reset input for P pipeline registers
);

// PROD_OUT[16: 0] = POUT_1[16:0]; 
// PROD_OUT[33:17] = POUT_3[16:0];
// PROD_OUT[63:34] = POUT_4[29:0];
assign acc_o[31: 0] = MAC_LO[31:0];
assign acc_o[63:32] = MAC_HI[31:0];

endmodule

