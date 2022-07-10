module Target010101(AD, CBEn, PAR, FRAMEn, TRDYn, IRDYn, STOPn, DEVSELn, IDSEL, PERRn, SERRn, CLK, RSTn);
	inout [31:0] AD;
	input [3:0] CBEn;
	inout PAR, DEVSELn, IDSEL, STOPn, TRDYn, PERRn, SERRn;
	input FRAMEn, IRDYn, CLK, RSTn;
	parameter [31:0] devAddr0 = 32'h000AAAAA;
	parameter [31:0] devAddr1 = 32'h000AAAAB;
	parameter [31:0] devAddr2 = 32'h000AAAAC;
	parameter [31:0] devAddr3 = 32'h000AAAAD;
	reg [2:0] buffer_counter;
	reg [31:0] buffer[0:3];
    	reg [31:0] adr;
	reg [3:0] command;
	reg devSelR;
	reg trdyR;
        reg writing;
	reg[31:0] memory [0:1023];
	reg[0:9] memory_counter;
	reg parR;
	reg perrR;
	reg pp;
	reg wrpp;
	reg rpar;

	always @(posedge CLK or negedge RSTn) begin
		if(~RSTn)
			begin
			buffer_counter = 2'b00;
			adr = 0;
			devSelR = 1'bz;
			trdyR = 1'bz;
			writing =0;
			wrpp=1'b1;
			rpar=1'b0;
			memory_counter=10'b0000000000;
			perrR=1'bz;
			parR=1'bz;
			end 

		else
			case({FRAMEn,IRDYn})
				2'b01:begin 
					if ((AD==devAddr0||AD== devAddr1||AD== devAddr2||AD== devAddr3)& DEVSELn===1'bz) // devsel for deff bet. two waiting and internal		
					begin

					buffer_counter=AD-devAddr0;
					command=CBEn;
						case(command)
						4'b0111:begin //write
							wrpp <=#15 0;
							pp<= (^{AD,CBEn});
							perrR<=#5 ~(^{pp,PAR});
							trdyR<=#5 1'b0;
							devSelR<=#5 1'b0;
							end //write
						4'b0110:begin //read
							rpar<=0;
							wrpp <=#15 0;//perr here for adresses that come 
							pp<= (^{AD,CBEn});//perr here for adresses that come
							perrR<=#5 ~(^{pp,PAR});//perr here for adresses that come
							if(AD===32'bz) parR <= #5 1'bz;
							else parR<=#5 (^{AD,CBEn});
							trdyR<=#5 1'b1;
							trdyR<=#15 1'b0;
							adr <=32'hzzzzzzzz;
							devSelR<=#5 1'b0;
							end //read
						endcase //initial
					end//intial
					else if( DEVSELn==1'b0 & trdyR==1'b0 )// devsel for deff bet. two waiting and internal & //new added trdyR maybe doesn't work for waiting 
						begin
						writing <=1;
						adr <=#15 buffer[buffer_counter] & {{8{~CBEn[3]}},{8{~CBEn[2]}},{8{~CBEn[1]}},{8{~CBEn[0]}}}; //reg for presduail block*/
						if(buffer_counter==3) //buffer_counter reset
							buffer_counter=0;
						end
					end //01
				2'b00:begin
					if(DEVSELn==1'b0 ) //new addaition
						case(command)
							4'b0111:begin //write
								writing <= 0;
								wrpp <=#15 0;
								pp<= (^{AD,CBEn});
								perrR<=#5 ~(^{pp,PAR});
								buffer[buffer_counter] = AD  & {{8{~CBEn[3]}},{8{~CBEn[2]}},{8{~CBEn[1]}},{8{~CBEn[0]}}};
								if(buffer_counter==3) //buffer_counter reset
									begin
									buffer_counter<=0;
									memory[memory_counter]=buffer[0];
									memory_counter=memory_counter+1;
									memory[memory_counter]=buffer[1];
									memory_counter=memory_counter+1;
						 			memory[memory_counter]=buffer[2];
									memory_counter=memory_counter+1;
						 			memory[memory_counter]=buffer[3];
									memory_counter=memory_counter+1;
									if(memory_counter==1023)memory_counter=10'b0000000000;
									end
								else
									buffer_counter = buffer_counter + 1;
								end //write
							4'b0110:begin //read
								writing <=1;	
								adr <=#5 buffer[buffer_counter] & {{8{~CBEn[3]}},{8{~CBEn[2]}},{8{~CBEn[1]}},{8{~CBEn[0]}}}; //reg for presduail block*/
								rpar<=0;
								if(AD===32'bz) #5 parR<=1'bz;
								else parR<=#5 ^{AD,CBEn};
								if(buffer_counter==3) //buffer_counter reset
									begin 
									buffer_counter=2'b00;
									end
								else
									buffer_counter = buffer_counter + 1;
								end //read
						endcase //excution with adress line
			end //end excuation
					2'b10:begin//final 
						case(command)
							4'b0111:begin //write
								writing <= 0;
								wrpp <= 0;
								pp<=(^{AD,CBEn});
								perrR<=~(^{pp,PAR});
								buffer[buffer_counter] = AD  & {{8{~CBEn[3]}},{8{~CBEn[2]}},{8{~CBEn[1]}},{8{~CBEn[0]}}};
								if(buffer_counter==3) //buffer_counter reset
									begin 
									buffer_counter<=2'b00;
									memory[memory_counter]=buffer[0];
									memory_counter=memory_counter+1;
						 			memory[memory_counter]=buffer[1];
									memory_counter=memory_counter+1;
						 			memory[memory_counter]=buffer[2];
									memory_counter=memory_counter+1;
						 			memory[memory_counter]=buffer[3];
									memory_counter=memory_counter+1;
									if(memory_counter==1023)memory_counter=10'b0000000000;
									end
								trdyR<=#5 1'bz;
								devSelR<=#5 1'bz;
								end //write
							4'b0110:begin //read
								trdyR<=#5 1'bz;
								devSelR<=#5 1'bz;
								end //read
							endcase //end
						end
				2'b11:begin
					trdyR<= 1'bz;
					devSelR<= 1'bz;
					end
			endcase //bigone
	end


	assign DEVSELn = (devSelR === 0)? 1'b0 : 1'bz;
	assign TRDYn = (trdyR === 0)? 1'b0 : ((trdyR === 1'b1) ? 1'b1 :	 1'bz);
	assign AD = (writing == 1)? adr : 32'hzzzzzzzz; //high impedance z
	assign PAR=(rpar==0)? parR:1'bz;
	assign PERRn=(wrpp== 0)?perrR:1'bz;
endmodule
