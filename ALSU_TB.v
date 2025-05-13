module ALSU_tb(

    );
    parameter INPUT_PRIORITY="A";
    parameter FULL_ADDER="ON";
    reg cin,clk,rst,serial_in,direction,red_op_B,red_op_A,bypass_A,bypass_B;
    reg [2:0]A,B,opcode;
    wire [15:0]leds;
    wire [5:0]out;
    wire [5:0]mult_out;
    wire [3:0]fulladder_out;
wire [3:0]adder_out;
    ALSU #("A","OFF") uut(A,B,opcode,cin,clk,
                         rst,serial_in, direction,
                         red_op_B,red_op_A,bypass_A,
                         bypass_B,leds,out);
    mult_gen_0 m0 (
  .A(A),  // input wire [2 : 0] A
  .B(B),  // input wire [2 : 0] B
  .P(mult_out)  // output wire [5 : 0] P
);
    c_addsub_0 m1 (
  .A(A),        // input wire [2 : 0] A
  .B(B),        // input wire [2 : 0] B
  .C_IN(cin),  // input wire C_IN
  .S(fulladder_out)        // output wire [3 : 0] S
);
c_addsub_1 m2 (
  .A(A),  // input wire [2 : 0] A
  .B(B),  // input wire [2 : 0] B
  .S(adder_out)  // output wire [3 : 0] S
);
     integer i;  
    initial begin 
    clk=0;
    forever #1 clk=~clk;
    end 
    
    initial begin //2.1
    
    opcode=$urandom_range(0,5);
    rst=1;
    cin=0; serial_in=0; 
    direction=0;
    red_op_B=0;  red_op_A=0;bypass_A=0; 
    bypass_B=0;
    A=0; B=0;
    @(negedge clk);
    if(out!=0&leds!=0) begin 
    $display("error");
    $stop;
    end 
   
 
  //2.2
 bypass_A=1; bypass_B=1; rst=0;
 
 for(i=0;i<100;i=i+1)begin 
  A=$random; B=$random; 
 opcode=$urandom_range(0,5);
  @(negedge clk);
  @(negedge clk);
  if(out!=A) begin 
  $display("error");
  $stop;
 end

 end
 
 
  //2.3
 bypass_A=0; bypass_B=0; rst=0;
 opcode=0;
 for(i=0;i<100;i=i+1)begin 
  A=$random; B=$random; 
  red_op_A=$random; red_op_B=$random;
  @(negedge clk);
  @(negedge clk);
  
  if((out!=((&A)&B))&&(out!=(A&B))) begin 
  $display("error");
$stop;

  end
   
 end
 
 //2.4
 opcode=1; rst=0;
 for(i=0;i<100;i=i+1)begin 
  A=$random; B=$random; 
  red_op_A=$random; red_op_B=$random;
  @(negedge clk);
  @(negedge clk);
  if(out!=((^A)^B)&&out!=(A^B)) begin 
  $display("error");
$stop;
 end 
 end 
//2.5
opcode=2;  red_op_A=0; red_op_B=0;
 for(i=0;i<100;i=i+1)begin 
  A=$random; B=$random; 
 cin=$random;
  @(negedge clk);
  @(negedge clk);
  if(out!=fulladder_out) begin 
  $display("error");
$stop;
 end 
 end 
 //2.6
 opcode=3;  
 for(i=0;i<100;i=i+1)begin 
  A=$random; B=$random; 
  @(negedge clk);
  @(negedge clk);
  if(out!=mult_out) begin 
  $display("error");
$stop;
 end 
 end 
 //2.7
 opcode=4;  
 for(i=0;i<100;i=i+1)begin 
  A=$random; B=$random; 
 direction=$random; serial_in=$random;
  @(negedge clk);
  @(negedge clk);
   
 end 
//2.8
 opcode=5;  
 for(i=0;i<100;i=i+1)begin 
  A=$random; B=$random; 
 direction=$random; serial_in=$random;
  @(negedge clk);
  @(negedge clk);
  
 end 
 
 
 opcode=6;
 @(negedge clk);
  @(negedge clk);
$stop;
    end 
    endmodule