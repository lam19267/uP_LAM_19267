//CODIGO DEL BUS DRIVERS
module BD(input wire enable, input wire[3:0] A, output wire[3:0] data_bus);
  assign data_bus = enable ? A:4'bz; //CODIGO PARA QUE NO HAYA CONTENCION
endmodule

//CODIGO DEL ACCUMULATOR
module ACCU(input wire clk, reset, enable, input wire[3:0]A, output wire[3:0] accu);
//FLIPFLOP DE 4 BITS PARA EL ACCUMULATOR
  FFP4 F3(clk, reset, enable, A, accu);
endmodule

//CODIGO DE ALU
module ALU(input [3:0] A, B, input [2:0] R, output C, Ze, output [3:0] Y);
    reg [4:0] H;
    always @ (A, B, R)
    //SE AGREGAN LOS CALCULOS ARITMETICOS DE LA ALU
        case (R)
            3'b000: H = A;
            3'b001: H = A - B;
            3'b010: H = B;
            3'b011: H = A + B;
            3'b100: H = {1'b0, ~(A & B)};
            default: H = 5'b10101;
        endcase
//SE ASIGNAN VALORES
    assign Y = H[3:0];
    assign C = H[4];
    assign Ze = ~(H[3] | H[2] | H[1] | H[0]);
endmodule

//CODIGO DEL PC
module PC(input wire clk, reset, enable, loadbit, input wire[11:0] load ,output reg [11:0] PC);
//SE ASIGNA PARA QUE EL PC CUENTE Y SE PUEDA RESETEAR Y METER UN VALOR PREDETERMINADO
  always @ (posedge clk or posedge reset) begin
    if (reset)
      PC <= 12'b0;
    else if (loadbit)
      PC <= load;
    else if (enable)
      PC <= PC + 1;
  end
endmodule

//CODIGO DEL ROM
module ROM(input wire[11:0] A, output  wire[7:0] program_byte);
//EL CODIGO DE LA ROM PARA QUE LEA LA MEMORIA
  reg[7:0] Memoria[0:4096];
  initial
    $readmemh("memory.list", Memoria);
  assign program_byte = Memoria[A];
endmodule

//CODIGO DEL FETCH
module FETCH(input wire clk, reset, enable, input wire [7:0]A, output wire[3:0] instr, oprnd);
//2 FLIPFLOP PARA EL oprnd Y EL instr DE 4 BITS CADA UNO
 FFP4 F1(clk, reset, enable, A[7:4], instr);
 FFP4 F2(clk, reset, enable, A[3:0], oprnd);
endmodule

//CODIGO DEL FETCH
module DECODE(input [6:0] A, output [12:0] controls);

    reg [12:0] Y;
//SE ASIGNA LA NUBE COMBINACIONAL DEL DECODE
    always @ (A)
        casez(A)
            // any
            7'b????_??0: Y <= 13'b1000_000_001000;
            // JC
            7'b0000_1?1: Y <= 13'b0100_000_001000;
            7'b0000_0?1: Y <= 13'b1000_000_001000;
            // JNC
            7'b0001_1?1: Y <= 13'b1000_000_001000;
            7'b0001_0?1: Y <= 13'b0100_000_001000;
            // CMPI
            7'b0010_??1: Y <= 13'b0001_001_000010;
            // CMPM
            7'b0011_??1: Y <= 13'b1001_001_100000;
            // LIT
            7'b0100_??1: Y <= 13'b0011_010_000010;
            // IN
            7'b0101_??1: Y <= 13'b0011_010_000100;
            // LD
            7'b0110_??1: Y <= 13'b1011_010_100000;
            // ST
            7'b0111_??1: Y <= 13'b1000_000_111000;
            // JZ
            7'b1000_?11: Y <= 13'b0100_000_001000;
            7'b1000_?01: Y <= 13'b1000_000_001000;
            // JNZ
            7'b1001_?11: Y <= 13'b1000_000_001000;
            7'b1001_?01: Y <= 13'b0100_000_001000;
            // ADDI
            7'b1010_??1: Y <= 13'b0011_011_000010;
            // ADDM
            7'b1011_??1: Y <= 13'b1011_011_100000;
            // JMP
            7'b1100_??1: Y <= 13'b0100_000_001000;
            // OUT
            7'b1101_??1: Y <= 13'b0000_000_001001;
            // NANDI
            7'b1110_??1: Y <= 13'b0011_100_000010;
            // NANDM
            7'b1111_??1: Y <= 13'b1011_100_100000;
            default: Y <= 13'b1111111111111;
        endcase
//SE ASIGNA Y A LA SALIDA DEL DECODE
    assign controls = Y;
endmodule

//CODIGO FLIP FLOP D DE UN BIT
module FFP1(input wire clk, reset, enable, A, output reg Y);
 always @ (posedge clk or posedge reset) begin
    if (reset)
      Y <= 1'b0;
    else if(enable)
      Y <= A;
  end
endmodule

//CODIGO FLIP FLOP DE 4 BITS
module FFP4(input wire clk, reset, enable, input wire[3:0] A, output reg[3:0] Y);
 always @ (posedge clk or posedge reset) begin
    if (reset)
      Y <= 4'b0000;
    else if(enable)
      Y <= A;
  end
endmodule

//CODIGO DE FLAGS
module FLAGS(input clk, reset, enable, carry, zero, output wire c_flag, z_flag);
//2 FLIPFLOP DE 1 BIT PARA EL c_flag Y EL z_flag
  FFP1 U1(clk, reset, enable, zero, z_flag);
  FFP1 U2(clk, reset, enable, carry, c_flag);
endmodule

//CODIGO DE PHASE
module PHASE(input wire clk, reset, enable, output wire phase);
//SE USA UN FLIPFLOP NEGANDO LA ENTRADA
  FFP1 U1(clk, reset, enable, ~phase, phase);
endmodule

//CODIGO DE RAM
module RAM(input wire cs, we, input wire [11:0]address, inout[3:0] data);
//CODIGO PARA LEER Y ESCRIBIR RAM 
  reg[3:0]memoria[0:4095];
  reg[3:0]data_out;
  assign data = (cs && !we) ? data_out : 4'bz;

  always @ (address or cs or we) begin
    if (cs && !we) begin
      data_out = memoria[address];
    end
  end

  always @ (address or data or cs or we) begin
    if (cs && we) begin
      memoria[address] = data;
    end
  end
endmodule

//CODIGO DE uP
module uP(input wire clock, reset, input wire[3:0] pushbuttons, output wire phase, c_flag, z_flag, output wire[3:0] instr, oprnd, accu, data_bus, FF_out, output wire[7:0] program_byte, output wire[11:0] PC, address_RAM);
  wire Ze, C;
  wire[12:0] controls;
  wire[3:0] a;
  assign address_RAM = {oprnd, program_byte};
  PHASE PHASE1(clock, reset, 1'b1, phase);
  DECODE DECODE1({instr, c_flag, z_flag, phase}, controls);
  FETCH FETCH1(clock, reset, ~phase, program_byte, instr, oprnd);
  PC PC1(clock, reset, controls[12], controls[11], address_RAM, PC);
  BD BD1(controls[1], oprnd, data_bus);
  ROM ROM1(PC, program_byte);
  RAM RAM1(controls[5], controls[4], address_RAM, data_bus);
  FLAGS FLAGS1(clock, reset, controls[9], C, Ze, c_flag, z_flag);
  ALU ALU1(accu, data_bus, {controls[8],controls[7],controls[6]}, C, Ze, a);
  ACCU ACCU1(clock, reset, controls[10], a, accu);
  BD BD2(controls[3], a, data_bus);
  BD BD3(controls[2], pushbuttons, data_bus);
  FFP4 FFP44(clock, reset, controls[0], data_bus, FF_out);
endmodule
