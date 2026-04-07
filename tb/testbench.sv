`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 08:17:26 PM
// Design Name: 
// Module Name: testbench
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


module testbench();

    localparam PERIOD =10;
    localparam HALF_PERIOD = PERIOD/2;
    
    localparam ID_WIDTH = 2;
    localparam ADDR_WIDTH = 8;
    localparam DATA_WIDTH = 8;
    localparam RESP_WIDTH = 2;
    localparam FIFO_DEPTH = 256 ;
    
    logic clk,resetn,awready,awvalid,wready,wvalid,bvalid,bready,aready,arvalid,rready,rvalid;
    logic awvalid_to_slave, awready_from_slave, wvalid_to_slave, wready_from_slave, bvalid_from_slave, bready_to_slave;
    logic arvalid_to_slave, aready_from_slave, rlast_from_slave, rvalid_from_slave, rready_to_slave;
    logic [RESP_WIDTH-1:0] bresp,rresp,bresp_from_slave,rresp_from_slave;
    logic [ADDR_WIDTH-1:0] awaddr,araddr,awaddr_to_slave,araddr_to_slave;
    logic [DATA_WIDTH-1:0] wdata,rdata,wdata_to_slave,rdata_from_slave;
    logic [DATA_WIDTH-1:0] read_data;

    axi_module #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .RESP_WIDTH(RESP_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    )
    axi_dut(
        .aclk(clk),
        .aresetn(resetn),
        
        .awready(awready),
        .awvalid(awvalid),
        .awaddr(awaddr),
            
        .wready(wready),
        .wvalid(wvalid),
        .wdata(wdata),
        
        .bvalid(bvalid),
        .bready(bready),
        .bresp(bresp),
        
        .aready(aready),
        .arvalid(arvalid),
        .araddr(araddr),

        .rready(rready),
        .rvalid(rvalid),
        .rdata(rdata),
        .rresp(rresp),
        
        .awaddr_to_slave(awaddr_to_slave),
        .awvalid_to_slave(awvalid_to_slave),
        .awready_from_slave(awready_from_slave),
        
        .wdata_to_slave(wdata_to_slave),
        .wvalid_to_slave(wvalid_to_slave),
        .wready_from_slave(wready_from_slave),
        
        .bvalid_from_slave(bvalid_from_slave),
        .bready_to_slave(bready_to_slave),
        .bresp_from_slave(bresp_from_slave),
        
        .araddr_to_slave(araddr_to_slave),
        .arvalid_to_slave(arvalid_to_slave),
        .aready_from_slave(aready_from_slave),
        
        .rdata_from_slave(rdata_from_slave),
        .rvalid_from_slave(rvalid_from_slave),
        .rready_to_slave(rready_to_slave),
        .rresp_from_slave(rresp_from_slave)
    );
    
    always #HALF_PERIOD clk=~clk;
    
    initial 
    begin
        clk=0;
        resetn = 0; 
        awvalid=0;
        wvalid=0;
        bready=1;
        arvalid=0;
        rready=0;

        awready_from_slave=0;
        wready_from_slave=0;
        bvalid_from_slave=0;
        aready_from_slave=0;
        rvalid_from_slave=0;
        rlast_from_slave=0;
        
        #PERIOD; 
        #PERIOD;
        resetn = 1;

        #PERIOD; 
        #PERIOD;
        #PERIOD; 
        #PERIOD;
        
    end
    
    task automatic axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            awaddr = addr; 
            awvalid = 1;
            @(posedge clk);
            awvalid = 0;

            wdata = data; 
            wvalid = 1;
            @(posedge clk);
            wvalid = 0;

            //slave response
            bvalid_from_slave = 1; 
            bresp_from_slave =1;
            @(posedge clk);
            bvalid_from_slave = 0;
        end
    endtask

    task automatic axi_read(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            araddr = addr; 
            arvalid = 1;
            @(posedge clk);
            arvalid = 0;

            //slave response
            rvalid_from_slave = 1; 
            rdata_from_slave = data; 
            rresp_from_slave = 0;
            @(posedge clk);
            rvalid_from_slave = 0;
        end
    endtask
    
    initial 
    begin
        #PERIOD; 
        #PERIOD;
        //write transactions
        awready_from_slave=1;
        wready_from_slave=1;
        axi_write(8'h10, 8'hAA);
        
        assert(awaddr_to_slave == 8'h10) else $error("awaddr expected 10 got %h", awaddr_to_slave);
        assert(wdata_to_slave == 8'hAA) else $error("wdata expected AA got %h", wdata_to_slave);
        assert(bresp == 2'b01) else $error("bresp expected 1 got %h", bresp);
        
        awready_from_slave=0;
        wready_from_slave=0;
        axi_write(8'h11, 8'hBB);
        axi_write(8'h12, 8'hCC);
        awready_from_slave=1;
        wready_from_slave=1;
        
        @(posedge clk);
        
        wait (awvalid_to_slave);
        assert(awaddr_to_slave == 8'h11) else $error("awaddr expected 11 got %h", awaddr_to_slave);
        
        wait (wvalid_to_slave);
        assert(wdata_to_slave == 8'hBB) else $error("wdata expected BB got %h", wdata_to_slave);
        
        @(posedge clk);
        
        wait (awvalid_to_slave);
        assert(awaddr_to_slave == 8'h12) else $error("awaddr expected 12 got %h", awaddr_to_slave);
        
        wait (wvalid_to_slave);
        assert(wdata_to_slave == 8'hCC) else $error("wdata expected CC got %h", wdata_to_slave);

        //read transactions
        aready_from_slave=1;
        rready=1;
        
        axi_read(8'h10, 8'hAA);
        assert(araddr_to_slave == 8'h10) else $error("araddr expected 10 got %h", araddr_to_slave);
        @(posedge clk);      
        assert(rdata == 8'hAA) else $error("rdata expected AA got %h", rdata);
        
        $finish;
    end
endmodule