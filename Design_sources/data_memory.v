`timescale 1ns / 1ps

module data_memory(
    input         clk,
    input  [7:0]  read_addr,
    input  [7:0]  write_addr,
    input  [7:0]  acc,
    input         mem_ren_wen, //reads for 0 and writes at 1
    output [7:0]  mem_output
);
    integer i = 0;
    reg [7:0] data_mem [255:0];

    initial begin
        for(i = 0; i < 256; i = i + 1)
            data_mem[i] <= 8'b0;
    end

    always @(posedge clk) begin
        if (mem_ren_wen)
            data_mem[write_addr] <= acc;
    end

    assign mem_output = (mem_ren_wen == 1'b0) ? data_mem[read_addr] : 8'b0;

endmodule