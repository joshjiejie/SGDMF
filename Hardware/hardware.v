module accelerator_unit # (
	parameter EDGE_W = 48,
	parameter DATA_W = 1024,
	parameter Bank_Num_W = 3,
	parameter ADDR_W = 15,
	parameter PIPE_NUM = 8,
	parameter FIFO_WIDTH = EDGE_W*PIPE_NUM
)(
	input wire 					clk,
	input wire					rst,
	input wire					input_valid,
	input wire	[FIFO_WIDTH-1:0]	input_data,
	input wire					stall_request,
	input wire	[1:0]			buff_sel,
	input wire					r_en,
	input wire					w_en,
	input wire	[ADDR_W-1:0]	r_addr,
	input wire	[ADDR_W-1:0]	w_addr,
	input wire 	[DATA_W-1:0]	input_FV,
	output wire [DATA_W-1:0]	output_FV,
	output wire [31:0]			output_error0,
	output wire [31:0]			output_error1,
	output wire [31:0]			output_error2,
	output wire [31:0]			output_error3,
	output wire [31:0]			output_error4,
	output wire [31:0]			output_error5,
	output wire [31:0]			output_error6,
	output wire [31:0]			output_error7,
	output wire					output_valid0,		
	output wire					output_valid1,
	output wire					output_valid2,		
	output wire					output_valid3,
	output wire					output_valid4,		
	output wire					output_valid5,
	output wire					output_valid6,		
	output wire					output_valid7,
	output wire					inc
);

wire FIFO_empty;
wire FIFO_full;
wire [FIFO_WIDTH-1:0] 	 	 fifo_out;
wire PE_stall;
wire hdu_v_stall;
wire hdu_u_stall;

assign PE_stall = hdu_v_stall || hdu_u_stall || stall_request;
assign inc = ~FIFO_full;
wire bcr_r_en;
wire [FIFO_WIDTH-1:0] 	 pp_input_word;
wire [0:0] 	 			 pp_input_word_valid	[PIPE_NUM-1:0];
reg  [FIFO_WIDTH-1:0] 	 pp_input_word_reg;
reg  [0:0] 	 			 pp_input_word_valid_reg[PIPE_NUM-1:0];

wire [DATA_W-1:0] pp_input_p [PIPE_NUM-1:0];
wire [DATA_W-1:0] pp_input_q [PIPE_NUM-1:0];
wire [DATA_W-1:0] pp_output_p [PIPE_NUM-1:0];
wire [DATA_W-1:0] pp_output_q [PIPE_NUM-1:0];
wire pp_output_valid [PIPE_NUM-1:0];   
wire [31:0] pp_output_error [PIPE_NUM-1:0];   
wire [ADDR_W-1:0] pp_uwaddr [PIPE_NUM-1:0];
wire [ADDR_W-1:0] pp_vwaddr [PIPE_NUM-1:0];

wire [DATA_W-1:0] buf_a_W_Data0,  buf_a_R_Data0;
wire [DATA_W-1:0] buf_b_W_Data0,  buf_b_R_Data0;
wire [DATA_W-1:0] buf_c_W_Data0,  buf_c_R_Data0;
wire [ADDR_W-1:0] buf_a_R_Addr0,  buf_a_W_Addr0;	 	
wire [ADDR_W-1:0] buf_b_R_Addr0,  buf_b_W_Addr0;
wire [ADDR_W-1:0] buf_c_R_Addr0,  buf_c_W_Addr0;
wire buf_a_R_valid0, buf_a_W_valid0, buf_b_R_valid0, buf_b_W_valid0, buf_c_R_valid0, buf_c_W_valid0;

wire [DATA_W-1:0] buf_a_W_Data1,  buf_a_R_Data1;
wire [DATA_W-1:0] buf_b_W_Data1,  buf_b_R_Data1;
wire [DATA_W-1:0] buf_c_W_Data1,  buf_c_R_Data1;
wire [ADDR_W-1:0] buf_a_R_Addr1,  buf_a_W_Addr1;	 	
wire [ADDR_W-1:0] buf_b_R_Addr1,  buf_b_W_Addr1;
wire [ADDR_W-1:0] buf_c_R_Addr1,  buf_c_W_Addr1;
wire buf_a_R_valid1, buf_a_W_valid1, buf_b_R_valid1, buf_b_W_valid1, buf_c_R_valid1, buf_c_W_valid1;

wire [DATA_W-1:0] buf_a_W_Data2,  buf_a_R_Data2;
wire [DATA_W-1:0] buf_b_W_Data2,  buf_b_R_Data2;
wire [DATA_W-1:0] buf_c_W_Data2,  buf_c_R_Data2;
wire [ADDR_W-1:0] buf_a_R_Addr2,  buf_a_W_Addr2;	 	
wire [ADDR_W-1:0] buf_b_R_Addr2,  buf_b_W_Addr2;
wire [ADDR_W-1:0] buf_c_R_Addr2,  buf_c_W_Addr2;
wire buf_a_R_valid2, buf_a_W_valid2, buf_b_R_valid2, buf_b_W_valid2, buf_c_R_valid2, buf_c_W_valid2;

wire [DATA_W-1:0] buf_a_W_Data3,  buf_a_R_Data3;
wire [DATA_W-1:0] buf_b_W_Data3,  buf_b_R_Data3;
wire [DATA_W-1:0] buf_c_W_Data3,  buf_c_R_Data3;
wire [ADDR_W-1:0] buf_a_R_Addr3,  buf_a_W_Addr3;	 	
wire [ADDR_W-1:0] buf_b_R_Addr3,  buf_b_W_Addr3;
wire [ADDR_W-1:0] buf_c_R_Addr3,  buf_c_W_Addr3;
wire buf_a_R_valid3, buf_a_W_valid3, buf_b_R_valid3, buf_b_W_valid3, buf_c_R_valid3, buf_c_W_valid3;

wire [DATA_W-1:0] buf_a_W_Data4,  buf_a_R_Data4;
wire [DATA_W-1:0] buf_b_W_Data4,  buf_b_R_Data4;
wire [DATA_W-1:0] buf_c_W_Data4,  buf_c_R_Data4;
wire [ADDR_W-1:0] buf_a_R_Addr4,  buf_a_W_Addr4;	 	
wire [ADDR_W-1:0] buf_b_R_Addr4,  buf_b_W_Addr4;
wire [ADDR_W-1:0] buf_c_R_Addr4,  buf_c_W_Addr4;
wire buf_a_R_valid4, buf_a_W_valid4, buf_b_R_valid4, buf_b_W_valid4, buf_c_R_valid4, buf_c_W_valid4;

wire [DATA_W-1:0] buf_a_W_Data5,  buf_a_R_Data5;
wire [DATA_W-1:0] buf_b_W_Data5,  buf_b_R_Data5;
wire [DATA_W-1:0] buf_c_W_Data5,  buf_c_R_Data5;
wire [ADDR_W-1:0] buf_a_R_Addr5,  buf_a_W_Addr5;	 	
wire [ADDR_W-1:0] buf_b_R_Addr5,  buf_b_W_Addr5;
wire [ADDR_W-1:0] buf_c_R_Addr5,  buf_c_W_Addr5;
wire buf_a_R_valid5, buf_a_W_valid5, buf_b_R_valid5, buf_b_W_valid5, buf_c_R_valid5, buf_c_W_valid5;

wire [DATA_W-1:0] buf_a_W_Data6,  buf_a_R_Data6;
wire [DATA_W-1:0] buf_b_W_Data6,  buf_b_R_Data6;
wire [DATA_W-1:0] buf_c_W_Data6,  buf_c_R_Data6;
wire [ADDR_W-1:0] buf_a_R_Addr6,  buf_a_W_Addr6;	 	
wire [ADDR_W-1:0] buf_b_R_Addr6,  buf_b_W_Addr6;
wire [ADDR_W-1:0] buf_c_R_Addr6,  buf_c_W_Addr6;
wire buf_a_R_valid6, buf_a_W_valid6, buf_b_R_valid6, buf_b_W_valid6, buf_c_R_valid6, buf_c_W_valid6;

wire [DATA_W-1:0] buf_a_W_Data7,  buf_a_R_Data7;
wire [DATA_W-1:0] buf_b_W_Data7,  buf_b_R_Data7;
wire [DATA_W-1:0] buf_c_W_Data7,  buf_c_R_Data7;
wire [ADDR_W-1:0] buf_a_R_Addr7,  buf_a_W_Addr7;	 	
wire [ADDR_W-1:0] buf_b_R_Addr7,  buf_b_W_Addr7;
wire [ADDR_W-1:0] buf_c_R_Addr7,  buf_c_W_Addr7;
wire buf_a_R_valid7, buf_a_W_valid7, buf_b_R_valid7, buf_b_W_valid7, buf_c_R_valid7, buf_c_W_valid7;

always @(posedge clk) begin
	 if (rst) begin
		 pp_input_word_valid_reg [0] <= 1'b0;		 
		 pp_input_word_valid_reg [1] <= 1'b0;
		 pp_input_word_valid_reg [2] <= 1'b0;		 
		 pp_input_word_valid_reg [3] <= 1'b0;
		 pp_input_word_valid_reg [4] <= 1'b0;		 
		 pp_input_word_valid_reg [5] <= 1'b0;
		 pp_input_word_valid_reg [6] <= 1'b0;		 
		 pp_input_word_valid_reg [7] <= 1'b0;
		 pp_input_word_reg <= {(FIFO_WIDTH){1'b0}};
		end else begin
		 if(PE_stall) begin
			pp_input_word_reg <= pp_input_word_reg;
			pp_input_word_valid_reg [0]<= pp_input_word_valid_reg [0];			 
			pp_input_word_valid_reg [1]<= pp_input_word_valid_reg [1];	
			pp_input_word_valid_reg [2]<= pp_input_word_valid_reg [2];			 
			pp_input_word_valid_reg [3]<= pp_input_word_valid_reg [3];	
			pp_input_word_valid_reg [4]<= pp_input_word_valid_reg [4];			 
			pp_input_word_valid_reg [5]<= pp_input_word_valid_reg [5];	
			pp_input_word_valid_reg [6]<= pp_input_word_valid_reg [6];			 
			pp_input_word_valid_reg [7]<= pp_input_word_valid_reg [7];			
		 end else begin
			pp_input_word_reg <= pp_input_word;
			pp_input_word_valid_reg [0] <= pp_input_word_valid [0];						
			pp_input_word_valid_reg [1] <= pp_input_word_valid [1];	
			pp_input_word_valid_reg [2] <= pp_input_word_valid [2];						
			pp_input_word_valid_reg [3] <= pp_input_word_valid [3];	
			pp_input_word_valid_reg [4] <= pp_input_word_valid [4];						
			pp_input_word_valid_reg [5] <= pp_input_word_valid [5];	
			pp_input_word_valid_reg [6] <= pp_input_word_valid [6];						
			pp_input_word_valid_reg [7] <= pp_input_word_valid [7];
		 end
	end 
 end
	 
fifo #(.FIFO_WIDTH(FIFO_WIDTH)) 
input_FIFO(
	.clk(clk),
	.rst(rst),
	.we(input_valid),
	.din(input_data),
	.re(~PE_stall && bcr_r_en),
	.dout(fifo_out),
	.count(),
	.empty(FIFO_empty),
	.almostempty(),
	.full(FIFO_full),
	.almostfull()
);

bcr #(.FIFO_WIDTH(FIFO_WIDTH), .ADDR_W(ADDR_W), .EDGE_W(EDGE_W), .Bank_Num_W(Bank_Num_W)) BCR(
	.clk(clk),
	.rst(rst),
	.input_valid(~FIFO_empty),
	.input_data(fifo_out),
	.stall(PE_stall),
	.output_data0(pp_input_word[EDGE_W*1-1:EDGE_W*0]),
	.output_valid0(pp_input_word_valid[0]),
	.output_data1(pp_input_word[EDGE_W*2-1:EDGE_W*1]),
	.output_valid1(pp_input_word_valid[1]),
	.output_data2(pp_input_word[EDGE_W*3-1:EDGE_W*2]),
	.output_valid2(pp_input_word_valid[2]),
	.output_data3(pp_input_word[EDGE_W*4-1:EDGE_W*3]),
	.output_valid3(pp_input_word_valid[3]),
	.output_data4(pp_input_word[EDGE_W*5-1:EDGE_W*4]),
	.output_valid4(pp_input_word_valid[4]),
	.output_data5(pp_input_word[EDGE_W*6-1:EDGE_W*5]),
	.output_valid5(pp_input_word_valid[5]),
	.output_data6(pp_input_word[EDGE_W*7-1:EDGE_W*6]),
	.output_valid6(pp_input_word_valid[6]),
	.output_data7(pp_input_word[EDGE_W*8-1:EDGE_W*7]),
	.output_valid7(pp_input_word_valid[7]),
	.inc(bcr_r_en)
);

hdu # (.ADDR_W(ADDR_W),.Bank_Num_W(Bank_Num_W)) HDU_V (
	.clk(clk),
	.rst(rst),
	.Raddr0(pp_input_word[ADDR_W-1+EDGE_W*0:EDGE_W*0]),
	.Raddr1(pp_input_word[ADDR_W-1+EDGE_W*1:EDGE_W*1]),		
	.Raddr2(pp_input_word[ADDR_W-1+EDGE_W*2:EDGE_W*2]),
	.Raddr3(pp_input_word[ADDR_W-1+EDGE_W*3:EDGE_W*3]),
	.Raddr4(pp_input_word[ADDR_W-1+EDGE_W*4:EDGE_W*4]),
	.Raddr5(pp_input_word[ADDR_W-1+EDGE_W*5:EDGE_W*5]),		
	.Raddr6(pp_input_word[ADDR_W-1+EDGE_W*6:EDGE_W*6]),
	.Raddr7(pp_input_word[ADDR_W-1+EDGE_W*7:EDGE_W*7]),
	.Waddr0(pp_vwaddr[0]),
	.Waddr1(pp_vwaddr[1]),	
	.Waddr2(pp_vwaddr[2]),
	.Waddr3(pp_vwaddr[3]),
	.Waddr4(pp_vwaddr[4]),
	.Waddr5(pp_vwaddr[5]),	
	.Waddr6(pp_vwaddr[6]),
	.Waddr7(pp_vwaddr[7]),	
	.Raddr_valid0(pp_input_word_valid[0]),	
	.Raddr_valid1(pp_input_word_valid[1]),
	.Raddr_valid2(pp_input_word_valid[2]),	
	.Raddr_valid3(pp_input_word_valid[3]),
	.Raddr_valid4(pp_input_word_valid[4]),	
	.Raddr_valid5(pp_input_word_valid[5]),
	.Raddr_valid6(pp_input_word_valid[6]),	
	.Raddr_valid7(pp_input_word_valid[7]),	
	.Waddr_valid0(pp_output_valid[0]),	
	.Waddr_valid1(pp_output_valid[1]),	
	.Waddr_valid2(pp_output_valid[2]),	
	.Waddr_valid3(pp_output_valid[3]),	
	.Waddr_valid4(pp_output_valid[4]),	
	.Waddr_valid5(pp_output_valid[5]),	
	.Waddr_valid6(pp_output_valid[6]),	
	.Waddr_valid7(pp_output_valid[7]),
	.stall_signal(hdu_v_stall)	
);

hdu # (.ADDR_W(ADDR_W),.Bank_Num_W(Bank_Num_W)) HDU_U (
	.clk(clk),
	.rst(rst),
	.Raddr0(pp_input_word[ADDR_W*2-1+EDGE_W*0:ADDR_W+EDGE_W*0]),	
	.Raddr1(pp_input_word[ADDR_W*2-1+EDGE_W*1:ADDR_W+EDGE_W*1]),		
	.Raddr2(pp_input_word[ADDR_W*2-1+EDGE_W*2:ADDR_W+EDGE_W*2]),	
	.Raddr3(pp_input_word[ADDR_W*2-1+EDGE_W*3:ADDR_W+EDGE_W*3]),
	.Raddr4(pp_input_word[ADDR_W*2-1+EDGE_W*4:ADDR_W+EDGE_W*4]),	
	.Raddr5(pp_input_word[ADDR_W*2-1+EDGE_W*5:ADDR_W+EDGE_W*5]),		
	.Raddr6(pp_input_word[ADDR_W*2-1+EDGE_W*6:ADDR_W+EDGE_W*6]),	
	.Raddr7(pp_input_word[ADDR_W*2-1+EDGE_W*7:ADDR_W+EDGE_W*7]),		
	.Waddr0(pp_uwaddr[0]),
	.Waddr1(pp_uwaddr[1]),
	.Waddr2(pp_uwaddr[2]),
	.Waddr3(pp_uwaddr[3]),	
	.Waddr4(pp_uwaddr[4]),
	.Waddr5(pp_uwaddr[5]),
	.Waddr6(pp_uwaddr[6]),
	.Waddr7(pp_uwaddr[7]),	
	.Raddr_valid0(pp_input_word_valid[0]),	
	.Raddr_valid1(pp_input_word_valid[1]),	
	.Raddr_valid2(pp_input_word_valid[2]),	
	.Raddr_valid3(pp_input_word_valid[3]),
	.Raddr_valid4(pp_input_word_valid[4]),	
	.Raddr_valid5(pp_input_word_valid[5]),	
	.Raddr_valid6(pp_input_word_valid[6]),	
	.Raddr_valid7(pp_input_word_valid[7]),	
	.Waddr_valid0(pp_output_valid[0]),	
	.Waddr_valid1(pp_output_valid[1]),
	.Waddr_valid2(pp_output_valid[2]),	
	.Waddr_valid3(pp_output_valid[3]),	
	.Waddr_valid4(pp_output_valid[4]),	
	.Waddr_valid5(pp_output_valid[5]),
	.Waddr_valid6(pp_output_valid[6]),	
	.Waddr_valid7(pp_output_valid[7]),
	.stall_signal(hdu_u_stall)	
);
	
assign buf_a_R_valid0 = (buff_sel==2'b11) ? r_en : pp_input_word_valid[0];
assign buf_b_R_valid0 = (buff_sel==2'b10) ? r_en : pp_input_word_valid[0];
assign buf_c_R_valid0 = (buff_sel==2'b00) ? r_en : (buff_sel==2'b01) ? r_en : pp_input_word_valid[0];
assign buf_a_W_valid0 = (buff_sel==2'b11) ? w_en : pp_output_valid [0];
assign buf_b_W_valid0 = (buff_sel==2'b10) ? w_en : pp_output_valid [0];
assign buf_c_W_valid0 = (buff_sel==2'b00) ? w_en : (buff_sel==2'b01) ? w_en : pp_output_valid [0];
assign buf_a_R_Addr0 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*0:ADDR_W+EDGE_W*0];
assign buf_b_R_Addr0 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*0:EDGE_W*0];
assign buf_c_R_Addr0 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1:ADDR_W] : pp_input_word[ADDR_W-1:0];
assign pp_input_p [0] = (buff_sel==2'b11) ? buf_c_R_Data0 : buf_a_R_Data0;
assign pp_input_q [0] = (buff_sel==2'b10) ? buf_c_R_Data0 : buf_b_R_Data0;
assign buf_a_W_Data0 = (buff_sel==2'b11) ? input_FV : pp_output_p [0];
assign buf_b_W_Data0 = (buff_sel==2'b10) ? input_FV : pp_output_q [0];
assign buf_c_W_Data0 = (buff_sel==2'b11) ? pp_output_p [0]: (buff_sel==2'b10) ? pp_output_q [0]: input_FV;
assign buf_a_W_Addr0 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [0];
assign buf_b_W_Addr0 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [0];
assign buf_c_W_Addr0 = (buff_sel==2'b11) ? pp_uwaddr [0] : (buff_sel==2'b10) ? pp_vwaddr [0] : w_addr;
assign output_FV = (buff_sel==2'b00) ? buf_c_R_Data0 : (buff_sel==2'b01) ? buf_c_R_Data0 : (buff_sel==2'b11) ? buf_a_R_Data0 : buf_b_R_Data0;
assign buf_a_R_valid1 = (buff_sel==2'b11) ? 1'b0 : pp_input_word_valid[1];
assign buf_b_R_valid1 = (buff_sel==2'b10) ? 1'b0 : pp_input_word_valid[1];
assign buf_c_R_valid1 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? 1'b0 : pp_input_word_valid[1];
assign buf_a_W_valid1 = (buff_sel==2'b11) ? 1'b0 : pp_output_valid [1];
assign buf_b_W_valid1 = (buff_sel==2'b10) ? 1'b0 : pp_output_valid [1];
assign buf_c_W_valid1 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? w_en : pp_output_valid [1];
assign buf_a_R_Addr1 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*1:ADDR_W+EDGE_W*1];
assign buf_b_R_Addr1 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*1:EDGE_W*1];
assign buf_c_R_Addr1 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1+EDGE_W*1:ADDR_W+EDGE_W*1] : pp_input_word[ADDR_W-1+EDGE_W*1:EDGE_W*1];
assign pp_input_p [1] = (buff_sel==2'b11) ? buf_c_R_Data1 : buf_a_R_Data1;
assign pp_input_q [1] = (buff_sel==2'b10) ? buf_c_R_Data1 : buf_b_R_Data1;
assign buf_a_W_Data1 = (buff_sel==2'b11) ? {DATA_W{1'b1}} : pp_output_p [1];
assign buf_b_W_Data1 = (buff_sel==2'b10) ? {DATA_W{1'b1}} : pp_output_q [1];
assign buf_c_W_Data1 = (buff_sel==2'b11) ? pp_output_p [1]: (buff_sel==2'b10) ? pp_output_q [1]: {DATA_W{1'b1}};
assign buf_a_W_Addr1 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [1];
assign buf_b_W_Addr1 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [1];
assign buf_c_W_Addr1 = (buff_sel==2'b11) ? pp_uwaddr [1] : (buff_sel==2'b10) ? pp_vwaddr [1] : w_addr;

assign buf_a_R_valid2 = (buff_sel==2'b11) ? 1'b0 : pp_input_word_valid[2];
assign buf_b_R_valid2 = (buff_sel==2'b10) ? 1'b0 : pp_input_word_valid[2];
assign buf_c_R_valid2 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? 1'b0 : pp_input_word_valid[2];
assign buf_a_W_valid2 = (buff_sel==2'b11) ? 1'b0 : pp_output_valid [2];
assign buf_b_W_valid2 = (buff_sel==2'b10) ? 1'b0 : pp_output_valid [2];
assign buf_c_W_valid2 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? w_en : pp_output_valid [2];
assign buf_a_R_Addr2 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*2:ADDR_W+EDGE_W*2];
assign buf_b_R_Addr2 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*2:EDGE_W*2];
assign buf_c_R_Addr2 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1+EDGE_W*2:ADDR_W+EDGE_W*2] : pp_input_word[ADDR_W-1+EDGE_W*2:EDGE_W*2];
assign pp_input_p [2] = (buff_sel==2'b11) ? buf_c_R_Data2 : buf_a_R_Data2;
assign pp_input_q [2] = (buff_sel==2'b10) ? buf_c_R_Data2 : buf_b_R_Data2;
assign buf_a_W_Data2 = (buff_sel==2'b11) ? {DATA_W{1'b1}} : pp_output_p [2];
assign buf_b_W_Data2 = (buff_sel==2'b10) ? {DATA_W{1'b1}} : pp_output_q [2];
assign buf_c_W_Data2 = (buff_sel==2'b11) ? pp_output_p [2]: (buff_sel==2'b10) ? pp_output_q [2]: {DATA_W{1'b1}};
assign buf_a_W_Addr2 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [2];
assign buf_b_W_Addr2 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [2];
assign buf_c_W_Addr2 = (buff_sel==2'b11) ? pp_uwaddr [2] : (buff_sel==2'b10) ? pp_vwaddr [2] : w_addr;

assign buf_a_R_valid3 = (buff_sel==2'b11) ? 1'b0 : pp_input_word_valid[3];
assign buf_b_R_valid3 = (buff_sel==2'b10) ? 1'b0 : pp_input_word_valid[3];
assign buf_c_R_valid3 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? 1'b0 : pp_input_word_valid[3];
assign buf_a_W_valid3 = (buff_sel==2'b11) ? 1'b0 : pp_output_valid [3];
assign buf_b_W_valid3 = (buff_sel==2'b10) ? 1'b0 : pp_output_valid [3];
assign buf_c_W_valid3 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? w_en : pp_output_valid [3];
assign buf_a_R_Addr3 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*3:ADDR_W+EDGE_W*3];
assign buf_b_R_Addr3 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*3:EDGE_W*3];
assign buf_c_R_Addr3 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1+EDGE_W*3:ADDR_W+EDGE_W*3] : pp_input_word[ADDR_W-1+EDGE_W*3:EDGE_W*3];
assign pp_input_p [3] = (buff_sel==2'b11) ? buf_c_R_Data3 : buf_a_R_Data3;
assign pp_input_q [3] = (buff_sel==2'b10) ? buf_c_R_Data3 : buf_b_R_Data3;
assign buf_a_W_Data3 = (buff_sel==2'b11) ? {DATA_W{1'b1}} : pp_output_p [3];
assign buf_b_W_Data3 = (buff_sel==2'b10) ? {DATA_W{1'b1}} : pp_output_q [3];
assign buf_c_W_Data3 = (buff_sel==2'b11) ? pp_output_p [3]: (buff_sel==2'b10) ? pp_output_q [3]: {DATA_W{1'b1}};
assign buf_a_W_Addr3 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [3];
assign buf_b_W_Addr3 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [3];
assign buf_c_W_Addr3 = (buff_sel==2'b11) ? pp_uwaddr [3] : (buff_sel==2'b10) ? pp_vwaddr [3] : w_addr;

assign buf_a_R_valid4 = (buff_sel==2'b11) ? 1'b0 : pp_input_word_valid[4];
assign buf_b_R_valid4 = (buff_sel==2'b10) ? 1'b0 : pp_input_word_valid[4];
assign buf_c_R_valid4 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? 1'b0 : pp_input_word_valid[4];
assign buf_a_W_valid4 = (buff_sel==2'b11) ? 1'b0 : pp_output_valid [4];
assign buf_b_W_valid4 = (buff_sel==2'b10) ? 1'b0 : pp_output_valid [4];
assign buf_c_W_valid4 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? w_en : pp_output_valid [4];
assign buf_a_R_Addr4 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*4:ADDR_W+EDGE_W*4];
assign buf_b_R_Addr4 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*4:EDGE_W*4];
assign buf_c_R_Addr4 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1+EDGE_W*4:ADDR_W+EDGE_W*4] : pp_input_word[ADDR_W-1+EDGE_W*4:EDGE_W*4];
assign pp_input_p [4] = (buff_sel==2'b11) ? buf_c_R_Data4 : buf_a_R_Data4;
assign pp_input_q [4] = (buff_sel==2'b10) ? buf_c_R_Data4 : buf_b_R_Data4;
assign buf_a_W_Data4 = (buff_sel==2'b11) ? {DATA_W{1'b1}} : pp_output_p [4];
assign buf_b_W_Data4 = (buff_sel==2'b10) ? {DATA_W{1'b1}} : pp_output_q [4];
assign buf_c_W_Data4 = (buff_sel==2'b11) ? pp_output_p [4]: (buff_sel==2'b10) ? pp_output_q [4]: {DATA_W{1'b1}};
assign buf_a_W_Addr4 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [4];
assign buf_b_W_Addr4 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [4];
assign buf_c_W_Addr4 = (buff_sel==2'b11) ? pp_uwaddr [4] : (buff_sel==2'b10) ? pp_vwaddr [4] : w_addr;

assign buf_a_R_valid5 = (buff_sel==2'b11) ? 1'b0 : pp_input_word_valid[5];
assign buf_b_R_valid5 = (buff_sel==2'b10) ? 1'b0 : pp_input_word_valid[5];
assign buf_c_R_valid5 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? 1'b0 : pp_input_word_valid[5];
assign buf_a_W_valid5 = (buff_sel==2'b11) ? 1'b0 : pp_output_valid [5];
assign buf_b_W_valid5 = (buff_sel==2'b10) ? 1'b0 : pp_output_valid [5];
assign buf_c_W_valid5 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? w_en : pp_output_valid [5];
assign buf_a_R_Addr5 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*5:ADDR_W+EDGE_W*5];
assign buf_b_R_Addr5 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*5:EDGE_W*5];
assign buf_c_R_Addr5 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1+EDGE_W*5:ADDR_W+EDGE_W*5] : pp_input_word[ADDR_W-1+EDGE_W*5:EDGE_W*5];
assign pp_input_p [5] = (buff_sel==2'b11) ? buf_c_R_Data5 : buf_a_R_Data5;
assign pp_input_q [5] = (buff_sel==2'b10) ? buf_c_R_Data5 : buf_b_R_Data5;
assign buf_a_W_Data5 = (buff_sel==2'b11) ? {DATA_W{1'b1}} : pp_output_p [5];
assign buf_b_W_Data5 = (buff_sel==2'b10) ? {DATA_W{1'b1}} : pp_output_q [5];
assign buf_c_W_Data5 = (buff_sel==2'b11) ? pp_output_p [5]: (buff_sel==2'b10) ? pp_output_q [5]: {DATA_W{1'b1}};
assign buf_a_W_Addr5 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [5];
assign buf_b_W_Addr5 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [5];
assign buf_c_W_Addr5 = (buff_sel==2'b11) ? pp_uwaddr [5] : (buff_sel==2'b10) ? pp_vwaddr [5] : w_addr;

assign buf_a_R_valid6 = (buff_sel==2'b11) ? 1'b0 : pp_input_word_valid[6];
assign buf_b_R_valid6 = (buff_sel==2'b10) ? 1'b0 : pp_input_word_valid[6];
assign buf_c_R_valid6 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? 1'b0 : pp_input_word_valid[6];
assign buf_a_W_valid6 = (buff_sel==2'b11) ? 1'b0 : pp_output_valid [6];
assign buf_b_W_valid6 = (buff_sel==2'b10) ? 1'b0 : pp_output_valid [6];
assign buf_c_W_valid6 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? w_en : pp_output_valid [6];
assign buf_a_R_Addr6 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*6:ADDR_W+EDGE_W*6];
assign buf_b_R_Addr6 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*6:EDGE_W*6];
assign buf_c_R_Addr6 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1+EDGE_W*6:ADDR_W+EDGE_W*6] : pp_input_word[ADDR_W-1+EDGE_W*6:EDGE_W*6];
assign pp_input_p [6] = (buff_sel==2'b11) ? buf_c_R_Data6 : buf_a_R_Data6;
assign pp_input_q [6] = (buff_sel==2'b10) ? buf_c_R_Data6 : buf_b_R_Data6;
assign buf_a_W_Data6 = (buff_sel==2'b11) ? {DATA_W{1'b1}} : pp_output_p [6];
assign buf_b_W_Data6 = (buff_sel==2'b10) ? {DATA_W{1'b1}} : pp_output_q [6];
assign buf_c_W_Data6 = (buff_sel==2'b11) ? pp_output_p [6]: (buff_sel==2'b10) ? pp_output_q [6]: {DATA_W{1'b1}};
assign buf_a_W_Addr6 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [6];
assign buf_b_W_Addr6 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [6];
assign buf_c_W_Addr6 = (buff_sel==2'b11) ? pp_uwaddr [6] : (buff_sel==2'b10) ? pp_vwaddr [6] : w_addr;

assign buf_a_R_valid7 = (buff_sel==2'b11) ? 1'b0 : pp_input_word_valid[7];
assign buf_b_R_valid7 = (buff_sel==2'b10) ? 1'b0 : pp_input_word_valid[7];
assign buf_c_R_valid7 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? 1'b0 : pp_input_word_valid[7];
assign buf_a_W_valid7 = (buff_sel==2'b11) ? 1'b0 : pp_output_valid [7];
assign buf_b_W_valid7 = (buff_sel==2'b10) ? 1'b0 : pp_output_valid [7];
assign buf_c_W_valid7 = (buff_sel==2'b00) ? 1'b0 : (buff_sel==2'b01) ? w_en : pp_output_valid [7];
assign buf_a_R_Addr7 = (buff_sel==2'b11) ? r_addr : pp_input_word[ADDR_W*2-1+EDGE_W*7:ADDR_W+EDGE_W*7];
assign buf_b_R_Addr7 = (buff_sel==2'b10) ? r_addr : pp_input_word[ADDR_W-1+EDGE_W*7:EDGE_W*7];
assign buf_c_R_Addr7 = (buff_sel==2'b00) ? r_addr : (buff_sel==2'b01) ? r_addr : (buff_sel==2'b11) ? pp_input_word[ADDR_W*2-1+EDGE_W*7:ADDR_W+EDGE_W*7] : pp_input_word[ADDR_W-1+EDGE_W*7:EDGE_W*7];
assign pp_input_p [7] = (buff_sel==2'b11) ? buf_c_R_Data7 : buf_a_R_Data7;
assign pp_input_q [7] = (buff_sel==2'b10) ? buf_c_R_Data7 : buf_b_R_Data7;
assign buf_a_W_Data7 = (buff_sel==2'b11) ? {DATA_W{1'b1}} : pp_output_p [7];
assign buf_b_W_Data7 = (buff_sel==2'b10) ? {DATA_W{1'b1}} : pp_output_q [7];
assign buf_c_W_Data7 = (buff_sel==2'b11) ? pp_output_p [7]: (buff_sel==2'b10) ? pp_output_q [7]: {DATA_W{1'b1}};
assign buf_a_W_Addr7 = (buff_sel==2'b11) ? w_addr : pp_uwaddr [7];
assign buf_b_W_Addr7 = (buff_sel==2'b10) ? w_addr : pp_vwaddr [7];
assign buf_c_W_Addr7 = (buff_sel==2'b11) ? pp_uwaddr [7] : (buff_sel==2'b10) ? pp_vwaddr [7] : w_addr;

assign output_error0 = pp_output_error [0];
assign output_error1 = pp_output_error [1];
assign output_error2 = pp_output_error [2];
assign output_error3 = pp_output_error [3];
assign output_error4 = pp_output_error [4];
assign output_error5 = pp_output_error [5];
assign output_error6 = pp_output_error [6];
assign output_error7 = pp_output_error [7];
assign output_valid0 = pp_output_valid [0];
assign output_valid1 = pp_output_valid [1];
assign output_valid2 = pp_output_valid [2];
assign output_valid3 = pp_output_valid [3];
assign output_valid4 = pp_output_valid [4];
assign output_valid5 = pp_output_valid [5];
assign output_valid6 = pp_output_valid [6];
assign output_valid7 = pp_output_valid [7];

buffer # (.DATA_W(DATA_W), .ADDR_W(ADDR_W), .Bank_Num_W(Bank_Num_W)) buf_a(	
	.clk(clk),
	.rst(rst),
	.R_Addr0(buf_a_R_Addr0),
	.R_Addr1(buf_a_R_Addr1),	
	.R_Addr2(buf_a_R_Addr2),
	.R_Addr3(buf_a_R_Addr3),
	.R_Addr4(buf_a_R_Addr4),
	.R_Addr5(buf_a_R_Addr5),	
	.R_Addr6(buf_a_R_Addr6),
	.R_Addr7(buf_a_R_Addr7),
	.W_Addr0(buf_a_W_Addr0),	
	.W_Addr1(buf_a_W_Addr1),
	.W_Addr2(buf_a_W_Addr2),	
	.W_Addr3(buf_a_W_Addr3),
	.W_Addr4(buf_a_W_Addr4),	
	.W_Addr5(buf_a_W_Addr5),
	.W_Addr6(buf_a_W_Addr6),	
	.W_Addr7(buf_a_W_Addr7),
	.W_Data0(buf_a_W_Data0),	
	.W_Data1(buf_a_W_Data1),	
	.W_Data2(buf_a_W_Data2),	
	.W_Data3(buf_a_W_Data3),
	.W_Data4(buf_a_W_Data4),	
	.W_Data5(buf_a_W_Data5),	
	.W_Data6(buf_a_W_Data6),	
	.W_Data7(buf_a_W_Data7),	
	.R_valid0(buf_a_R_valid0),		
	.R_valid1(buf_a_R_valid1),		
	.R_valid2(buf_a_R_valid2),		
	.R_valid3(buf_a_R_valid3),	
	.R_valid4(buf_a_R_valid4),		
	.R_valid5(buf_a_R_valid5),		
	.R_valid6(buf_a_R_valid6),		
	.R_valid7(buf_a_R_valid7),		
	.W_valid0(buf_a_W_valid0),		
	.W_valid1(buf_a_W_valid1),
	.W_valid2(buf_a_W_valid2),		
	.W_valid3(buf_a_W_valid3),		
	.W_valid4(buf_a_W_valid4),		
	.W_valid5(buf_a_W_valid5),
	.W_valid6(buf_a_W_valid6),		
	.W_valid7(buf_a_W_valid7),		
	.R_Data0(buf_a_R_Data0),	
	.R_Data1(buf_a_R_Data1),
	.R_Data2(buf_a_R_Data2),	
	.R_Data3(buf_a_R_Data3),
	.R_Data4(buf_a_R_Data4),	
	.R_Data5(buf_a_R_Data5),
	.R_Data6(buf_a_R_Data6),	
	.R_Data7(buf_a_R_Data7)	
);

buffer # (.DATA_W(DATA_W), .ADDR_W(ADDR_W), .Bank_Num_W(Bank_Num_W)) buf_b(	
	.clk(clk),
	.rst(rst),
	.R_Addr0(buf_b_R_Addr0),
	.R_Addr1(buf_b_R_Addr1),	
	.R_Addr2(buf_b_R_Addr2),
	.R_Addr3(buf_b_R_Addr3),
	.R_Addr4(buf_b_R_Addr4),
	.R_Addr5(buf_b_R_Addr5),	
	.R_Addr6(buf_b_R_Addr6),
	.R_Addr7(buf_b_R_Addr7),
	.W_Addr0(buf_b_W_Addr0),	
	.W_Addr1(buf_b_W_Addr1),
	.W_Addr2(buf_b_W_Addr2),	
	.W_Addr3(buf_b_W_Addr3),
	.W_Addr4(buf_b_W_Addr4),	
	.W_Addr5(buf_b_W_Addr5),
	.W_Addr6(buf_b_W_Addr6),	
	.W_Addr7(buf_b_W_Addr7),
	.W_Data0(buf_b_W_Data0),	
	.W_Data1(buf_b_W_Data1),	
	.W_Data2(buf_b_W_Data2),	
	.W_Data3(buf_b_W_Data3),
	.W_Data4(buf_b_W_Data4),	
	.W_Data5(buf_b_W_Data5),	
	.W_Data6(buf_b_W_Data6),	
	.W_Data7(buf_b_W_Data7),	
	.R_valid0(buf_b_R_valid0),		
	.R_valid1(buf_b_R_valid1),		
	.R_valid2(buf_b_R_valid2),		
	.R_valid3(buf_b_R_valid3),	
	.R_valid4(buf_b_R_valid4),		
	.R_valid5(buf_b_R_valid5),		
	.R_valid6(buf_b_R_valid6),		
	.R_valid7(buf_b_R_valid7),		
	.W_valid0(buf_b_W_valid0),		
	.W_valid1(buf_b_W_valid1),
	.W_valid2(buf_b_W_valid2),		
	.W_valid3(buf_b_W_valid3),		
	.W_valid4(buf_b_W_valid4),		
	.W_valid5(buf_b_W_valid5),
	.W_valid6(buf_b_W_valid6),		
	.W_valid7(buf_b_W_valid7),		
	.R_Data0(buf_b_R_Data0),	
	.R_Data1(buf_b_R_Data1),
	.R_Data2(buf_b_R_Data2),	
	.R_Data3(buf_b_R_Data3),
	.R_Data4(buf_b_R_Data4),	
	.R_Data5(buf_b_R_Data5),
	.R_Data6(buf_b_R_Data6),	
	.R_Data7(buf_b_R_Data7)	
);

buffer # (.DATA_W(DATA_W), .ADDR_W(ADDR_W), .Bank_Num_W(Bank_Num_W)) buf_c(	
	.clk(clk),
	.rst(rst),
	.R_Addr0(buf_c_R_Addr0),
	.R_Addr1(buf_c_R_Addr1),	
	.R_Addr2(buf_c_R_Addr2),
	.R_Addr3(buf_c_R_Addr3),
	.R_Addr4(buf_c_R_Addr4),
	.R_Addr5(buf_c_R_Addr5),	
	.R_Addr6(buf_c_R_Addr6),
	.R_Addr7(buf_c_R_Addr7),
	.W_Addr0(buf_c_W_Addr0),	
	.W_Addr1(buf_c_W_Addr1),
	.W_Addr2(buf_c_W_Addr2),	
	.W_Addr3(buf_c_W_Addr3),
	.W_Addr4(buf_c_W_Addr4),	
	.W_Addr5(buf_c_W_Addr5),
	.W_Addr6(buf_c_W_Addr6),	
	.W_Addr7(buf_c_W_Addr7),
	.W_Data0(buf_c_W_Data0),	
	.W_Data1(buf_c_W_Data1),	
	.W_Data2(buf_c_W_Data2),	
	.W_Data3(buf_c_W_Data3),
	.W_Data4(buf_c_W_Data4),	
	.W_Data5(buf_c_W_Data5),	
	.W_Data6(buf_c_W_Data6),	
	.W_Data7(buf_c_W_Data7),	
	.R_valid0(buf_c_R_valid0),		
	.R_valid1(buf_c_R_valid1),		
	.R_valid2(buf_c_R_valid2),		
	.R_valid3(buf_c_R_valid3),	
	.R_valid4(buf_c_R_valid4),		
	.R_valid5(buf_c_R_valid5),		
	.R_valid6(buf_c_R_valid6),		
	.R_valid7(buf_c_R_valid7),		
	.W_valid0(buf_c_W_valid0),		
	.W_valid1(buf_c_W_valid1),
	.W_valid2(buf_c_W_valid2),		
	.W_valid3(buf_c_W_valid3),		
	.W_valid4(buf_c_W_valid4),		
	.W_valid5(buf_c_W_valid5),
	.W_valid6(buf_c_W_valid6),		
	.W_valid7(buf_c_W_valid7),		
	.R_Data0(buf_c_R_Data0),	
	.R_Data1(buf_c_R_Data1),
	.R_Data2(buf_c_R_Data2),	
	.R_Data3(buf_c_R_Data3),
	.R_Data4(buf_c_R_Data4),	
	.R_Data5(buf_c_R_Data5),
	.R_Data6(buf_c_R_Data6),	
	.R_Data7(buf_c_R_Data7)	
);

genvar numpp; 
generate for(numpp=0; numpp < PIPE_NUM; numpp = numpp+1) 
	begin: elements
		processing_pipeline # (.ADDR_W(ADDR_W), .EDGE_W(EDGE_W), .Pipeline_Depth(27), .DATA_W(DATA_W))
		pp (
			.clk(clk),
			.rst(rst),
			.Uid_in(pp_input_word_reg[ADDR_W*2-1+EDGE_W*numpp:ADDR_W+EDGE_W*numpp]),
			.Vid_in(pp_input_word_reg[ADDR_W-1+EDGE_W*numpp:EDGE_W*numpp]),
			.rating(pp_input_word_reg[EDGE_W-1+EDGE_W*numpp:EDGE_W-16+EDGE_W*numpp]),
			.input_valid(pp_input_word_valid_reg[numpp]),
			.p(pp_input_p[numpp]),    
			.q(pp_input_q[numpp]),		
			.p_new(pp_output_p[numpp]),
			.q_new(pp_output_q[numpp]),	
			.output_valid(pp_output_valid[numpp]),
			.Ubuf_waddr(pp_uwaddr[numpp]),
			.Vbuf_waddr(pp_vwaddr[numpp]),
			.total_err(pp_output_error[numpp])
		);
	end
endgenerate	

endmodule

module processing_pipeline # (
	parameter ADDR_W = 16,
	parameter EDGE_W = 64,
	parameter Pipeline_Depth = 27,
	parameter DATA_W = 1024
)(
	input   wire 	clk,
	input   wire 	rst,
	input   wire 	[ADDR_W-1:0] Uid_in,
	input   wire 	[ADDR_W-1:0] Vid_in,
	input   wire 	[15:0] rating,
	input   wire 	input_valid,
	input 	wire 	[DATA_W-1:0] p,    
    input 	wire 	[DATA_W-1:0] q,		
	output 	wire 	[DATA_W-1:0] p_new,
	output 	wire 	[DATA_W-1:0] q_new,	
	output  wire 	output_valid,
	output  wire 	[ADDR_W-1:0] Ubuf_waddr,
	output  wire 	[ADDR_W-1:0] Vbuf_waddr,
	output 	wire	[31:0]       total_err
);	
	wire	u_flag, u_flag_valid, v_flag, v_flag_valid, pcu_output_valid;
	reg		[ADDR_W-1:0] 	Uid_shift_reg [Pipeline_Depth-1:0]; 
	reg		[ADDR_W-1:0] 	Vid_shift_reg [Pipeline_Depth-1:0]; 
	wire	[31:0]	err;	

	wire 	[DATA_W-1:0] ap;    
	wire 	[DATA_W-1:0] aq;
	wire 	[DATA_W-1:0] bp;
	wire 	[DATA_W-1:0] bq;
	wire 	[DATA_W-1:0] errap;    
	wire 	[DATA_W-1:0] erraq;
	wire 	[31:0] alpha;
	wire 	[31:0] beta;
	wire    [31:0] err_square;

	wire    err_ap_valid, err_aq_valid;
	wire	p_new_valid, q_new_valid;
	integer i;
		
	assign alpha = 32'h00a0;
	assign beta	 = 32'h00b0;
	assign output_valid = p_new_valid & q_new_valid;
	assign  total_err   = err_square;
		
			
	 
	always @(posedge clk) begin
        if(rst) begin
			for(i=0; i<Pipeline_Depth; i=i+1) begin
				Uid_shift_reg [i]	<= {ADDR_W{1'b0}};
				Vid_shift_reg [i]	<= {ADDR_W{1'b0}};
			end	
		end else begin 
			Uid_shift_reg [0] <= Uid_in;
			Vid_shift_reg [0] <= Vid_in;
			for(i=1; i<Pipeline_Depth; i=i+1) begin
				Uid_shift_reg [i]	<= Uid_shift_reg [i-1];
				Vid_shift_reg [i]	<= Vid_shift_reg [i-1];
			end
		end
	end	
	assign Ubuf_waddr = Uid_shift_reg [Pipeline_Depth-1];
	assign Vbuf_waddr = Vid_shift_reg [Pipeline_Depth-1];
	
prediction_unit PCU(
	.clk(clk),
	.rst(rst),
	.p(p),    
	.q(q),
	.rating(rating),		
	.input_valid(input_valid),
	.err(err),
	.output_valid(pcu_output_valid)    
);
	
vector_mul #(.Delay(9)) 
multi_alpha_p(
	.clk(clk),
	.rst(rst),
	.in_valid(1'b1),
	.p(p),    
	.constant(alpha), 		
	.p_out(ap)           
);

vector_mul #(.Delay(9)) 
multi_alpha_q(
	.clk(clk),
	.rst(rst),
	.in_valid(1'b1),
	.p(q),    
	.constant(alpha),    
	.p_out(aq)           
 );

vector_mul #(.Delay(12)) 
multi_beta_p(
   .clk(clk),
   .rst(rst),
   .in_valid(1'b1),
   .p(p),    
   .constant(beta),
   .p_out(bp)           
);

vector_mul #(.Delay(12)) 
multi_beta_q(
   .clk(clk),
   .rst(rst),
   .in_valid(1'b1),
   .p(q),    
   .constant(beta),
   .p_out(bq)           
);
   
vector_mul #(.Delay(0)) 
multi_err_ap(
  .clk(clk),
  .rst(rst),
  .in_valid(pcu_output_valid),
  .p(ap),    
  .constant(err),
  .out_valid(err_ap_valid),
  .p_out(errap)           
);

vector_mul #(.Delay(0)) 
multi_err_aq(
  .clk(clk),
  .rst(rst),
  .in_valid(pcu_output_valid),
  .p(aq),    
  .constant(err),
  .out_valid(err_aq_valid),
  .p_out(erraq)           
);
   
vector_add add_errap_bp(
   .clk(clk),
   .rst(rst),
   .in_valid(err_ap_valid),
   .in0(errap),
   .in1(bp),
   .out_valid(p_new_valid),
   .out(p_new)
);

vector_add add_erraq_bq(
 .clk(clk),
 .rst(rst),
 .in_valid(err_aq_valid),
 .in0(erraq),
 .in1(bq),
 .out_valid(q_new_valid),
 .out(q_new)
);

fp_mul squarer (              
    .aclk    (clk),
    .s_axis_a_tvalid(pcu_output_valid),        
    .s_axis_a_tdata(err),
    .s_axis_b_tvalid(pcu_output_valid),
    .s_axis_b_tdata(err),		
    .m_axis_result_tdata(err_square)              
); 
	
endmodule


module vector_add(
    input wire 	clk,
    input wire 	rst,
	input wire  in_valid,
    input wire 	[32*32-1:0] in0,    
    input wire 	[32*32-1:0] in1,    
	output wire out_valid,
    output wire [32*32-1:0] out
);

wire output_valid_wire [31:0];

assign out_valid = output_valid_wire[0];
genvar numstg;
generate
		for(numstg=0; numstg < 32; numstg = numstg+1)
		begin: l1_elements
			fp_add adders(
				.aclk    (clk),
				.s_axis_a_tvalid (in_valid),
				.s_axis_a_tdata (in0[32*numstg+31:32*numstg]),
				.s_axis_b_tvalid (in_valid), 
				.s_axis_b_tdata (in1[32*numstg+31:32*numstg]),  
				.m_axis_result_tvalid (output_valid_wire[numstg]),				                   
				.m_axis_result_tdata (out[32*numstg+31:32*numstg])
			  );  
		end
endgenerate	
endmodule

module vector_mul #(
	parameter 	Delay = 16
)(
    input wire 	clk,
    input wire 	rst,
	input wire  in_valid,
    input wire 	[32*32-1:0] p,    
    input wire 	[31:0] constant,
	output wire out_valid,
    output reg  [32*32-1:0] p_out           
);
        
    
    reg [32*32-1:0] p_reg [Delay:0]; 
    integer i;
    wire [32*32-1:0] product; 
	wire output_valid_wire [31:0];
	assign out_valid = output_valid_wire[0];
	
    genvar numstg;
    generate
        for(numstg=0; numstg < 32; numstg = numstg+1)
        begin: mm_elements
            fp_mul multipliers (              
                .aclk    (clk),
                .s_axis_a_tvalid(in_valid),        
                .s_axis_a_tdata(p[32*numstg+31:32*numstg]),
                .s_axis_b_tvalid(1'b1),
                .s_axis_b_tdata(constant),
				.m_axis_result_tvalid (output_valid_wire[numstg]),                
                .m_axis_result_tdata(product[32*numstg+31:32*numstg])              
            );         
        end
    endgenerate	
    
    always @(posedge clk) begin     
       if(rst) begin                
            for(i=0; i<Delay; i=i+1) begin 
                p_reg [i] <= 0;            
            end
       end else begin
            for(i=1; i<Delay+1; i=i+1) begin 
               p_reg [i] <= p_reg [i-1] ;                           
            end
            p_reg [0] <= product;
            p_out <= p_reg[Delay];
       end
    end
endmodule

module hdu # (
	parameter ADDR_W = 16,
	parameter Bank_Num_W = 3
)(
	input   wire clk,
	input   wire rst,
	input   wire [ADDR_W-1:0] Raddr0,
	input   wire [ADDR_W-1:0] Raddr1,	
	input   wire [ADDR_W-1:0] Raddr2,
	input   wire [ADDR_W-1:0] Raddr3,
	input   wire [ADDR_W-1:0] Raddr4,
	input   wire [ADDR_W-1:0] Raddr5,	
	input   wire [ADDR_W-1:0] Raddr6,
	input   wire [ADDR_W-1:0] Raddr7,	
	input   wire [ADDR_W-1:0] Waddr0,
	input   wire [ADDR_W-1:0] Waddr1,
	input   wire [ADDR_W-1:0] Waddr2,
	input   wire [ADDR_W-1:0] Waddr3,	
	input   wire [ADDR_W-1:0] Waddr4,
	input   wire [ADDR_W-1:0] Waddr5,
	input   wire [ADDR_W-1:0] Waddr6,
	input   wire [ADDR_W-1:0] Waddr7,	
	input   wire Raddr_valid0,
	input   wire Raddr_valid1,	
	input   wire Raddr_valid2,
	input   wire Raddr_valid3,
	input   wire Raddr_valid4,
	input   wire Raddr_valid5,	
	input   wire Raddr_valid6,
	input   wire Raddr_valid7,	
	input   wire Waddr_valid0,
	input   wire Waddr_valid1,
	input   wire Waddr_valid2,
	input   wire Waddr_valid3,	
	input   wire Waddr_valid4,
	input   wire Waddr_valid5,
	input   wire Waddr_valid6,
	input   wire Waddr_valid7,	
	output	wire stall_signal	
);
   
localparam Bank_Num = (2**Bank_Num_W);
localparam Port_Num = 8;

wire flag_valid0;
wire flag_valid1;
wire flag_valid2;
wire flag_valid3;
wire flag_valid4;
wire flag_valid5;
wire flag_valid6;
wire flag_valid7;
wire flag0;
wire flag1;
wire flag2;
wire flag3;
wire flag4;
wire flag5;
wire flag6;
wire flag7;
	
wire [ADDR_W-Bank_Num_W-1:0] bank_raddr [Bank_Num-1:0];
wire [ADDR_W-Bank_Num_W-1:0] bank_waddr [Bank_Num-1:0];
wire [0:0] bank_rvalid [Bank_Num-1:0];
wire [0:0] bank_wvalid [Bank_Num-1:0];
wire [0:0] bank_fvalid [Bank_Num-1:0];
wire [0:0] bank_flag   [Bank_Num-1:0];

reg	 [Bank_Num_W-1:0] sel	[Port_Num-1:0];
reg	 [ADDR_W:0]		lock [Port_Num-1:0];
reg	 [ADDR_W-1:0]	Raddr_reg [Port_Num-1:0];
reg	 [0:0]	Raddr_valid_reg [Port_Num-1:0];

genvar numbank; 
generate for(numbank=0; numbank < Bank_Num; numbank = numbank+1) 
	begin: elements	
		hdu_unit # (.ADDR_W(ADDR_W-Bank_Num_W))	hdu_bank (
			.clk(clk),
			.rst(rst),
			.Raddr(bank_raddr[numbank]),
			.Waddr(bank_waddr[numbank]),
			.Raddr_valid(bank_rvalid[numbank]),
			.Waddr_valid(bank_wvalid[numbank]),
			.flag_valid(bank_fvalid[numbank]),
			.flag(bank_flag[numbank])
		);
	end
endgenerate 

	
genvar i;
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: read_addr assign bank_raddr[i] = (Raddr_valid0 && Raddr0[Bank_Num_W-1:0] == i) ? Raddr0[ADDR_W-1: Bank_Num_W] :
							(Raddr_valid1 && Raddr1[Bank_Num_W-1:0] == i) ? Raddr1[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid2 && Raddr2[Bank_Num_W-1:0] == i) ? Raddr2[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid3 && Raddr3[Bank_Num_W-1:0] == i) ? Raddr3[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid4 && Raddr4[Bank_Num_W-1:0] == i) ? Raddr4[ADDR_W-1: Bank_Num_W] :
							(Raddr_valid5 && Raddr5[Bank_Num_W-1:0] == i) ? Raddr5[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid6 && Raddr6[Bank_Num_W-1:0] == i) ? Raddr6[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid7 && Raddr7[Bank_Num_W-1:0] == i) ? Raddr7[ADDR_W-1: Bank_Num_W] : {(ADDR_W-Bank_Num_W){1'b0}};	  
   end 
endgenerate
	
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_addr assign bank_waddr[i] = (Waddr_valid0 && Waddr0[Bank_Num_W-1:0] == i) ? Waddr0[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid1 && Waddr1[Bank_Num_W-1:0] == i) ? Waddr1[ADDR_W-1: Bank_Num_W] :	
							(Waddr_valid2 && Waddr2[Bank_Num_W-1:0] == i) ? Waddr2[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid3 && Waddr3[Bank_Num_W-1:0] == i) ? Waddr3[ADDR_W-1: Bank_Num_W] :	
							(Waddr_valid4 && Waddr4[Bank_Num_W-1:0] == i) ? Waddr4[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid5 && Waddr5[Bank_Num_W-1:0] == i) ? Waddr5[ADDR_W-1: Bank_Num_W] :	
							(Waddr_valid6 && Waddr6[Bank_Num_W-1:0] == i) ? Waddr6[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid7 && Waddr7[Bank_Num_W-1:0] == i) ? Waddr7[ADDR_W-1: Bank_Num_W] : {(ADDR_W-Bank_Num_W){1'b0}};	
   end 
endgenerate
																			
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: read_valid assign bank_rvalid[i] = (Raddr_valid0 && Raddr0[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Raddr_valid1 && Raddr1[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid2 && Raddr2[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid3 && Raddr3[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid4 && Raddr4[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Raddr_valid5 && Raddr5[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid6 && Raddr6[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid7 && Raddr7[Bank_Num_W-1:0] == i) ? 1'b1 : 1'b0;
   end 
endgenerate
							
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_valid assign bank_wvalid[i] = (Waddr_valid0 && Waddr0[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid1 && Waddr1[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Waddr_valid2 && Waddr2[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid3 && Waddr3[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Waddr_valid4 && Waddr4[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid5 && Waddr5[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Waddr_valid6 && Waddr6[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid7 && Waddr7[Bank_Num_W-1:0] == i) ? 1'b1 : 1'b0;
   end 
endgenerate

wire stall;	
assign stall = (lock[0]<{(ADDR_W+1){1'b1}}) || (lock[1]<{(ADDR_W+1){1'b1}}) || (lock[2]<{(ADDR_W+1){1'b1}}) || (lock[3]<{(ADDR_W+1){1'b1}}) || (lock[4]<{(ADDR_W+1){1'b1}}) || (lock[5]<{(ADDR_W+1){1'b1}}) || (lock[6]<{(ADDR_W+1){1'b1}}) || (lock[7]<{(ADDR_W+1){1'b1}});
assign stall_signal = stall;
	
always @(posedge clk) begin
	if(rst) begin
		lock[0] <= {(ADDR_W+1){1'b1}};
		lock[1] <= {(ADDR_W+1){1'b1}};    
		lock[2] <= {(ADDR_W+1){1'b1}};
		lock[3] <= {(ADDR_W+1){1'b1}};
		lock[4] <= {(ADDR_W+1){1'b1}};
		lock[5] <= {(ADDR_W+1){1'b1}};    
		lock[6] <= {(ADDR_W+1){1'b1}};
		lock[7] <= {(ADDR_W+1){1'b1}};			
	end else begin
		if(stall_signal) begin
			if((lock[0] == {1'b0, Waddr0} && Waddr_valid0) || (lock[0] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[0] == {1'b0, Waddr2} && Waddr_valid2) || (lock[0] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[0] == {1'b0, Waddr4} && Waddr_valid4) || (lock[0] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[0] == {1'b0, Waddr6} && Waddr_valid6) || (lock[0] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[0] <= {(ADDR_W+1){1'b1}};
			end  
			if((lock[1] == {1'b0, Waddr0} && Waddr_valid0) || (lock[1] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[1] == {1'b0, Waddr2} && Waddr_valid2) || (lock[1] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[1] == {1'b0, Waddr4} && Waddr_valid4) || (lock[1] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[1] == {1'b0, Waddr6} && Waddr_valid6) || (lock[1] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[1] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[2] == {1'b0, Waddr0} && Waddr_valid0) || (lock[2] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[2] == {1'b0, Waddr2} && Waddr_valid2) || (lock[2] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[2] == {1'b0, Waddr4} && Waddr_valid4) || (lock[2] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[2] == {1'b0, Waddr6} && Waddr_valid6) || (lock[2] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[2] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[3] == {1'b0, Waddr0} && Waddr_valid0) || (lock[3] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[3] == {1'b0, Waddr2} && Waddr_valid2) || (lock[3] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[3] == {1'b0, Waddr4} && Waddr_valid4) || (lock[3] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[3] == {1'b0, Waddr6} && Waddr_valid6) || (lock[3] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[3] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[4] == {1'b0, Waddr0} && Waddr_valid0) || (lock[4] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[4] == {1'b0, Waddr2} && Waddr_valid2) || (lock[4] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[4] == {1'b0, Waddr4} && Waddr_valid4) || (lock[4] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[4] == {1'b0, Waddr6} && Waddr_valid6) || (lock[4] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[4] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[5] == {1'b0, Waddr0} && Waddr_valid0) || (lock[5] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[5] == {1'b0, Waddr2} && Waddr_valid2) || (lock[5] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[5] == {1'b0, Waddr4} && Waddr_valid4) || (lock[5] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[5] == {1'b0, Waddr6} && Waddr_valid6) || (lock[5] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[5] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[6] == {1'b0, Waddr0} && Waddr_valid0) || (lock[6] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[6] == {1'b0, Waddr2} && Waddr_valid2) || (lock[6] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[6] == {1'b0, Waddr4} && Waddr_valid4) || (lock[6] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[6] == {1'b0, Waddr6} && Waddr_valid6) || (lock[6] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[6] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[7] == {1'b0, Waddr0} && Waddr_valid0) || (lock[7] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[7] == {1'b0, Waddr2} && Waddr_valid2) || (lock[7] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[7] == {1'b0, Waddr4} && Waddr_valid4) || (lock[7] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[7] == {1'b0, Waddr6} && Waddr_valid6) || (lock[7] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[7] <= {(ADDR_W+1){1'b1}};
			end
		end else begin
			if(Raddr_reg [0] && Raddr_valid_reg [0] && flag_valid0 && flag0) begin lock[0] <= {1'b0, Raddr_reg [0]}; end
			if(Raddr_reg [1] && Raddr_valid_reg [1] && flag_valid1 && flag1) begin lock[1] <= {1'b0, Raddr_reg [1]}; end
			if(Raddr_reg [2] && Raddr_valid_reg [2] && flag_valid2 && flag2) begin lock[2] <= {1'b0, Raddr_reg [2]}; end
			if(Raddr_reg [3] && Raddr_valid_reg [3] && flag_valid3 && flag3) begin lock[3] <= {1'b0, Raddr_reg [3]}; end
			if(Raddr_reg [4] && Raddr_valid_reg [4] && flag_valid4 && flag4) begin lock[4] <= {1'b0, Raddr_reg [4]}; end
			if(Raddr_reg [5] && Raddr_valid_reg [5] && flag_valid5 && flag5) begin lock[5] <= {1'b0, Raddr_reg [5]}; end
			if(Raddr_reg [6] && Raddr_valid_reg [6] && flag_valid6 && flag6) begin lock[6] <= {1'b0, Raddr_reg [6]}; end
			if(Raddr_reg [7] && Raddr_valid_reg [7] && flag_valid7 && flag7) begin lock[7] <= {1'b0, Raddr_reg [7]}; end
		end
	end
end
							
always @(posedge clk) begin
	if(rst) begin
		sel[0] <= {Bank_Num_W{1'b0}};
		sel[1] <= {Bank_Num_W{1'b0}};   
		sel[2] <= {Bank_Num_W{1'b0}};
		sel[3] <= {Bank_Num_W{1'b0}};
		sel[4] <= {Bank_Num_W{1'b0}};
		sel[5] <= {Bank_Num_W{1'b0}};    
		sel[6] <= {Bank_Num_W{1'b0}};
		sel[7] <= {Bank_Num_W{1'b0}};
		Raddr_reg [0] <= {(ADDR_W){1'b0}};
		Raddr_reg [1] <= {(ADDR_W){1'b0}};
		Raddr_reg [2] <= {(ADDR_W){1'b0}};
		Raddr_reg [3] <= {(ADDR_W){1'b0}};
		Raddr_reg [4] <= {(ADDR_W){1'b0}};
		Raddr_reg [5] <= {(ADDR_W){1'b0}};
		Raddr_reg [6] <= {(ADDR_W){1'b0}};
		Raddr_reg [7] <= {(ADDR_W){1'b0}};
		Raddr_valid_reg [0] <= 1'b0;
		Raddr_valid_reg [1] <= 1'b0;
		Raddr_valid_reg [2] <= 1'b0;
		Raddr_valid_reg [3] <= 1'b0;
		Raddr_valid_reg [4] <= 1'b0;
		Raddr_valid_reg [5] <= 1'b0;
		Raddr_valid_reg [6] <= 1'b0;
		Raddr_valid_reg [7] <= 1'b0;
	end else begin
		if(~stall) begin
			sel[0] <= Raddr0[Bank_Num_W-1:0];			
			sel[1] <= Raddr1[Bank_Num_W-1:0];			  
			sel[2] <= Raddr2[Bank_Num_W-1:0];			
			sel[3] <= Raddr3[Bank_Num_W-1:0];			  
			sel[4] <= Raddr4[Bank_Num_W-1:0];			
			sel[5] <= Raddr5[Bank_Num_W-1:0];			  
			sel[6] <= Raddr6[Bank_Num_W-1:0];			
			sel[7] <= Raddr7[Bank_Num_W-1:0];
			Raddr_reg [0] <= Raddr0;
			Raddr_reg [1] <= Raddr1;
			Raddr_reg [2] <= Raddr2;
			Raddr_reg [3] <= Raddr3;
			Raddr_reg [4] <= Raddr4;
			Raddr_reg [5] <= Raddr5;
			Raddr_reg [6] <= Raddr6;
			Raddr_reg [7] <= Raddr7;
			Raddr_valid_reg [0] <= Raddr_valid0;
			Raddr_valid_reg [1] <= Raddr_valid1;
			Raddr_valid_reg [2] <= Raddr_valid2;
			Raddr_valid_reg [3] <= Raddr_valid3;
			Raddr_valid_reg [4] <= Raddr_valid4;
			Raddr_valid_reg [5] <= Raddr_valid5;
			Raddr_valid_reg [6] <= Raddr_valid6;
			Raddr_valid_reg [7] <= Raddr_valid7;	
		end else begin
			sel[0] <= sel[0];			
			sel[1] <= sel[1];			  
			sel[2] <= sel[2];			
			sel[3] <= sel[3];			  
			sel[4] <= sel[4];			
			sel[5] <= sel[5];			  
			sel[6] <= sel[6];			
			sel[7] <= sel[7];
			Raddr_reg [0] <= Raddr_reg [0];
			Raddr_reg [1] <= Raddr_reg [1];
			Raddr_reg [2] <= Raddr_reg [2];
			Raddr_reg [3] <= Raddr_reg [3];
			Raddr_reg [4] <= Raddr_reg [4];
			Raddr_reg [5] <= Raddr_reg [5];
			Raddr_reg [6] <= Raddr_reg [6];
			Raddr_reg [7] <= Raddr_reg [7];
			Raddr_valid_reg [0] <= Raddr_valid_reg [0];
			Raddr_valid_reg [1] <= Raddr_valid_reg [1];
			Raddr_valid_reg [2] <= Raddr_valid_reg [2];
			Raddr_valid_reg [3] <= Raddr_valid_reg [3];
			Raddr_valid_reg [4] <= Raddr_valid_reg [4];
			Raddr_valid_reg [5] <= Raddr_valid_reg [5];
			Raddr_valid_reg [6] <= Raddr_valid_reg [6];
			Raddr_valid_reg [7] <= Raddr_valid_reg [7];
		end
	end
end

assign flag_valid0 = bank_fvalid[sel[0]];
assign flag_valid1 = bank_fvalid[sel[1]];
assign flag_valid2 = bank_fvalid[sel[2]];
assign flag_valid3 = bank_fvalid[sel[3]];
assign flag_valid4 = bank_fvalid[sel[4]];
assign flag_valid5 = bank_fvalid[sel[5]];
assign flag_valid6 = bank_fvalid[sel[6]];
assign flag_valid7 = bank_fvalid[sel[7]];	
assign flag0 = bank_flag[sel[0]];
assign flag1 = bank_flag[sel[1]];
assign flag2 = bank_flag[sel[2]];
assign flag3 = bank_flag[sel[3]];	
assign flag4 = bank_flag[sel[4]];
assign flag5 = bank_flag[sel[5]];
assign flag6 = bank_flag[sel[6]];
assign flag7 = bank_flag[sel[7]];

endmodule

module hdu_unit # (
    parameter ADDR_W = 16
)(
	input   wire clk,
	input   wire rst,
	input   wire [ADDR_W-1:0] Raddr,
	input   wire [ADDR_W-1:0] Waddr,
	input   wire Raddr_valid,
	input   wire Waddr_valid,
	output  reg  flag_valid,
	output  reg  flag
);
    
    wire bram_flag_outA;
    wire bram_flag_outB;
    
    always @(posedge clk) begin
        if(rst) begin
            flag_valid <=1'b0;
            flag <=1'b0;
        end else begin
            flag_valid <= Raddr_valid;
            flag <= bram_flag_outA;            
        end    
    end 
    bram # (.DATA(1),  .ADDR(ADDR_W))
    hdu_ram(
        .clk(clk),
        .a_wr(Raddr_valid),
        .a_addr(Raddr),
        .a_din(1'b1),
        .a_dout(bram_flag_outA),
        .b_wr(Waddr_valid),
        .b_addr(Waddr),
        .b_din(1'b0),
        .b_dout(bram_flag_outB)
    );    
endmodule

module bram #(
    parameter DATA = 1,
    parameter ADDR = 16
) (
    input   wire                clk,
    input   wire                a_wr,
    input   wire    [ADDR-1:0]  a_addr,
    input   wire    [DATA-1:0]  a_din,
    output  reg     [DATA-1:0]  a_dout,
    input   wire                b_wr,
    input   wire    [ADDR-1:0]  b_addr,
    input   wire    [DATA-1:0]  b_din,
    output  reg     [DATA-1:0]  b_dout
);
 
(* ram_style="block" *) reg [DATA-1:0] mem [(2**ADDR)-1:0];

always @(posedge clk) begin
    a_dout      <= mem[a_addr];
    if(a_wr) begin
        a_dout      <= a_din;
        mem[a_addr] <= a_din;
    end
end

always @(posedge clk) begin
    b_dout      <= mem[b_addr];
    if(b_wr && (~a_wr || b_addr != a_addr)) begin
        b_dout      <= b_din;
        mem[b_addr] <= b_din;
    end
end

endmodule

module bcr # (parameter FIFO_WIDTH = 192, parameter ADDR_W = 15, parameter EDGE_W = 48, parameter Bank_Num_W = 3)
(
	input wire 						clk,	
	input wire						rst,
	input wire						input_valid,
	input wire	[FIFO_WIDTH-1:0]	input_data,
	input wire						stall,
	output reg 	[EDGE_W-1:0]		output_data0,
	output reg 	[EDGE_W-1:0]		output_data1,
	output reg 	[EDGE_W-1:0]		output_data2,
	output reg 	[EDGE_W-1:0]		output_data3,
	output reg 	[EDGE_W-1:0]		output_data4,
	output reg 	[EDGE_W-1:0]		output_data5,
	output reg 	[EDGE_W-1:0]		output_data6,
	output reg 	[EDGE_W-1:0]		output_data7,
	output reg						output_valid0,
	output reg						output_valid1,
	output reg						output_valid2,
	output reg						output_valid3,
	output reg						output_valid4,
	output reg						output_valid5,
	output reg						output_valid6,
	output reg						output_valid7,	
	output reg						inc
);

reg	data0_outputed;
reg	data1_outputed;
reg	data2_outputed;
reg	data3_outputed;
reg	data4_outputed;
reg	data5_outputed;
reg	data6_outputed;
reg	data7_outputed;

reg input_valid_reg;
reg [EDGE_W*8-1:0] input_data_reg;
wire valid0, valid1, valid2, valid3, valid4, valid5, valid6, valid7, inc_wire;

always @(posedge clk) begin
	if(rst) begin
		input_valid_reg 	<= 1'b0;		 
		input_data_reg 		<= {(EDGE_W*8){1'b0}};		
	end else begin 	
		if(stall) begin
			input_valid_reg <= input_valid_reg;
			input_data_reg <= input_data_reg;
		end else begin
			input_valid_reg <= input_valid;
			input_data_reg <= input_data;		
		end
	end
end
	
wire [EDGE_W-1:0] data0;
wire [EDGE_W-1:0] data1;
wire [EDGE_W-1:0] data2;
wire [EDGE_W-1:0] data3;
wire [EDGE_W-1:0] data4;
wire [EDGE_W-1:0] data5;
wire [EDGE_W-1:0] data6;
wire [EDGE_W-1:0] data7;

assign	data0 = input_data_reg[EDGE_W-1:0];
assign	data1 = input_data_reg[EDGE_W*2-1:EDGE_W*1];
assign	data2 = input_data_reg[EDGE_W*3-1:EDGE_W*2];
assign	data3 = input_data_reg[EDGE_W*4-1:EDGE_W*3];
assign	data4 = input_data_reg[EDGE_W*5-1:EDGE_W*4];
assign	data5 = input_data_reg[EDGE_W*6-1:EDGE_W*5];
assign	data6 = input_data_reg[EDGE_W*7-1:EDGE_W*6];
assign	data7 = input_data_reg[EDGE_W*8-1:EDGE_W*7];

wire conflict01, conflict02, conflict03, conflict04, conflict05, conflict06, conflict07;
wire conflict12, conflict13, conflict14, conflict15, conflict16, conflict17;
wire conflict23, conflict24, conflict25, conflict26, conflict27;
wire conflict34, conflict35, conflict36, conflict37;
wire conflict45, conflict46, conflict47;
wire conflict56, conflict57;
wire conflict67;
wire conflict_free;

assign conflict01 = (data0[Bank_Num_W-1:0] == data1[Bank_Num_W-1:0] || data0[Bank_Num_W-1+ADDR_W:ADDR_W] == data1[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict02 = (data0[Bank_Num_W-1:0] == data2[Bank_Num_W-1:0] || data0[Bank_Num_W-1+ADDR_W:ADDR_W] == data2[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict03 = (data0[Bank_Num_W-1:0] == data3[Bank_Num_W-1:0] || data0[Bank_Num_W-1+ADDR_W:ADDR_W] == data3[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict04 = (data0[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0] || data0[Bank_Num_W-1+ADDR_W:ADDR_W] == data4[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict05 = (data0[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0] || data0[Bank_Num_W-1+ADDR_W:ADDR_W] == data5[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict06 = (data0[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0] || data0[Bank_Num_W-1+ADDR_W:ADDR_W] == data6[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict07 = (data0[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0] || data0[Bank_Num_W-1+ADDR_W:ADDR_W] == data7[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict12 = (data1[Bank_Num_W-1:0] == data2[Bank_Num_W-1:0] || data1[Bank_Num_W-1+ADDR_W:ADDR_W] == data2[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict13 = (data1[Bank_Num_W-1:0] == data3[Bank_Num_W-1:0] || data1[Bank_Num_W-1+ADDR_W:ADDR_W] == data3[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict14 = (data1[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0] || data1[Bank_Num_W-1+ADDR_W:ADDR_W] == data4[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict15 = (data1[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0] || data1[Bank_Num_W-1+ADDR_W:ADDR_W] == data5[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict16 = (data1[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0] || data1[Bank_Num_W-1+ADDR_W:ADDR_W] == data6[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict17 = (data1[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0] || data1[Bank_Num_W-1+ADDR_W:ADDR_W] == data7[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict23 = (data2[Bank_Num_W-1:0] == data3[Bank_Num_W-1:0] || data2[Bank_Num_W-1+ADDR_W:ADDR_W] == data3[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict24 = (data2[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0] || data2[Bank_Num_W-1+ADDR_W:ADDR_W] == data4[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict25 = (data2[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0] || data2[Bank_Num_W-1+ADDR_W:ADDR_W] == data5[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict26 = (data2[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0] || data2[Bank_Num_W-1+ADDR_W:ADDR_W] == data6[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict27 = (data2[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0] || data2[Bank_Num_W-1+ADDR_W:ADDR_W] == data7[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict34 = (data3[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0] || data3[Bank_Num_W-1+ADDR_W:ADDR_W] == data4[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict35 = (data3[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0] || data3[Bank_Num_W-1+ADDR_W:ADDR_W] == data5[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict36 = (data3[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0] || data3[Bank_Num_W-1+ADDR_W:ADDR_W] == data6[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict37 = (data3[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0] || data3[Bank_Num_W-1+ADDR_W:ADDR_W] == data7[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict45 = (data4[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0] || data4[Bank_Num_W-1+ADDR_W:ADDR_W] == data5[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict46 = (data4[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0] || data4[Bank_Num_W-1+ADDR_W:ADDR_W] == data6[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict47 = (data4[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0] || data4[Bank_Num_W-1+ADDR_W:ADDR_W] == data7[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict56 = (data5[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0] || data5[Bank_Num_W-1+ADDR_W:ADDR_W] == data6[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict57 = (data5[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0] || data5[Bank_Num_W-1+ADDR_W:ADDR_W] == data7[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict67 = (data6[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0] || data6[Bank_Num_W-1+ADDR_W:ADDR_W] == data7[Bank_Num_W-1+ADDR_W:ADDR_W]);
assign conflict_free =(~conflict01 && ~conflict02 && ~conflict03 && ~conflict04 && ~conflict05 && ~conflict06 && ~conflict07 && 
					   ~conflict12 && ~conflict13 && ~conflict14 && ~conflict15 && ~conflict16 && ~conflict17 &&  
					   ~conflict23 && ~conflict24 && ~conflict25 && ~conflict26 && ~conflict27 &&
					   ~conflict34 && ~conflict35 && ~conflict36 && ~conflict37 &&
					   ~conflict45 && ~conflict46 && ~conflict47 && ~conflict56 && ~conflict57 && ~conflict67);


assign	inc_wire = ~input_valid_reg ? 1'b0 :
			   (valid0 || data0_outputed) && (valid1 || data1_outputed) && (valid2 || data2_outputed)&&(valid3 || data3_outputed) && (valid4 || data4_outputed) && (valid5 || data5_outputed) && (valid6 || data6_outputed)	
			   && (valid7 || data7_outputed) ? 1'b1 :
			   conflict_free ? 1'b1 : 1'b0;	 
assign	valid0 = input_valid_reg && ~data0_outputed;
assign	valid1 = input_valid_reg && ~data1_outputed && (~valid0 || (valid0 && ~conflict01));
assign	valid2 = input_valid_reg && ~data2_outputed && (~valid0 || (valid0 && ~conflict02)) && (~valid1 || (valid1 && ~conflict12));
assign	valid3 = input_valid_reg && ~data3_outputed && (~valid0 || (valid0 && ~conflict03)) && (~valid1 || (valid1 && ~conflict13)) && (~valid2 || (valid2 && ~conflict23));
assign	valid4 = input_valid_reg && ~data4_outputed && (~valid0 || (valid0 && ~conflict04)) && (~valid1 || (valid1 && ~conflict14)) && (~valid2 || (valid2 && ~conflict24)) && (~valid3 || (valid3 && ~conflict34));
assign	valid5 = input_valid_reg && ~data5_outputed && (~valid0 || (valid0 && ~conflict05)) && (~valid1 || (valid1 && ~conflict15)) && (~valid2 || (valid2 && ~conflict25)) && (~valid3 || (valid3 && ~conflict35))
			 && (~valid4 || (valid4 && ~conflict45));
assign	valid6 = input_valid_reg && ~data6_outputed && (~valid0 || (valid0 && ~conflict06)) && (~valid1 || (valid1 && ~conflict16)) && (~valid2 || (valid2 && ~conflict26)) && (~valid3 || (valid3 && ~conflict36))
			 && (~valid4 || (valid4 && ~conflict46)) && (~valid5 || (valid5 && ~conflict56));		 
assign	valid7 = input_valid_reg && ~data7_outputed && (~valid0 || (valid0 && ~conflict07)) && (~valid1 || (valid1 && ~conflict17)) && (~valid2 || (valid2 && ~conflict27)) && (~valid3 || (valid3 && ~conflict37))
			 && (~valid4 || (valid4 && ~conflict47)) && (~valid5 || (valid5 && ~conflict57)) && (~valid6 || (valid6 && ~conflict67));			 

					   
always @(posedge clk) begin
	if(rst) begin
		output_data0 	<= 1'b0;		 
		output_data1 	<= 1'b0;
		output_data2 	<= 1'b0;		 
		output_data3 	<= 1'b0;
		output_data4 	<= 1'b0;		 
		output_data5 	<= 1'b0;
		output_data6 	<= 1'b0;		 
		output_data7 	<= 1'b0;
		output_valid0 	<= 1'b0;
		output_valid1	<= 1'b0;
		output_valid2 	<= 1'b0;
		output_valid3	<= 1'b0;
		output_valid4 	<= 1'b0;
		output_valid5	<= 1'b0;
		output_valid6 	<= 1'b0;
		output_valid7	<= 1'b0;
		data0_outputed 	<= 1'b0;
		data1_outputed  <= 1'b0;
		data2_outputed 	<= 1'b0;
		data3_outputed  <= 1'b0;
		data4_outputed 	<= 1'b0;
		data5_outputed  <= 1'b0;
		data6_outputed 	<= 1'b0;
		data7_outputed  <= 1'b0;
	end else begin 	
		output_data0 <= data0;
		output_data1 <= data1;
		output_data2 <= data2;
		output_data3 <= data3;
		output_data4 <= data4;
		output_data5 <= data5;
		output_data6 <= data6;
		output_data7 <= data7;		
		if(~stall) begin
			inc			 	<= inc_wire;
			output_valid0 	<= valid0;
			output_valid1 	<= valid1;
			output_valid2 	<= valid2;
			output_valid3 	<= valid3;
			output_valid4 	<= valid4;
			output_valid5 	<= valid5;
			output_valid6 	<= valid6;
			output_valid7 	<= valid7;
			data0_outputed  <= inc_wire ? 1'b0 : valid0   ? 1'b1 : data0_outputed;
			data1_outputed  <= inc_wire ? 1'b0 : valid1   ? 1'b1 : data1_outputed;
			data2_outputed  <= inc_wire ? 1'b0 : valid2   ? 1'b1 : data2_outputed;
			data3_outputed  <= inc_wire ? 1'b0 : valid3   ? 1'b1 : data3_outputed;
			data4_outputed  <= inc_wire ? 1'b0 : valid4   ? 1'b1 : data4_outputed;
			data5_outputed  <= inc_wire ? 1'b0 : valid5   ? 1'b1 : data5_outputed;
			data6_outputed  <= inc_wire ? 1'b0 : valid6   ? 1'b1 : data6_outputed;
			data7_outputed  <= inc_wire ? 1'b0 : valid7   ? 1'b1 : data7_outputed;			
		end else begin  
			output_valid0 	<= 1'b0;
			output_valid1	<= 1'b0;
			output_valid2 	<= 1'b0;
			output_valid3	<= 1'b0;
			output_valid4 	<= 1'b0;
			output_valid5	<= 1'b0;
			output_valid6 	<= 1'b0;
			output_valid7	<= 1'b0;
			data0_outputed 	<= data0_outputed;
			data1_outputed  <= data1_outputed;
			data2_outputed 	<= data2_outputed;
			data3_outputed  <= data3_outputed;
			data4_outputed 	<= data4_outputed;
			data5_outputed  <= data5_outputed;
			data6_outputed 	<= data6_outputed;
			data7_outputed  <= data7_outputed;
			inc				<= 1'b0;
		end
	end
end	
endmodule


module buffer # (parameter DATA_W = 1024, parameter ADDR_W =13, parameter Bank_Num_W = 1)
(	
	input wire 					clk,
	input wire 					rst,
	input wire [ADDR_W-1:0]		R_Addr0,
	input wire [ADDR_W-1:0]		R_Addr1,
	input wire [ADDR_W-1:0]		R_Addr2,
	input wire [ADDR_W-1:0]		R_Addr3,
	input wire [ADDR_W-1:0]		R_Addr4,
	input wire [ADDR_W-1:0]		R_Addr5,
	input wire [ADDR_W-1:0]		R_Addr6,
	input wire [ADDR_W-1:0]		R_Addr7,	
	input wire [ADDR_W-1:0]		W_Addr0,	
	input wire [ADDR_W-1:0]		W_Addr1,	
	input wire [ADDR_W-1:0]		W_Addr2,	
	input wire [ADDR_W-1:0]		W_Addr3,	
	input wire [ADDR_W-1:0]		W_Addr4,	
	input wire [ADDR_W-1:0]		W_Addr5,	
	input wire [ADDR_W-1:0]		W_Addr6,	
	input wire [ADDR_W-1:0]		W_Addr7,
	input wire [DATA_W-1:0]		W_Data0,	
	input wire [DATA_W-1:0]		W_Data1,
	input wire [DATA_W-1:0]		W_Data2,	
	input wire [DATA_W-1:0]		W_Data3,
	input wire [DATA_W-1:0]		W_Data4,	
	input wire [DATA_W-1:0]		W_Data5,
	input wire [DATA_W-1:0]		W_Data6,	
	input wire [DATA_W-1:0]		W_Data7,
	input wire					R_valid0,	
	input wire					R_valid1,
	input wire					R_valid2,	
	input wire					R_valid3,
	input wire					R_valid4,	
	input wire					R_valid5,
	input wire					R_valid6,	
	input wire					R_valid7,
	input wire 					W_valid0,			
	input wire 					W_valid1,
	input wire 					W_valid2,			
	input wire 					W_valid3,
	input wire 					W_valid4,			
	input wire 					W_valid5,
	input wire 					W_valid6,			
	input wire 					W_valid7,	
	output reg [DATA_W-1:0]		R_Data0,
	output reg [DATA_W-1:0]		R_Data1,
	output reg [DATA_W-1:0]		R_Data2,
	output reg [DATA_W-1:0]		R_Data3,
	output reg [DATA_W-1:0]		R_Data4,
	output reg [DATA_W-1:0]		R_Data5,
	output reg [DATA_W-1:0]		R_Data6,
	output reg [DATA_W-1:0]		R_Data7	
);

localparam Bank_Num = (2**Bank_Num_W);

wire [DATA_W-1:0] 				bank_rdata 	[Bank_Num-1:0];
wire [DATA_W-1:0] 				bank_wdata 	[Bank_Num-1:0];
wire [ADDR_W-Bank_Num_W-1:0] 	bank_raddr 	[Bank_Num-1:0];
wire [ADDR_W-Bank_Num_W-1:0] 	bank_waddr 	[Bank_Num-1:0];
wire 			  				bank_w_en  	[Bank_Num-1:0];
reg	 [Bank_Num_W-1:0] 		  	sel		 	[Bank_Num-1:0];

reg [ADDR_W-1:0]	R_Addr0_reg, R_Addr1_reg, R_Addr2_reg, R_Addr3_reg, R_Addr4_reg, R_Addr5_reg, R_Addr6_reg, R_Addr7_reg; 	
reg [ADDR_W-1:0]	W_Addr0_reg, W_Addr1_reg, W_Addr2_reg, W_Addr3_reg, W_Addr4_reg, W_Addr5_reg, W_Addr6_reg, W_Addr7_reg; 		
reg					R_valid0_reg, R_valid1_reg, R_valid2_reg, R_valid3_reg, R_valid4_reg, R_valid5_reg, R_valid6_reg, R_valid7_reg;	
reg					W_valid0_reg, W_valid1_reg, W_valid2_reg, W_valid3_reg, W_valid4_reg, W_valid5_reg, W_valid6_reg, W_valid7_reg; 	
reg [DATA_W-1:0]	W_Data0_reg, W_Data1_reg, W_Data2_reg, W_Data3_reg, W_Data4_reg, W_Data5_reg, W_Data6_reg, W_Data7_reg;	

always @(posedge clk) begin
	if(rst) begin
		R_Addr0_reg <= {ADDR_W{1'b0}};
		R_Addr1_reg <= {ADDR_W{1'b0}};
		R_Addr2_reg <= {ADDR_W{1'b0}};
		R_Addr3_reg <= {ADDR_W{1'b0}};
		R_Addr4_reg <= {ADDR_W{1'b0}};
		R_Addr5_reg <= {ADDR_W{1'b0}};
		R_Addr6_reg <= {ADDR_W{1'b0}};
		R_Addr7_reg <= {ADDR_W{1'b0}};
		W_Addr0_reg <= {ADDR_W{1'b0}};
		W_Addr1_reg <= {ADDR_W{1'b0}};
		W_Addr2_reg <= {ADDR_W{1'b0}};
		W_Addr3_reg <= {ADDR_W{1'b0}};
		W_Addr4_reg <= {ADDR_W{1'b0}};
		W_Addr5_reg <= {ADDR_W{1'b0}};
		W_Addr6_reg <= {ADDR_W{1'b0}};
		W_Addr7_reg <= {ADDR_W{1'b0}};
		R_valid0_reg <= 1'b0;
		R_valid1_reg <= 1'b0;
		R_valid2_reg <= 1'b0;
		R_valid3_reg <= 1'b0;
		R_valid4_reg <= 1'b0;
		R_valid5_reg <= 1'b0;
		R_valid6_reg <= 1'b0;
		R_valid7_reg <= 1'b0;
		W_valid0_reg <= 1'b0;
		W_valid1_reg <= 1'b0;
		W_valid2_reg <= 1'b0;
		W_valid3_reg <= 1'b0;
		W_valid4_reg <= 1'b0;
		W_valid5_reg <= 1'b0;
		W_valid6_reg <= 1'b0;
		W_valid7_reg <= 1'b0;	
		W_Data0_reg <= {DATA_W{1'b0}};
		W_Data1_reg <= {DATA_W{1'b0}};
		W_Data2_reg <= {DATA_W{1'b0}};
		W_Data3_reg <= {DATA_W{1'b0}};
		W_Data4_reg <= {DATA_W{1'b0}};
		W_Data5_reg <= {DATA_W{1'b0}};
		W_Data6_reg <= {DATA_W{1'b0}};
		W_Data7_reg <= {DATA_W{1'b0}};	
	end else begin
		R_Addr0_reg <= R_Addr0;
		R_Addr1_reg <= R_Addr1;
		R_Addr2_reg <= R_Addr2;
		R_Addr3_reg <= R_Addr3;
		R_Addr4_reg <= R_Addr4;
		R_Addr5_reg <= R_Addr5;
		R_Addr6_reg <= R_Addr6;
		R_Addr7_reg <= R_Addr7;
		W_Addr0_reg <= W_Addr0;
		W_Addr1_reg <= W_Addr1;
		W_Addr2_reg <= W_Addr2;
		W_Addr3_reg <= W_Addr3;
		W_Addr4_reg <= W_Addr4;
		W_Addr5_reg <= W_Addr5;
		W_Addr6_reg <= W_Addr6;
		W_Addr7_reg <= W_Addr7;
		R_valid0_reg <= R_valid0;
		R_valid1_reg <= R_valid1;
		R_valid2_reg <= R_valid2;
		R_valid3_reg <= R_valid3;
		R_valid4_reg <= R_valid4;
		R_valid5_reg <= R_valid5;
		R_valid6_reg <= R_valid6;
		R_valid7_reg <= R_valid7;
		W_valid0_reg <= W_valid0;
		W_valid1_reg <= W_valid1;
		W_valid2_reg <= W_valid2;
		W_valid3_reg <= W_valid3;
		W_valid4_reg <= W_valid4;
		W_valid5_reg <= W_valid5;
		W_valid6_reg <= W_valid6;
		W_valid7_reg <= W_valid7;
		W_Data0_reg <= W_Data0;
		W_Data1_reg <= W_Data1;
		W_Data2_reg <= W_Data2;
		W_Data3_reg <= W_Data3;
		W_Data4_reg <= W_Data4;
		W_Data5_reg <= W_Data5;
		W_Data6_reg <= W_Data6;
		W_Data7_reg <= W_Data7;
	end
end
	
genvar numbank; 
generate for(numbank=0; numbank < Bank_Num; numbank = numbank+1) 
	begin: elements	
		URAM #(.DATA_W(DATA_W), .ADDR_W(ADDR_W-Bank_Num_W))
		bank (
			.Data_in(bank_wdata[numbank]),
			.R_Addr(bank_raddr[numbank]),
			.W_Addr(bank_waddr[numbank]),
			.W_En(bank_w_en[numbank]),
			.En(1'b1),
			.clk(clk),
			.Data_out(bank_rdata[numbank])
		);
	end
endgenerate	
	
genvar i;
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: read_addr assign bank_raddr[i] = (R_valid0_reg && R_Addr0_reg[Bank_Num_W-1:0] ==i) ? R_Addr0_reg[ADDR_W-1:Bank_Num_W] :
										   (R_valid1_reg && R_Addr1_reg[Bank_Num_W-1:0] ==i) ? R_Addr1_reg[ADDR_W-1:Bank_Num_W] : 
										   (R_valid2_reg && R_Addr2_reg[Bank_Num_W-1:0] ==i) ? R_Addr2_reg[ADDR_W-1:Bank_Num_W] : 
										   (R_valid3_reg && R_Addr3_reg[Bank_Num_W-1:0] ==i) ? R_Addr3_reg[ADDR_W-1:Bank_Num_W] : 	  
										   (R_valid4_reg && R_Addr4_reg[Bank_Num_W-1:0] ==i) ? R_Addr4_reg[ADDR_W-1:Bank_Num_W] :
										   (R_valid5_reg && R_Addr5_reg[Bank_Num_W-1:0] ==i) ? R_Addr5_reg[ADDR_W-1:Bank_Num_W] : 
										   (R_valid6_reg && R_Addr6_reg[Bank_Num_W-1:0] ==i) ? R_Addr6_reg[ADDR_W-1:Bank_Num_W] : 
										   (R_valid7_reg && R_Addr7_reg[Bank_Num_W-1:0] ==i) ? R_Addr7_reg[ADDR_W-1:Bank_Num_W] : 1'b0;	  
   end 
endgenerate

generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_addr assign bank_waddr[i] = (W_valid0_reg && W_Addr0_reg[Bank_Num_W-1:0] ==i) ? W_Addr0_reg[ADDR_W-1:Bank_Num_W] :
										    (W_valid1_reg && W_Addr1_reg[Bank_Num_W-1:0] ==i) ? W_Addr1_reg[ADDR_W-1:Bank_Num_W] : 
											(W_valid2_reg && W_Addr2_reg[Bank_Num_W-1:0] ==i) ? W_Addr2_reg[ADDR_W-1:Bank_Num_W] : 
											(W_valid3_reg && W_Addr3_reg[Bank_Num_W-1:0] ==i) ? W_Addr3_reg[ADDR_W-1:Bank_Num_W] : 
											(W_valid4_reg && W_Addr4_reg[Bank_Num_W-1:0] ==i) ? W_Addr4_reg[ADDR_W-1:Bank_Num_W] :
										    (W_valid5_reg && W_Addr5_reg[Bank_Num_W-1:0] ==i) ? W_Addr5_reg[ADDR_W-1:Bank_Num_W] : 
											(W_valid6_reg && W_Addr6_reg[Bank_Num_W-1:0] ==i) ? W_Addr6_reg[ADDR_W-1:Bank_Num_W] : 
											(W_valid7_reg && W_Addr7_reg[Bank_Num_W-1:0] ==i) ? W_Addr7_reg[ADDR_W-1:Bank_Num_W] : 1'b0;
   end 
endgenerate

generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_data assign bank_wdata[i] = (W_valid0_reg && W_Addr0_reg[Bank_Num_W-1:0] ==i) ? W_Data0_reg :
										    (W_valid1_reg && W_Addr1_reg[Bank_Num_W-1:0] ==i) ? W_Data1_reg : 
											(W_valid2_reg && W_Addr2_reg[Bank_Num_W-1:0] ==i) ? W_Data2_reg :  
											(W_valid3_reg && W_Addr3_reg[Bank_Num_W-1:0] ==i) ? W_Data3_reg : 
											(W_valid4_reg && W_Addr4_reg[Bank_Num_W-1:0] ==i) ? W_Data4_reg :		
										    (W_valid5_reg && W_Addr5_reg[Bank_Num_W-1:0] ==i) ? W_Data5_reg : 
											(W_valid6_reg && W_Addr6_reg[Bank_Num_W-1:0] ==i) ? W_Data6_reg :  
											(W_valid7_reg && W_Addr7_reg[Bank_Num_W-1:0] ==i) ? W_Data7_reg : 1'b0;											
   end 
endgenerate

generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_enable assign bank_w_en[i] = (W_valid0_reg && W_Addr0_reg[Bank_Num_W-1:0] ==i) ? 1'b1 :
										     (W_valid1_reg && W_Addr1_reg[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid2_reg && W_Addr2_reg[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid3_reg && W_Addr3_reg[Bank_Num_W-1:0] ==i) ? 1'b1 :
											 (W_valid4_reg && W_Addr4_reg[Bank_Num_W-1:0] ==i) ? 1'b1 :
										     (W_valid5_reg && W_Addr5_reg[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid6_reg && W_Addr6_reg[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid7_reg && W_Addr7_reg[Bank_Num_W-1:0] ==i) ? 1'b1 : 1'b0;											 
   end 
endgenerate


integer j;												
always @(posedge clk) begin
	if(rst) begin
		R_Data0 <= {DATA_W{1'b0}};
		R_Data1 <= {DATA_W{1'b0}};
		R_Data2 <= {DATA_W{1'b0}};
		R_Data3 <= {DATA_W{1'b0}};
		R_Data4 <= {DATA_W{1'b0}};
		R_Data5 <= {DATA_W{1'b0}};
		R_Data6 <= {DATA_W{1'b0}};
		R_Data7 <= {DATA_W{1'b0}};
		sel[0]  <= {Bank_Num_W{1'b0}};   
		sel[1]  <= {Bank_Num_W{1'b0}};   
		sel[2]  <= {Bank_Num_W{1'b0}};   
		sel[3]  <= {Bank_Num_W{1'b0}};   
		sel[4]  <= {Bank_Num_W{1'b0}};   
		sel[5]  <= {Bank_Num_W{1'b0}};   
		sel[6]  <= {Bank_Num_W{1'b0}};   
		sel[7]  <= {Bank_Num_W{1'b0}};           
	end else begin		
		sel[0] <= R_Addr0[Bank_Num_W-1:0];			
		sel[1] <= R_Addr1[Bank_Num_W-1:0];			  
		sel[2] <= R_Addr2[Bank_Num_W-1:0];			
		sel[3] <= R_Addr3[Bank_Num_W-1:0];			  
		sel[4] <= R_Addr4[Bank_Num_W-1:0];			
		sel[5] <= R_Addr5[Bank_Num_W-1:0];			  
		sel[6] <= R_Addr6[Bank_Num_W-1:0];			
		sel[7] <= R_Addr7[Bank_Num_W-1:0];
		R_Data0 <= bank_rdata[sel[0]];
		R_Data1 <= bank_rdata[sel[1]];
		R_Data2 <= bank_rdata[sel[2]];
		R_Data3 <= bank_rdata[sel[3]];
		R_Data4 <= bank_rdata[sel[4]];
		R_Data5 <= bank_rdata[sel[5]];
		R_Data6 <= bank_rdata[sel[6]];
		R_Data7 <= bank_rdata[sel[7]];		
	end
end
endmodule

module URAM(
	Data_in,	// W
	R_Addr,	// R
	W_Addr,	// W
	W_En,	// W
	En,
	clk,
	Data_out	// R
	);
parameter DATA_W = 256;
parameter ADDR_W = 10;
localparam DEPTH = (2**ADDR_W);

input [DATA_W-1:0] Data_in;
input [ADDR_W-1:0] R_Addr, W_Addr;
input W_En;
input En;
input clk;
output reg [DATA_W-1:0] Data_out;

(* ram_style="ultra" *) reg [DATA_W-1:0] ram [DEPTH-1:0];
integer i;
initial for (i=0; i<DEPTH; i=i+1) begin
	ram[i] = 0;  	
end
always @(posedge clk) begin
	if (En) begin
		Data_out <= ram[R_Addr];
		if (W_En) begin
			ram[W_Addr] <= Data_in;
		end
	end	
end    
					
endmodule	

module prediction_unit #(
	parameter Delay = 7
)(
    input wire clk,
    input wire rst,
    input wire [32*32-1:0] p,    
    input wire [32*32-1:0] q,
	input wire [15:0] rating,		
    input wire  input_valid,
    output reg [31:0] err,
    output reg output_valid    
);    
wire  [31:0] level_product 	[31:0];
wire  level_valid [31:0];
wire  [31:0] level0_adder 	[15:0];
wire  level0_valid [15:0];	
wire  [31:0] level1_adder   [7:0];
wire  level1_valid [7:0];
wire  [31:0] level2_adder   [3:0];
wire  level2_valid [3:0];
wire  [31:0] level3_adder   [1:0];
wire  level3_valid [1:0];

wire [31:0] inner_product;
wire [31:0] rating_float;
wire		floating_rating_ready;
reg [31:0] 	rating_float_reg;
reg			floating_rating_ready_reg;

wire 		inner_product_ready;

reg [15:0] 	rating_reg [Delay-1:0]; 	
wire [31:0] err_wire;
wire output_valid_wire;
	
integer i;
always @(posedge clk) begin     
   if(rst) begin
		err <= {32{1'b0}};
		output_valid <= 1'b0;
		rating_float_reg <= {32{1'b0}};
		floating_rating_ready_reg <= 1'b0;
		for(i=0; i<Delay; i=i+1) begin 
			rating_reg [i] <= 0;            
		end
   end else begin
		for(i=1; i<Delay; i=i+1) begin 
		   rating_reg [i] <= rating_reg [i-1] ;                           
		end
		rating_reg [0] <= rating;            
		rating_float_reg <= rating_float;
		floating_rating_ready_reg <= floating_rating_ready;
		err <= err_wire;
		output_valid <= output_valid_wire;
   end
end	


genvar numstg;
generate
	for(numstg=0; numstg < 32; numstg = numstg+1)
	begin: mm_elements
		fp_mul multipliers (              
			.aclk    (clk),
			.s_axis_a_tvalid(input_valid),        
			.s_axis_a_tdata(p[32*numstg+31:32*numstg]),
			.s_axis_b_tvalid(input_valid),
			.s_axis_b_tdata(q[32*numstg+31:32*numstg]),
			.m_axis_result_tvalid(level_valid[numstg]),                    
			.m_axis_result_tdata(level_product[numstg])              
		);         
	end
endgenerate	

generate
	for(numstg=0; numstg < 16; numstg = numstg+1)
	begin: l1_elements
		fp_add l1_adders(
			.aclk    (clk),
			.s_axis_a_tvalid (level_valid[numstg*2]),
			.s_axis_a_tdata (level_product[numstg*2]),
			.s_axis_b_tvalid (level_valid[numstg*2+1]), 
			.s_axis_b_tdata (level_product[numstg*2+1]), 
			.m_axis_result_tvalid (level0_valid[numstg]),                     
			.m_axis_result_tdata (level0_adder[numstg])
		  );  
	end
endgenerate

generate
	for(numstg=0; numstg < 8; numstg = numstg+1)
	begin: l2_elements
		fp_add l2_adders(
			.aclk    (clk),
			.s_axis_a_tvalid (level0_valid[numstg*2]),
			.s_axis_a_tdata (level0_adder[numstg*2]),
			.s_axis_b_tvalid (level0_valid[numstg*2+1]), 
			.s_axis_b_tdata (level0_adder[numstg*2+1]), 
			.m_axis_result_tvalid (level1_valid[numstg]),                                            
			.m_axis_result_tdata (level1_adder[numstg])
		  );  
	end
endgenerate

generate
	for(numstg=0; numstg < 4; numstg = numstg+1)
	begin: l3_elements 
		fp_add l3_adders(
			.aclk    (clk),
			.s_axis_a_tvalid (level1_valid[numstg*2]),
			.s_axis_a_tdata (level1_adder[numstg*2]),
			.s_axis_b_tvalid (level1_valid[numstg*2+1]), 
			.s_axis_b_tdata (level1_adder[numstg*2+1]), 
			.m_axis_result_tvalid (level2_valid[numstg]),                                             
			.m_axis_result_tdata (level2_adder[numstg])
		  );  
	end
endgenerate
	
	
generate
		for(numstg=0; numstg < 2; numstg = numstg+1)
		begin: l4_elements 
			fp_add l4_adder(
				.aclk    (clk),
				.s_axis_a_tvalid (level2_valid[numstg*2]),
				.s_axis_a_tdata (level2_adder[numstg*2]),
				.s_axis_b_tvalid (level2_valid[numstg*2+1]), 
				.s_axis_b_tdata (level2_adder[numstg*2+1]), 
				.m_axis_result_tvalid (level3_valid[numstg]), 					                      
				.m_axis_result_tdata (level3_adder[numstg])
			); 
		end
endgenerate
 
fp_add l5_adder(
	.aclk    (clk),
	.s_axis_a_tvalid (level3_valid[0]),
	.s_axis_a_tdata (level3_adder[0]),
	.s_axis_b_tvalid (level3_valid[1]), 
	.s_axis_b_tdata (level3_adder[1]), 
	.m_axis_result_tvalid(inner_product_ready),
	.m_axis_result_tdata (inner_product)
); 

fp_fix_to_float fixed_to_float(	
	.aclk    (clk),
	.s_axis_a_tvalid (input_valid),
	.s_axis_a_tdata(rating_reg[Delay-1]),
	.m_axis_result_tvalid (floating_rating_ready),
	.m_axis_result_tdata(rating_float)
);
 
fp_add compute_err(
	.aclk    (clk),
	.s_axis_a_tvalid (floating_rating_ready_reg),
	.s_axis_a_tdata (rating_float_reg),
	.s_axis_b_tvalid (inner_product_ready), 
	.s_axis_b_tdata (inner_product), 
	.m_axis_result_tvalid (output_valid_wire),                           
	.m_axis_result_tdata (err_wire)
);	    
endmodule	

