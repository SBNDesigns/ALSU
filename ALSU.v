module ALSU #(parameter INPUT_PRIORITY="A",FULL_ADDER="ON")(
input [2:0]A,B,opcode,
input cin,clk,rst,serial_in,direction,red_op_B,red_op_A,bypass_A,bypass_B,
output reg [15:0]led,
output reg[5:0]out

);
integer i;
wire [3:0]fulladder_out;
wire [3:0]adder_out;
wire [5:0]mult_out;
reg  [2:0]a_reg,b_reg,opcode_reg;
reg    cin_reg,serial_in_reg,direction_reg,red_op_A_reg,red_op_B_reg,bypass_A_reg,bypass_B_reg;

mult_gen_0 m0 (
  .A(a_reg),  // input wire [2 : 0] A
  .B(b_reg),  // input wire [2 : 0] B
  .P(mult_out)  // output wire [5 : 0] P
);
 generate 
 if(FULL_ADDER=="ON")begin 
 c_addsub_0 m2 (
  .A(a_reg),        // input wire [2 : 0] A
  .B(b_reg),        // input wire [2 : 0] B
  .C_IN(cin_reg),  // input wire C_IN
  .S(fulladder_out)        // output wire [3 : 0] S
);
 end 
 else if(FULL_ADDER=="OFF")begin 
 c_addsub_1 m1 (
  .A(a_reg),  // input wire [2 : 0] A
  .B(b_reg),  // input wire [2 : 0] B
  .S(adder_out)  // output wire [3 : 0] S
);
 end 
 endgenerate 
always @(posedge clk or posedge rst) begin

led<=0;
if(rst) begin
       out<=0;
       {cin_reg,serial_in_reg,direction_reg,red_op_A_reg,red_op_B_reg,bypass_A_reg,bypass_B_reg,a_reg,b_reg,opcode_reg}<='b0000000000;
    end
    
else begin
     cin_reg<=cin; serial_in_reg<=serial_in; direction_reg<=direction;
      red_op_A_reg<=red_op_A; red_op_B_reg<=red_op_B;
     bypass_A_reg<=bypass_A; bypass_B_reg<=bypass_B; a_reg<=A;
      b_reg<=B; opcode_reg<=opcode;
     if(bypass_A_reg&&bypass_B_reg)begin
         if(INPUT_PRIORITY=="A")  out<=a_reg;
         else if(INPUT_PRIORITY=="B") out<=b_reg; 
    end
    else if(bypass_A)out<=a_reg;
    else if(bypass_B)out<=b_reg;
    else begin 
    casex (opcode_reg)
        'b000:if((red_op_B_reg)&&(red_op_A_reg)&&(INPUT_PRIORITY=="A"))begin   
            out<=((&a_reg)&b_reg);  end
              else if((red_op_A_reg)&&(red_op_B_reg)&&(INPUT_PRIORITY=="B")) begin  
                out<=((&b_reg)&a_reg);end
              else out<=(a_reg&b_reg);
              
        'b001:if((red_op_B_reg)&&(red_op_A_reg)&&(INPUT_PRIORITY=="A"))begin   
             out<=((^a_reg)^b_reg);  end
              else if((red_op_A_reg)&&(red_op_B_reg)&&(INPUT_PRIORITY=="B")) begin   out<=((^b_reg)^a_reg);end 
              else out<=(a_reg^b_reg);
              
        'b010:if(FULL_ADDER=="ON") out<=fulladder_out; 
               else if(FULL_ADDER=="off") out<=adder_out;
               
        'b011: out<=mult_out; 
        
        'b100: if(direction) out<={out[4:0],serial_in_reg};//shift
                else out<={serial_in_reg,out[5:1]};
                
        'b101: if(direction) out<={out[4:0],out[5]};//rotation
               else out<={out[0],out[5:1]}; 
               
        'b11x:   for(i=0;i<16;i=i+1)begin
                               led <= ~led ; out<=0;
                        end
         default :out<=0;       
    endcase
end
    end

    end

endmodule


