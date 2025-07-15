`timescale 1ns / 1ps

module tb_MF();

    // 参数定义
    parameter DATA_WIDTH = 8;
    parameter WINDOW_SIZE = 3;
    parameter FRAME_WIDTH = 20;
    parameter FRAME_HEIGHT = 20;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // 信号定义
    logic clk;
    logic rst_n;
    logic [DATA_WIDTH-1:0] s_axis_tdata;
    logic s_axis_tvalid;
    logic s_axis_tlast;
    logic s_axis_tuser;
    logic s_axis_tready;
    logic [DATA_WIDTH-1:0] m_axis_tdata;
    logic m_axis_tvalid;
    logic m_axis_tlast;
    logic m_axis_tuser;
    logic m_axis_tready;
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // 复位生成
    initial begin
        rst_n = 0;
        #(CLK_PERIOD*2);
        rst_n = 1;
    end
    
    // 实例化待测试模块
    MeanFilter #(
        .DATA_WIDTH(DATA_WIDTH),
        .WINDOW_SIZE(WINDOW_SIZE),
        .FRAME_WIDTH(FRAME_WIDTH),
        .FRAME_HEIGHT(FRAME_HEIGHT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tuser(s_axis_tuser),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tuser(m_axis_tuser),
        .m_axis_tready(m_axis_tready)
    );
    
    // 测试激励
    initial begin
        // 初始化信号
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        s_axis_tuser = 0;
        m_axis_tready = 1;
        
        // 等待复位完成
        wait(rst_n);
        #(CLK_PERIOD*10);
        
        // 开始测试
        $display("Starting MeanFilter test...");
        
        // 发送一帧测试数据
        send_frame();
        
        // 等待处理完成
        #(CLK_PERIOD*1000);
        
        $display("Test completed!");
        $finish;
    end
    
    // 发送一帧数据的任务
    task send_frame();
        integer row, col;
        logic [DATA_WIDTH-1:0] test_data;
        
        for (row = 0; row < FRAME_HEIGHT; row++) begin
            for (col = 0; col < FRAME_WIDTH; col++) begin
                // 生成测试数据（简单的渐变模式）
                test_data = (row + col) % 256;
                
                // 发送数据
                @(posedge clk);
                s_axis_tdata = test_data;
                s_axis_tvalid = 1;
                s_axis_tlast = (col == FRAME_WIDTH - 1);
                s_axis_tuser = (row == 0 && col == 0);
                
                // 等待握手
                while (!s_axis_tready) @(posedge clk);
            end
        end
        
        // 结束传输
        @(posedge clk);
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        s_axis_tuser = 0;
    endtask
    
    // 监控输出
    // always @(posedge clk) begin
    //     if (m_axis_tvalid && m_axis_tready) begin
    //         $display("Output: data=%d, last=%b, user=%b", m_axis_tdata, m_axis_tlast, m_axis_tuser);
    //     end
    // end
    
endmodule
