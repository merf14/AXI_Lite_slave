`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 04:09:27 PM
// Design Name: 
// Module Name: axi_module
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


module axi_module
#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter RESP_WIDTH = 2,
    parameter FIFO_DEPTH= 8 
 )
 (
    input aclk,
    input aresetn,
 
    output logic awready,
    input awvalid,
    input [ADDR_WIDTH-1:0] awaddr,
    
    output logic wready,
    input wvalid,
    input [DATA_WIDTH-1:0] wdata,
    
    output logic bvalid,
    input bready,
    output logic [RESP_WIDTH-1:0] bresp,
    
    output logic aready,
    input arvalid,
    input [ADDR_WIDTH-1:0] araddr,
    
    input rready,
    output logic rvalid,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic [RESP_WIDTH-1:0] rresp,
    
    output logic [ADDR_WIDTH-1:0] awaddr_to_slave,
    output logic awvalid_to_slave,
    input awready_from_slave,
    
    output logic [DATA_WIDTH-1:0] wdata_to_slave,
    output logic wvalid_to_slave,
    input wready_from_slave,
    
    input bvalid_from_slave,
    output logic  bready_to_slave,
    input [RESP_WIDTH-1:0] bresp_from_slave,
    
    output logic [ADDR_WIDTH-1:0] araddr_to_slave,
    output logic arvalid_to_slave,
    input aready_from_slave,
    
    input [DATA_WIDTH-1:0] rdata_from_slave,
    input rvalid_from_slave,
    output logic rready_to_slave,
    input [RESP_WIDTH-1:0] rresp_from_slave
    );

    logic aw_push, aw_pop, aw_full, aw_empty;
    logic w_push, w_pop, w_full, w_empty;
    logic ar_push, ar_pop, ar_full, ar_empty;
    logic r_push, r_pop, r_full, r_empty;
    logic b_empty, b_full;

    //AW channel
    
    assign awvalid_to_slave = ~aw_empty;
    assign awready = ~aw_full;
    assign aw_push = awvalid&&awready&&(~aw_full);
    assign aw_pop = awready_from_slave&&awvalid_to_slave;  
    
    localparam AW_FIFO_WIDTH = ADDR_WIDTH;
    
    fifo
    #(
        .WIDTH(AW_FIFO_WIDTH),
        .DEPTH(FIFO_DEPTH)
     )
    fifo_aw_inst(
        .clk(aclk),
        .aresetn(aresetn),
        .data_in(awaddr),
        .data_out(awaddr_to_slave),
        .full(aw_full),
        .empty(aw_empty),
        .push(aw_push),
        .pop(aw_pop)
        );   
    
    //W channel
    
    assign wvalid_to_slave = ~w_empty;
    assign wready = ~w_full;
    assign w_push = wvalid&&wready&&(~w_full);
    assign w_pop = wready_from_slave&&wvalid_to_slave;   
    
    localparam W_FIFO_WIDTH = DATA_WIDTH;
    
    fifo
    #(
        .WIDTH(W_FIFO_WIDTH),
        .DEPTH(FIFO_DEPTH)
     )
    fifo_w_inst(
        .clk(aclk),
        .aresetn(aresetn),
        .data_in(wdata),
        .data_out(wdata_to_slave),
        .full(w_full),
        .empty(w_empty),
        .push(w_push),
        .pop(w_pop)
        );
    
    //AR channel
    
    assign arvalid_to_slave = ~ar_empty;
    assign aready = ~ar_full;
    assign ar_push = arvalid&&aready&&(~ar_full);
    assign ar_pop = aready_from_slave&&arvalid_to_slave;  
    
    localparam AR_FIFO_WIDTH = ADDR_WIDTH;
    
    fifo
    #(
        .WIDTH(AR_FIFO_WIDTH),
        .DEPTH(FIFO_DEPTH)
     )
    fifo_ar_inst(
        .clk(aclk),
        .aresetn(aresetn),
        .data_in(araddr),
        .data_out(araddr_to_slave),
        .full(ar_full),
        .empty(ar_empty),
        .push(ar_push),
        .pop(ar_pop)
        );  
    
    //R channel
    
    assign rvalid = ~r_empty;
    assign rready_to_slave = ~r_full;
    assign r_push = rvalid_from_slave&&(~r_full);
    assign r_pop = rready&&rvalid;    
    
    localparam R_FIFO_WIDTH = DATA_WIDTH+RESP_WIDTH;
    
    fifo
    #(
        .WIDTH(R_FIFO_WIDTH),
        .DEPTH(FIFO_DEPTH)
     )
    fifo_r_inst(
        .clk(aclk),
        .aresetn(aresetn),
        .data_in({rdata_from_slave,rresp_from_slave}),
        .data_out({rdata,rresp}),
        .full(r_full),
        .empty(r_empty),
        .push(r_push),
        .pop(r_pop)
        );
    
    //B channel
    
    assign bvalid = ~b_empty;
    assign bready_to_slave = ~b_full;
    assign b_push = bvalid_from_slave&&(~b_full);
    assign b_pop = bready&&bvalid; 
    
    localparam B_FIFO_WIDTH = RESP_WIDTH;
    
    fifo
    #(
        .WIDTH(B_FIFO_WIDTH),
        .DEPTH(FIFO_DEPTH)
     )
    fifo_b_inst(
        .clk(aclk),
        .aresetn(aresetn),
        .data_in(bresp_from_slave),
        .data_out(bresp),
        .full(b_full),
        .empty(b_empty),
        .push(b_push),
        .pop(b_pop)
        );
    
endmodule
