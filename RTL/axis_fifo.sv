`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 10:20:49 PM
// Design Name: 
// Module Name: axis_fifo
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


module axis_fifo
 ( 
 input wire aclk,
 input wire aresetn,
 input wire s_axis_tvalid,
 input wire [7:0] s_axis_tdata,
 input wire s_axis_tkeep,
 input wire s_axis_tlast,
 
 output reg m_axis_tvalid, // output to mux
 output reg [7:0] m_axis_tdata, // output to mux
 output reg m_axis_tkeep, // output to mux
 output reg m_axis_tlast, // output to mux
 input wire m_axis_tready // input from mux
);

reg [7:0] mem_d [16];
reg mem_k [16];
reg mem_l [16];

reg [4:0] wr_ptr;
reg [4:0] rd_ptr;

wire full;
wire empty;
reg [4:0] count;

assign full = (count == 5'd15) ? 1 : 0;
assign empty = (count == 5'd0) ? 1 : 0;

always @(posedge aclk) begin
 if(aresetn == 1'b0) begin
 wr_ptr <= 0;
 rd_ptr <= 0;
 count <= 0;
 m_axis_tvalid <= 1'b0;
 m_axis_tkeep <= 1'b0;
 m_axis_tlast <= 1'b0;
 m_axis_tdata <= 8'h00;
 
 //initialize memory
 for (int i = 0; i < 16; i++) begin
 mem_d[i] <= 8'h00;
 mem_k[i] <= 1'b0;
 mem_l[i] <= 1'b0;
 end
 end
 //update fifo memory
 else if (s_axis_tvalid == 1'b1 && full == 1'b0) begin
 mem_d[wr_ptr] <= s_axis_tdata;
 mem_k[wr_ptr] <= s_axis_tkeep;
 mem_l[wr_ptr] <= s_axis_tlast;
 wr_ptr <= wr_ptr + 1;
 count <= count + 1;
 m_axis_tvalid <= 1'b0;
 m_axis_tkeep <= 1'b0;
 m_axis_tlast <= 1'b0;
 m_axis_tdata <= 8'h00;
 end 
 // Read data from the FIFO if it's not empty and mux is ready
 else if (m_axis_tready == 1'b1 && empty == 1'b0) begin
 m_axis_tdata <= mem_d[rd_ptr] ;
 m_axis_tkeep <= mem_k[rd_ptr];
 m_axis_tlast <= mem_l[rd_ptr];
 m_axis_tvalid <= 1'b1;
 rd_ptr <= rd_ptr + 1;
 count <= count - 1;
 end
end
endmodule


