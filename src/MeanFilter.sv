`timescale 1ns / 1ps

module MeanFilter #(
        parameter DATA_WIDTH = 8,
        parameter WINDOW_SIZE = 3,
        parameter FRAME_WIDTH = 640,
        parameter FRAME_HEIGHT = 512
    ) (
        input   clk,
        input   rst_n,
        input   [DATA_WIDTH-1:0] s_axis_tdata,
        input   s_axis_tvalid,
        input   s_axis_tlast,
        input   s_axis_tuser,
        output s_axis_tready,
        output  [DATA_WIDTH-1:0] m_axis_tdata,
        output  m_axis_tvalid,
        output  m_axis_tlast,
        output  m_axis_tuser,
        input  m_axis_tready
    );
    localparam int LATENCY_LINEBUF = (WINDOW_SIZE-1)*FRAME_WIDTH;
    localparam int LATENCY_ADDERTREE = $clog2(WINDOW_SIZE)*2; // 计算加法树的延时
    localparam int LATENCY_LINEBUF_R = WINDOW_SIZE - 1;
    localparam int LATENCY_TOTAL = LATENCY_LINEBUF + LATENCY_ADDERTREE + LATENCY_LINEBUF_R;

    localparam int WINDOW_NUM = WINDOW_SIZE * WINDOW_SIZE;

    // ---------------------- Line Buffer Start ---------------------- //
    logic [DATA_WIDTH-1:0] data_linebuf [0:WINDOW_SIZE-1];
    assign data_linebuf[0] = s_axis_tdata;
    generate
        for (genvar linebuf_idx = 0; linebuf_idx < WINDOW_SIZE - 1; linebuf_idx++) begin: LineBuf_gen
            LineBuf #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .LATENCY(FRAME_WIDTH)
                    ) linebuf_inst (
                        .clk(clk),
                        .rst_n(rst_n),
                        .in_valid(s_axis_tvalid),
                        .data_in(data_linebuf[linebuf_idx]),
                        .data_out(data_linebuf[linebuf_idx+1])
                    );
        end
    endgenerate
    // ---------------------- Line Buffer End ---------------------- //

    // ---------------------- Adder Tree Start ---------------------- //
    // 缓存每一行窗口大小的数据
    logic [DATA_WIDTH-1:0] data_linebuf_r[0:WINDOW_SIZE-1][0:WINDOW_SIZE-1];
    always_ff @(posedge clk) begin
        for (int linebuf_r_idx = 0; linebuf_r_idx < WINDOW_SIZE; linebuf_r_idx++) begin
            data_linebuf_r[linebuf_r_idx][1:WINDOW_SIZE-1] <= data_linebuf_r[linebuf_r_idx][0:WINDOW_SIZE-2];
            data_linebuf_r[linebuf_r_idx][0] <= data_linebuf[linebuf_r_idx];
        end
    end

    localparam int LINE_SUM_WIDTH = $clog2(WINDOW_SIZE) + DATA_WIDTH;
    logic [LINE_SUM_WIDTH-1:0] line_sum[0:WINDOW_SIZE-1];
    generate
        for (genvar linebuf_idx = 0; linebuf_idx < WINDOW_SIZE; linebuf_idx++) begin
            AdderTree #(
                          .DATA_IN_WIDTH(DATA_WIDTH),
                          .DATA_NUM(WINDOW_SIZE),
                          .DATA_OUT_WIDTH(LINE_SUM_WIDTH)
                      ) adder_tree_inst (
                          .clk(clk),
                          .rst_n(rst_n),
                          .data_in(data_linebuf_r[linebuf_idx]),
                          .data_out(line_sum[linebuf_idx])
                      );
        end
    endgenerate

    localparam int SUM_WIDTH = $clog2(WINDOW_NUM) + DATA_WIDTH;
    logic [SUM_WIDTH-1:0] sum_data;
    AdderTree #(
                  .DATA_IN_WIDTH(LINE_SUM_WIDTH),
                  .DATA_NUM(WINDOW_SIZE),
                  .DATA_OUT_WIDTH(SUM_WIDTH)
              ) adder_tree_sum_inst (
                  .clk(clk),
                  .rst_n(rst_n),
                  .data_in(line_sum),
                  .data_out(sum_data)
              );
    // ---------------------- Adder Tree End ---------------------- //

    // ---------------------- Output Logic Start ---------------------- //
    localparam int LATENCY_TOTAL_WIDTH = $clog2(LATENCY_TOTAL);

    logic [LATENCY_TOTAL_WIDTH-1:0] latency_cnt;
    logic s_fire;
    logic m_fire;
    logic initial_delayed;

    assign s_fire = s_axis_tvalid && s_axis_tready;
    assign m_fire = m_axis_tvalid && m_axis_tready;
    assign initial_delayed = (latency_cnt >= LATENCY_TOTAL - 1);

    always_ff @(posedge clk) begin : latency_counter
        if (!rst_n) begin
            latency_cnt <= 'd0;
        end
        else begin
            if (s_fire) begin
                if (latency_cnt < LATENCY_TOTAL) begin
                    latency_cnt <= latency_cnt + 'd1;
                end
            end
        end
    end

    localparam int WIDTH_WIDTH = $clog2(FRAME_WIDTH);
    localparam int HEIGHT_WIDTH = $clog2(FRAME_HEIGHT);

    logic [WIDTH_WIDTH-1:0] out_hcnt;
    logic [HEIGHT_WIDTH-1:0] out_vcnt;
    always_ff @(posedge clk) begin : output_counter
        if (!rst_n) begin
            out_hcnt <= 'd0;
            out_vcnt <= 'd0;
        end
        else if (m_fire) begin
            if (out_hcnt < FRAME_WIDTH - 1) begin
                out_hcnt <= out_hcnt + 'd1;
            end
            else begin
                out_hcnt <= 'd0;
                if (out_vcnt < FRAME_HEIGHT - 1) begin
                    out_vcnt <= out_vcnt + 'd1;
                end
                else begin
                    out_vcnt <= 'd0;
                end
            end
        end
    end

    assign m_axis_tvalid = initial_delayed && s_fire;
    assign m_axis_tlast = m_fire && (out_hcnt == FRAME_WIDTH - 1);
    assign m_axis_tuser = m_fire && (out_hcnt == 0) && (out_vcnt == 0);
    assign m_axis_tdata = sum_data / WINDOW_NUM;
    assign s_axis_tready = m_axis_tready;
    // ---------------------- Output Logic End ---------------------- //

endmodule


module AdderTree #(
        parameter DATA_IN_WIDTH = 8,
        parameter DATA_NUM = 3,
        parameter DATA_OUT_WIDTH = 8
    ) (
        input   clk,
        input   rst_n,
        input   [DATA_IN_WIDTH-1:0] data_in[0:DATA_NUM-1],
        output  [DATA_OUT_WIDTH-1:0] data_out
    );
    localparam int SUM_TOTAL_STAGES = $clog2(DATA_NUM);
    function integer min_int(input integer a, input integer b);
        begin
            min_int = (a < b) ? a : b;
        end
    endfunction
    function integer get_pruned_number(input integer inv_level, input integer depth, input integer max_leaves);
        begin : calculate_number
            integer threshold;
            integer level_max;
            integer remainder;
            remainder         = max_leaves % (1 << inv_level);
            threshold         = max_leaves / (1 << inv_level);
            threshold         = remainder > 0 ? threshold + 1 : threshold;  // ceil round
            level_max         = 1 << (depth - 1 - inv_level);
            get_pruned_number = min_int(threshold, level_max);
        end
    endfunction

    logic [DATA_OUT_WIDTH-1:0] sum_data[0:DATA_NUM-1][0:SUM_TOTAL_STAGES-1];
    
    // 第0级直接连接输入数据, range is not allowed in a prefix
    generate
        for (genvar i = 0; i < DATA_NUM; i++) begin
            assign sum_data[i][0] = data_in[i];
        end
    endgenerate
    
    // 如果只有一级，直接输出；否则进行加法树计算
    generate
        if (SUM_TOTAL_STAGES > 1) begin
            always_ff @(posedge clk) begin
                for (int sum_stages = 1; sum_stages < SUM_TOTAL_STAGES; sum_stages++) begin // 从第1级开始计算
                    integer number;
                    integer number_paired;
                    integer number_single;
                    number = get_pruned_number(sum_stages, SUM_TOTAL_STAGES, DATA_NUM);
                    number_paired = number / 2;
                    number_single = number % 2;

                    for (int i = 0; i < number_paired; i++) begin
                        sum_data[i][sum_stages] <= sum_data[2*i][sum_stages-1] + sum_data[2*i+1][sum_stages-1];
                    end
                    for (int i = 0; i < number_single; i++) begin
                        sum_data[number_paired+i][sum_stages] <= sum_data[2*number_paired+i][sum_stages-1];
                    end
                end
            end
        end
    endgenerate
    assign data_out = sum_data[0][SUM_TOTAL_STAGES-1];
endmodule
