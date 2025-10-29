module sram_test_design (
    input           clk,
    input           rst,
    input           scan_in,
    input           scan_en,
    input           start_op,
    input           op_type,
    input  [7:0]    addr_in,
    input  [7:0]    data_in,
    output [7:0]    data_out,
    output          done,
    output          scan_out
);
    wire mem_ren_wen;
    wire [7:0] ram_read_addr, ram_write_addr, ram_data_in, ram_data_out;

    memory_controller_with_scan controller (
        .clk(clk),
        .rst(rst),
        .start_op(start_op),
        .op_type(op_type),
        .addr_in(addr_in),
        .data_in(data_in),
        .ram_data_out_in(ram_data_out),
        .done(done),
        .data_out(data_out),
        .scan_en(scan_en),
        .scan_in(scan_in),
        .scan_out(scan_out),
        .mem_ren_wen(mem_ren_wen),
        .ram_read_addr(ram_read_addr),
        .ram_write_addr(ram_write_addr),
        .ram_data_in(ram_data_in)
    );

    data_memory mem (
        .clk(clk),
        .read_addr(ram_read_addr),
        .write_addr(ram_write_addr),
        .acc(ram_data_in),
        .mem_ren_wen(mem_ren_wen),
        .mem_output(ram_data_out)
    );

endmodule