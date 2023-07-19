`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2023 03:04:17 PM
// Design Name: 
// Module Name: mult_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mult_control(
 input clk , 
 input reset_a ,
 input start ,
 input [1:0] count ,
 output  [1:0] input_sel ,
 output  [1:0] shift_sel , 
 output  done , 
 output  clk_ena ,
 output  sclr_n 
    );
     
  reg [2:0] Q_reg , Q_next ;
    
  localparam idle = 3'b000 ;
  localparam lsb = 3'b001 ;
  localparam mid = 3'b010 ;
  localparam msb = 3'b011 ;
  localparam clac_done = 3'b100 ;
  localparam err = 3'b101 ;
  
    // state logic 
    
    always @(posedge clk , negedge reset_a)
    begin 
     if (~reset_a)
      Q_reg <= idle ;
      else 
       Q_reg <= Q_next ;
   end
    
    // next state logic 
    always@(*)
     begin
      case(Q_reg)
              idle: if (start)
                    Q_next = lsb ;
                     else 
                     Q_next = idle ; 
              lsb: if (start)
                     if (count == 2'b00)
                          Q_next = mid ;
                           else 
                           Q_next = err ; 
              mid: if (~start )
                      if( count == 2'b01 )
                        Q_next = mid ;
                          else if (~start )
                            if (count == 2'b10)
                            Q_next = msb ; 
                          else
                            Q_next = err ;    
              msb: if (~start )
                     if(count == 2'b11)
                        Q_next = clac_done ;
                         else 
                             Q_next = err ; 
             clac_done: if (~start)
                         Q_next = idle ;
                           else 
                             Q_next = err ;
              err: if (start)
                          Q_next = lsb ;
                           else 
                              Q_next = err ; 
                  default:  Q_next = err ;
               endcase
             end
     
    // output logic 
      
              assign input_sel[1:0] = (Q_reg == lsb || Q_reg == mid || Q_reg == msb ) & ( ~start ) ? count[1:0] : 'bx  ;
              assign shift_sel[1:0] = (Q_reg == lsb | Q_reg == mid | Q_reg == msb ) & (~start) ? ((count[1:0]) > 'b01 ? count[1:0] - 1 : count[1:0] ) : 'bx ;
              assign  done = (Q_reg == clac_done ) & (~start) ? 'b1 : 'b0;
              assign  clk_ena = ((Q_reg == idle | Q_reg == err)&(start))| ((Q_reg == lsb | Q_reg == mid | Q_reg == msb)&(~start)) ? 1'b1 : 'b0 ; 
               assign sclr_n = (start) ? 1'b0 : 'b1 ;                                    
endmodule                                       
