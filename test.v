module MMM42(A1,A2,B1,B2,N,S1,S2,clk);
input clk;
input [3:0]A1,A2,B1,B2,N;
output [6:0]S1,S2;
reg [3:0]a1,a2,b1,b2,n,bd1,bd2,d1,d2,w,y;
reg [6:0]s1,s2,s11,s21,s12,s22;
reg q,A,Ai1,Ai2,qi1,qi2,mbrfa_ctemp,bypass;
reg temp1,temp2;
integer i=0;
initial
begin
assign q=1'h0;
assign A=1'h0;
assign s1=7'h0;
assign s2=7'h0;
assign bd1=(B1<<1)^(B2<<1);
assign bd2=(B1<<1)&(B2<<1);
assign d1=bd1^bd2^n;
assign d2=bd1&bd2&n;
assign mbrfa_ctemp=1'h0;
assign bypass=1'h0;
assign qi1=1'h0;
assign qi2=1'h0;
assign s11=7'h0;
assign s21=7'h0;
assign s12=7'h0;
assign s22=7'h0;
assign w=4'h0;
assign y=4'h0;
assign Ai1=1'h0;
assign Ai2=1'h0;
end
always 
begin 
assign a1=A1;
assign b1=B1;
assign a2=A2;
assign b2=B2;
assign n=N;
end
always @(posedge clk)
begin
while(i<6)
begin

//mbrfa
assign temp1=(a1[i]&a2[i]);//carry_i+1
assign temp2=(a1[i+1]&a2[i+1]);//carry_i+2
assign mbrfa_ctemp=bypass?temp1:temp2;//mux
assign Ai1=a1[i]^a2[i]^mbrfa_ctemp;//A_i+1
assign Ai2=a1[i+1]^a2[i+1]^temp1;//A_i+2

//look-ahead unit
assign qi1=s11[1];//q_i+1
assign qi2=s21[1]^s11[2];q_i+2
assign bypass=~(qi1|Ai1);
assign q=bypass?qi2:qi1;//q_bar
assign A=bypass?Ai2:Ai1;//A_bar

//iteration variable
i=bypass?i+2:i+1;

//carry save adder 1
assign s11=(s1^s2^w)>>1;//S1'[i]
assign s21=(s1&s2&w)>>1;//S2'[i]

//carry save adder 2
assign s12=(s11^s21^y)>>1;//S1[i+1]
assign s22=(s11&s21&y)>>1;S2[i+1]

//multiplexers 3 and 4
assign s1=bypass?(s21>>1):s21;
assign s2=bypass?(s22>>1):s22;

//multiplexers 1 and 2
if((A==0)&(q==0))
begin
assign w=4'h0;
assign y=4'h0;
end
else if((A==0)&(q==1))
begin
assign w=N;
assign y=4'h0;
end
else if((A==1)&(q==0))
begin
assign w=bd1;
assign y=bd2;
end
else if((A==1)&(q==1))
begin
assign w=d1;
assign y=d2;
end
end
end
endmodule