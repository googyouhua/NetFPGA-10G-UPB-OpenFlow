/*
 * Copyright (c) 2014, 2015 Michael Lass
 * bevan@bi-co.net
 *
 * This file is part of the NetFPGA 10G UPB OpenFlow Switch project:
 *
 * Project Group "On-the-Fly Networking for Big Data"
 * SFB 901 "On-The-Fly Computing"
 *
 * University of Paderborn
 * Computer Engineering Group
 * Pohlweg 47 - 49
 * 33098 Paderborn
 * Germany
 *
 * 
 * This file is free code: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 2.1 as
 * published by the Free Software Foundation.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this project. If not, see <http://www.gnu.org/licenses/>.
 * 
 */

`timescale 1ns / 1ps
`include "parameters.v"
`include "tuple_t.v"

module upb_tcam_lookup_tb;

	localparam TCAM_DEPTH = 5;

	// Inputs
	reg CLK;
	reg RST;
	
	tuple_t tuple;

	wire action_match;
   wire action_valid;
   wire [1:0] action_type;
   wire [C_OUT_PORT_WIDTH-1:0] action_port;
   wire [C_OUT_PORT_WIDTH-1:0] action_vport;
   wire [C_MATCH_ADDR_WIDTH-1:0] action_match_addr;
	
   reg s_axi_aresetn;
   reg s_axi_awvalid;
   wire s_axi_awready;
   reg [29:0] s_axi_awaddr;
   reg [2:0] s_axi_awprot;
   reg s_axi_wvalid;
   wire s_axi_wready;
   reg [31:0] s_axi_wdata;
   reg [3:0] s_axi_wstrb;
   wire s_axi_bvalid;
   reg s_axi_bready;
   wire [1:0] s_axi_bresp;
   reg s_axi_arvalid;
   wire s_axi_arready;
   reg [29:0] s_axi_araddr;
   reg [2:0] s_axi_arprot;
   wire s_axi_rvalid;
   reg s_axi_rready;
   wire [31:0] s_axi_rdata;
   wire [1:0] s_axi_rresp;
	
	// helper variables
	logic [31:0] weird_data;
	logic [4:0] counter;
	logic [244:0] matching_content;
	logic [31:0] test_data [63:0];
	wire [31:0] s_axi_araddr_aligned = {s_axi_araddr, 2'b0};
	wire [31:0] s_axi_awaddr_aligned = {s_axi_awaddr, 2'b0};

	// Instantiate the Unit Under Test (UUT)
	upb_tcam_lookup #(
		.DELAY_MATCH(4), // minimum: 1
		.DELAY_LOOKUP(2),  // minimum: 1
		.DELAY_WRITE(1), // minimum: 1
		.FORCE_MUXCY(0),  // force usage of carry chain on current Xilinx devices
		.TCAM_DEPTH(TCAM_DEPTH)   // number of entries (max. 1024)
	) uut (
		.CLK(CLK), 
		.RST(RST), 
		.tuple(tuple),
	 .action_match(action_match),
    .action_valid(action_valid),
    .action_type(action_type),
    .action_port(action_port),
    .action_vport(action_vport),
    .action_match_addr(action_match_addr),
    .s_axi_aclk(CLK),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
   .s_axi_awaddr(s_axi_awaddr_aligned),
   .s_axi_awprot(s_axi_awprot),
   .s_axi_wvalid(s_axi_wvalid),
   .s_axi_wready(s_axi_wready),
   .s_axi_wdata(s_axi_wdata),
   .s_axi_wstrb(s_axi_wstrb),
   .s_axi_bvalid(s_axi_bvalid),
   .s_axi_bready(s_axi_bready),
   .s_axi_bresp(s_axi_bresp),
   .s_axi_arvalid(s_axi_arvalid),
   .s_axi_arready(s_axi_arready),
   .s_axi_araddr(s_axi_araddr_aligned),
   .s_axi_arprot(s_axi_arprot),
   .s_axi_rvalid(s_axi_rvalid),
   .s_axi_rready(s_axi_rready),
   .s_axi_rdata(s_axi_rdata),
   .s_axi_rresp(s_axi_rresp)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RST = 0;
		s_axi_aresetn = 1;
		s_axi_bready = 1; // we do not care about write results
		s_axi_rready = 1; // ready to receive read results

		// Wait 100 ns for global reset to finish
		#100;
        
		// The following test data was generated by a script so
		// we can verify the TCAM behaves like expected
		test_data[0] = 32'h08000000;
		test_data[1] = 32'h00000404;
		test_data[2] = 32'ha0000000;
		test_data[3] = 32'h00000000;
		test_data[4] = 32'h44840000;
		test_data[5] = 32'h00002020;
		test_data[6] = 32'h00000000;
		test_data[7] = 32'h00000000;
		test_data[8] = 32'h004a0000;
		test_data[9] = 32'h00000000;
		test_data[10] = 32'h00200000;
		test_data[11] = 32'h00000000;
		test_data[12] = 32'h00000000;
		test_data[13] = 32'h00000000;
		test_data[14] = 32'h00000000;
		test_data[15] = 32'h00010101;
		test_data[16] = 32'h12000000;
		test_data[17] = 32'h00000000;
		test_data[18] = 32'h00100000;
		test_data[19] = 32'h00000808;
		test_data[20] = 32'h00000000;
		test_data[21] = 32'h01000000;
		test_data[22] = 32'h00000000;
		test_data[23] = 32'h00004040;
		test_data[24] = 32'h00000000;
		test_data[25] = 32'h00000000;
		test_data[26] = 32'h00001010;
		test_data[27] = 32'h00000202;
		test_data[28] = 32'h00000000;
		test_data[29] = 32'h00008080;
		test_data[30] = 32'h00000000;
		test_data[31] = 32'h00000000;
		test_data[32] = 32'h00000100;
		test_data[33] = 32'h00000000;
		test_data[34] = 32'h00000080;
		test_data[35] = 32'h00000000;
		test_data[36] = 32'h00000009;
		test_data[37] = 32'h00000004;
		test_data[38] = 32'h00000000;
		test_data[39] = 32'h00000000;
		test_data[40] = 32'h00000240;
		test_data[41] = 32'h00000002;
		test_data[42] = 32'h00000020;
		test_data[43] = 32'h00000000;
		test_data[44] = 32'h00000000;
		test_data[45] = 32'h00000000;
		test_data[46] = 32'h00000000;
		test_data[47] = 32'h00000000;
		test_data[48] = 32'h00000000;
		test_data[49] = 32'h00000000;
		test_data[50] = 32'h00000010;
		test_data[51] = 32'h00000000;
		test_data[52] = 32'h00000000;
		test_data[53] = 32'h00000000;
		test_data[54] = 32'h00000000;
		test_data[55] = 32'h00000000;
		test_data[56] = 32'h00000000;
		test_data[57] = 32'h00000000;
		test_data[58] = 32'h00000000;
		test_data[59] = 32'h00000000;
		test_data[60] = 32'h00000000;
		test_data[61] = 32'h00000400;
		test_data[62] = 32'h00000000;
		test_data[63] = 32'h0001f800;


		// Write some action into block ram entry 3
		@(posedge CLK)
		s_axi_wdata = 32'h0000dead; // first two bytes are ignored, no wstrb
		s_axi_awaddr = 32'h00002000 + 3;
		s_axi_wvalid = 1;
		s_axi_awvalid = 1;
		fork
		  begin
		    wait(s_axi_wready);
		    @(posedge CLK) s_axi_wvalid = 0;
		  end
		  begin
		    wait(s_axi_awready);
		    @(posedge CLK) s_axi_awvalid = 0;
		  end
		join
		
		// Here we generate some predictable TCAM entry and write it into pos. 3
		weird_data = 1;
		for (int i = 1; i >= 0; i--) begin
			for (int j = 31; j >= 0; j--) begin
				@(posedge CLK)
				if (i == 1) // fill first SRL with ones or tuple will never match, because it is 2 bits short
					s_axi_wdata = {15'b0, 1'b1, weird_data[15:0]}; // first 15 bits ignored because we have only 49 SRLs
				else 
					s_axi_wdata = weird_data;
				s_axi_awaddr = 32'h00001000 + i + 4*3;
				s_axi_wvalid = 1;
				s_axi_awvalid = 1;
				fork
				  begin
				    wait(s_axi_wready);
					 @(posedge CLK) s_axi_wvalid = 0;
				  end
				  begin
				    wait(s_axi_awready);
					 @(posedge CLK) s_axi_awvalid = 0;
				  end
				join
				weird_data = {weird_data[30:0], weird_data[31]}; // some "randomization"
			end
		end
		
		// Mark 0th, 3rd and 4th entry as active
		// Wait for one CLK cycle between wvalid and awvalid. This has to be handled correctly.
		@(posedge CLK)
		s_axi_wdata = 32'b11001;
		s_axi_awaddr = 32'h00003000;
		s_axi_wvalid = 1;
		wait(s_axi_wready);
		@(posedge CLK)
		s_axi_wvalid = 0;
		s_axi_awvalid = 1;
		wait(s_axi_awready);
	   @(posedge CLK)
		s_axi_awvalid = 0;
						
		#25 // wait for change to settle
		
		// generate matching content for tcam entry 3
		// this does not mean much but at least it is predictable
		counter = 15;
		matching_content = 0;
		for (int i = 0; i < 49; i++) begin
			matching_content = (matching_content << 5) + counter;
			counter = counter + 1;
		end

		#25 // wait for change to settle
		
		// Look up matching content
		tuple = {1'b0, matching_content};
		@(posedge CLK)
		tuple.valid = 1;
		@(posedge CLK)
		tuple.valid = 0;
		
		@(action_valid)
		if (action_port == 8'had && action_vport == 8'hde && action_match_addr == 3 && action_match)
			$display("Found correct entry :)");
		else
			$display("ERROR: Entry not found! :(");
		
		// Mark only 0th and 4th entry as active
		@(posedge CLK)
		s_axi_wdata = 32'b10001;
		s_axi_awaddr = 32'h00003000;
		s_axi_wvalid = 1;
		s_axi_awvalid = 1;
		fork
		  begin
		    wait(s_axi_wready);
		    @(posedge CLK) s_axi_wvalid = 0;
		  end
		  begin
		    wait(s_axi_awready);
		    @(posedge CLK) s_axi_awvalid = 0;
		  end
		join
		
		#25 // wait for change to settle
		
		// Look it up again. There should be NO match this time!
		@(posedge CLK)
		tuple.valid = 1;
		@(posedge CLK)
		tuple.valid = 0;
		
		@(action_valid)
		if (action_match)
			$display("ERROR: Found entry that should be deactivated! :(");
		else
			$display("Deactivated entry not found :)");
		
		// write pregenerated content into 4th entry
		for (int i = 0; i < 2; i++) begin
			for (int j = 0; j < 32; j++) begin
				@(posedge CLK)
				s_axi_wdata = test_data[i*32+j];
				s_axi_awaddr = 32'h00001000 + i + 4*4;
				s_axi_wvalid = 1;
				s_axi_awvalid = 1;
				fork
				  begin
					 wait(s_axi_wready);
					 @(posedge CLK) s_axi_wvalid = 0;
				  end
				  begin
					 wait(s_axi_awready);
					 @(posedge CLK) s_axi_awvalid = 0;
				  end
				join
			end
		end
		
		// ... and a corresponding action
		@(posedge CLK)
		s_axi_wdata = 32'h000000ff; // wstrb is ignored anyway
		s_axi_awaddr = 32'h00002000 + 4;
		s_axi_wvalid = 1;
		s_axi_awvalid = 1;
		fork
		  begin
		    wait(s_axi_wready);
		    @(posedge CLK) s_axi_wvalid = 0;
		  end
		  begin
		    wait(s_axi_awready);
		    @(posedge CLK) s_axi_awvalid = 0;
		  end
		join

		#25 // wait for change to settle

		matching_content = 245'haffedeaddeadbeefaffedeaddeadbeef012345678901234567890;

		// Look it up. We expect a match at pos. 4
		tuple = {1'b0, matching_content};
		@(posedge CLK)
		tuple.valid = 1;
		@(posedge CLK)
		tuple.valid = 0;
		@(action_valid)
		if (action_port == 8'hff && action_vport == 8'h00 && action_match_addr == 4 && action_match)
			$display("Found correct entry :)");
		else
			$display("ERROR: Entry not found! :(");
		
		
		// Test read functionality
		s_axi_araddr = 32'h0;
		s_axi_arvalid = 1;
		wait(s_axi_arready);
		@(posedge CLK) s_axi_arvalid = 0;
		wait(s_axi_rvalid);
		@(posedge CLK) $display("Module name: %s", s_axi_rdata);
		
		s_axi_araddr = 32'h2;
		s_axi_arvalid = 1;
		wait(s_axi_arready);
		@(posedge CLK) s_axi_arvalid = 0;
		wait(s_axi_rvalid);
		@(posedge CLK)
		if (s_axi_rdata != TCAM_DEPTH)
			$display("ERROR: Could not readback correct number of entries (%d vs. %d) :(", s_axi_rdata, TCAM_DEPTH);
		else
			$display("Number of entries correct: %d :)", s_axi_rdata);
		
		#100 $stop;

	end
	
	always begin
	  #1 CLK = ~CLK;
	end
      
endmodule
