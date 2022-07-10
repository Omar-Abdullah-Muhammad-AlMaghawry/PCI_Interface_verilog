`define MemRead 4'b0110
`define MemWrite 4'b0111


module clk(clk);
	output reg clk = 1;
	always begin
		#5 clk = ~clk;
		end
endmodule


module TestBench010101();
	wire [31:0] AD;
	wire [3:0] CBEn;
	wire PAR, FRAMEn, TRDYn, IRDYn, STOPn, DEVSELn, IDSEL, PERRn, SERRn, CLK, RSTn;
	clk clock(CLK);
	Target0101 target(AD, CBEn, PAR, FRAMEn, TRDYn, IRDYn, STOPn, DEVSELn, IDSEL, PERRn, SERRn, CLK, RSTn);
	reg [31:0] ADR;
	reg [3:0] CBEnR;
	reg PARR, FRAMEnR, TRDYnR, IRDYnR, STOPnR, DEVSELnR, IDSELR, PERRnR, SERRnR, RSTnR;
	reg readOp;
	reg parR;
	assign AD = (readOp)? 32'hzzzzzzzz:ADR;
	assign FRAMEn = FRAMEnR;
	assign IRDYn = IRDYnR;
	assign RSTn = RSTnR;
	assign CBEn = CBEnR;
	assign PAR= (~readOp)? parR:1'bz;

	reg [2:0] cases = 3'b101; //CHOOSE TEST CASE

initial
begin
case(cases)
////comm2 write initial
//CASE 1
	3'b001 : begin
readOp=0;
		IRDYnR = 1;
		RSTnR = 0;
		#50 RSTnR = 1;
		#5
		FRAMEnR = 0;
		ADR = 32'hAAAAA;
		CBEnR =`MemWrite;
		#10
		IRDYnR = 0;
      //ADR = 32'hAAAAA; //address BEreg   
		CBEnR=4'b0000;
		ADR = 32'hAABAA; //data1 
		#10
		CBEnR=4'b0000;
      		ADR = 32'hCABAA; //data2
		#10
		CBEnR=4'b0000;
     		 ADR = 32'hCABFA;  //data3
		#10
		FRAMEnR = 1;
		CBEnR=4'b0000;
      ADR = 32'hCABAB; //data4
		//#50;
		#10 IRDYnR = 1;

		#20

	$finish;
	end

////write then read
/////
//CASE 2 write then read **with par** whithout waiting on IDRYnR or any Masking or any more data than no. of reg on buffer
 
	3'b010:
		begin
		readOp = 0;
		IRDYnR = 1;
		parR=0;
		RSTnR = 0;
	#50 	RSTnR = 1;
	#5;
		FRAMEnR = 0;
		parR=0;
		ADR = 32'hAAAAA;
		CBEnR =`MemWrite;
	#10;
		IRDYnR = 0;
		parR=0;
		CBEnR=4'b0000;
	  	ADR = 32'hAABAA; //data1 
	#10;
		parR=1;
		CBEnR=4'b0000;
	        ADR = 32'hCABAA; //data2
	#10;
		parR=1;
		CBEnR=4'b0000;
	        ADR = 32'hCABFA; //data3
	#10
		FRAMEnR = 1;
		CBEnR=4'b0000;
	        ADR = 32'hCABAB; //data4
	#10     IRDYnR = 1;
	#20;   // readOp=1;
	

///comm3 read 

	#10
		ADR = 32'hAAAAC;
		CBEnR=`MemRead;
		FRAMEnR = 0;
	#10     IRDYnR <= 0;
		readOp <= 1;
		CBEnR<=4'b0000;
	#10	CBEnR<=4'b0000;
	#10	CBEnR<=4'b0000;
	#10 	CBEnR<=4'b0000;
	#10	CBEnR<=4'b0000;
 	#10 	FRAMEnR <= 1;
	#10 	IRDYnR <= 1;
	#20;   // readOp=0;

		$finish;

end
/////
	//CASE 3 write then read **with masks** //////whithout waiting on IDRYnR or any more data than no. of reg on buffer or any par
 
	3'b011:
		begin
		readOp = 0;
		IRDYnR = 1;
		RSTnR = 0;
		#50 RSTnR = 1;
		#5;
		FRAMEnR = 0;
		ADR = 32'hAAAAA;
		CBEnR =`MemWrite;
		#10;
		IRDYnR = 0;   
		CBEnR=4'b0001;
    		ADR = 32'hFFFFFFFF; //data1 
		#10;
		CBEnR=4'b0010;
		ADR = 32'hFFFFFFFF; //data2
		#10;
		CBEnR=4'b0100;
     		ADR = 32'hFFFFFFFF;  //data3
		#10
		FRAMEnR = 1;
		CBEnR=4'b1000;
      		ADR = 32'hFFFFFFFF; //data4
		//#50;
		#10 IRDYnR = 1;
		#20;

	

///comm3 read 


      #10
		ADR = 32'hAAAAA;
		CBEnR=`MemRead;
		FRAMEnR = 0;
		#10 IRDYnR = 0;
		readOp = 1;
		CBEnR=4'b0000;
		#10 CBEnR=4'b1000;
		#10 CBEnR=4'b0100;
		IRDYnR = 1;
		#10 IRDYnR = 0;
		#10 CBEnR=4'b0010;
		#10 CBEnR=4'b0001;
		FRAMEnR = 1;
		#10 IRDYnR = 1;
		ADR = 32'h5a1ac;
		#20;

	$finish;

end
/////
//CASE 4 write then read **with more data than no. of reg on buffer** //////whithout waiting on IDRYnR or any masks or any par
 
	3'b100:
		begin
		readOp = 0;
		IRDYnR = 1;
		RSTnR = 0;
	#50 	RSTnR = 1;
	#5;
		FRAMEnR = 0;
		ADR = 32'hAAAAA;
		CBEnR =`MemWrite;
	#10;
		IRDYnR = 0;
		CBEnR=4'b0000;
	  	ADR = 32'hAABAA; //data1 
	#10;
		CBEnR=4'b0000;
	        ADR = 32'hCABAA; //data2
	#10;
		CBEnR=4'b0000;
	        ADR = 32'hCABFA;  //data3
	#10
		CBEnR=4'b0000;
	        ADR = 32'hCABAB; //data4
	#10
		FRAMEnR = 1;
		CBEnR=4'b0000;
     		ADR = 32'hCABAF; //data5
	#10     IRDYnR = 1;
	#20;
	

///comm3 read 

	#10
		ADR = 32'hAAAAC;
		CBEnR=`MemRead;
		FRAMEnR = 0;
	#10     IRDYnR <= 0;
		readOp <= 1;
		CBEnR<=4'b0000;
	#10	CBEnR<=4'b0000;
	#10	CBEnR<=4'b0000;
	#10 	CBEnR<=4'b0000;
	#10	CBEnR<=4'b0000;
 	#10 	FRAMEnR <= 1;
	#10 	IRDYnR <= 1;
	#20;

			$finish;

end
/////
//CASE 5 write then read **with waiting on IDRYnR And more data than no. of reg on buffer and par** //////whithout masks   
	3'b101:
		begin
		readOp = 0;
		IRDYnR = 1;
		parR=0;
		RSTnR = 0;
	#50 	RSTnR = 1;
	#5;
		FRAMEnR = 0;
		parR=1;
		ADR = 32'hAAAAA;
		CBEnR =`MemWrite;
	#10;
		IRDYnR = 0;
		parR=1;
		CBEnR=4'b0000;
	  	ADR = 32'hAABAA; //data1 
	#10;
		CBEnR=4'b0000;
		parR=0;
	        ADR = 32'hCABAA; //data2
	#10;
		parR=0;
		CBEnR=4'b0000;
	        ADR = 32'hCABFA;  //data3
	#10
		parR=0;
		CBEnR=4'b0000;
	        ADR = 32'hCABAB; //data4
	#10
		parR=0;
		FRAMEnR = 1;
		CBEnR=4'b0000;
     		ADR = 32'hCABAF; //data5
	#10     IRDYnR = 1;
	#20;
	
///comm3 read 

        #10
		ADR = 32'hAAAAC;
		CBEnR=`MemRead;
		FRAMEnR = 0;
	#10 	IRDYnR <= 0;
		readOp <= 1;
		CBEnR<=4'b0000;
	#10 	CBEnR<=4'b0000;
	#10 	CBEnR<=4'b0000;
		IRDYnR <= 1; //second senario
 	#10	IRDYnR <= 0;
	#10 	CBEnR<=4'b0000;
		IRDYnR <= 1; //second senario
 	#10 	IRDYnR <= 0;
	#10 	CBEnR<=4'b0000;
		IRDYnR <= 1; //second senario
 	#10 	IRDYnR <= 0;
		FRAMEnR <= 1;
	#10 	IRDYnR <= 1;
	#20;
		$finish;

end
endcase
end
	always #10 begin
	$monitor("DEVSELn=%b, FRAMEn=%b, IRDYn=%b, TRDYn=%b, data=%h at time %t ",DEVSELn ,FRAMEn, IRDYn , TRDYn,ADR, $time);
	end

endmodule
