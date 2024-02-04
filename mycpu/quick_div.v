`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/24 21:02:26
// Design Name: 
// Module Name: div
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


module quick_div(
    input wire clk,rst,
    input wire [31:0] a,b,  //a�Ǳ�������b�ǳ���
    input wire valid,
    input wire is_sign,  //�����ж��Ƿ����з��ŵĳ�������
    output reg div_stall,  //��ǳ������Ƿ���æ
    output wire [63:0] result   //��32λ����������32λ����
    );
    
    wire [31:0] divident_abs,divisor_abs;
    wire [31:0] final_remainer,final_quotient;
    reg [31:0] a_save,b_save;
    reg is_sign_save;
    reg [64:0] Shift_right;   //��ʼʱ��32λ��������һλ����ڸ�33λ����32λ��0
    reg [31:0] remainer_temp; //��������ʼ��Ϊ����������󲻶ϼ������󣬽��Ϊ����
    wire [31:0] quotient_temp;
    wire [32:0] divisor_temp;
    wire carry_out;    //�ӷ�����λ�������жϵ�ǰ������-�����Ǵ��ڵ���0����С��0
    wire [32:0] sub_result;
    wire [31:0] mux_result;
    reg left_shift; //�Ƿ������ƽ׶Σ�������������Ľ׶�
    reg [31:0] flag;
    
    assign divisor_temp = Shift_right[64:32];   //��������λ�Ĵ����ĸ�33λ
    assign quotient_temp = {Shift_right[0],Shift_right[1],Shift_right[2],Shift_right[3],Shift_right[4],Shift_right[5],Shift_right[6],Shift_right[7],Shift_right[8],
                       Shift_right[9],Shift_right[10],Shift_right[11],Shift_right[12],Shift_right[13],Shift_right[14],Shift_right[15],Shift_right[16],
                       Shift_right[17],Shift_right[18],Shift_right[19],Shift_right[20],Shift_right[21],Shift_right[22],Shift_right[23],Shift_right[24],
                       Shift_right[25],Shift_right[26],Shift_right[27],Shift_right[28],Shift_right[29],Shift_right[30],Shift_right[31]}; //������λ�Ĵ����ĵ�32λ������
    
    //�����ֵ
    assign divident_abs = (is_sign & a[31]) ? ~a + 1'b1 : a;
    assign divisor_abs = (is_sign & b[31]) ? ~b + 1'b1 : b;
    
    adder_with_carry adder(1'b1,~divisor_temp,{1'b0,remainer_temp},sub_result,carry_out); //������-����
    
    
    assign mux_result = !left_shift & carry_out ? sub_result[31:0] : remainer_temp;   //���ƽ׶�˵������������carry_outΪ1��˵����������ȥ��������0�����±���������֮����
    
    //��
    always @(posedge clk,posedge rst) begin
        if(rst)begin
            div_stall <= 1'b0;    
            left_shift <=1'b0; 
            a_save <= 1'b0;
            b_save <= 1'b0;
            is_sign_save <= 1'b0;
            remainer_temp <= 32'b0;
            Shift_right<= 33'b0;
            flag <= 32'h0000_0000;
        end
        
        else if(!div_stall & valid) begin   //��ǰ�����������У����Կ�ʼ����,���г�ʼ��
            left_shift <= 1'b1;
            div_stall <= 1'b1;
            a_save <= a;
            b_save <= b;
            is_sign_save <= is_sign;
            remainer_temp <= divident_abs;
            Shift_right[64:32] <= {divisor_abs[31:0],1'b0};  //��ʼ������һ��
            flag <= 32'h0000_0002;
            Shift_right[31:0] <= 32'b0;
        end
        
        else if(div_stall) begin   //��������ʼ����
            if(left_shift & carry_out) begin    //carry_out=1˵�����Գ�
                Shift_right <= {Shift_right[63:0],1'b0};   //���Ƴ���:�������
                flag <= {flag[30:0],1'b0};
            end
            if(left_shift & !carry_out) begin   //carry_out=0˵��������С�ڳ���
                left_shift <= 1'b0;       //���ƽ���
                Shift_right <= {1'b0,Shift_right[64:1]};    //��������һ��
                flag <= {1'b0,flag[31:1]}; 
            end
            else if(!left_shift) begin  //��ʼ������
                if(flag[0]) begin //flag��1�ƶ�����0λ����������
                   //end
                    remainer_temp <= mux_result;
                    Shift_right[31] <= carry_out;   //�������µ���
                    div_stall <= 1'b0; 
                end
                else begin
                    remainer_temp <= mux_result;
                    Shift_right <= {1'b0,Shift_right[64:32],carry_out,Shift_right[30:1]}; //�������µ���
                    flag <= {1'b0,flag[31:1]};
                end
            end
        end
    end
    
    //���������뱻������ͬ
    assign final_remainer = (is_sign_save & a_save[31]) ? ~remainer_temp + 1'b1 : remainer_temp;
    assign final_quotient = (is_sign_save & (a_save[31] ^ b_save[31])) ? ~quotient_temp + 1'b1 : quotient_temp;
    assign result = {final_remainer,final_quotient};
    
endmodule
