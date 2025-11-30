module memory_controller_with_scan (
    input           clk,
    input           rst,
    input           start_op,
    input           op_type,
    input  [7:0]    addr_in,
    input  [7:0]    data_in,
    input  [7:0]    ram_data_out_in,
    output reg      done,
    output reg [7:0]    data_out,
    input           scan_en,
    input           scan_in,
    output wire         scan_out,
    output reg      mem_ren_wen,
    output reg [7:0]    ram_read_addr,
    output reg [7:0]    ram_write_addr,
    output reg [7:0]    ram_data_in
);

    // Using sequential binary encoding for robustness
    parameter IDLE        = 3'b000;
    parameter READ_SETUP  = 3'b001;
    parameter READ_WAIT   = 3'b010;
    parameter WRITE_SETUP = 3'b011;
    parameter WRITE_WAIT  = 3'b100;
    parameter DONE_STATE  = 3'b101; 

    reg  [2:0] current_state, next_state;
    reg  [7:0] op_addr;

    // Sequential Block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            op_addr <= 8'b0; 
        end
        else if (scan_en) begin
            // Scan Mode: Standard Right Shift (MSB in, LSB out)
            current_state <= {scan_in, current_state[2:1]};
        end
        else begin
            current_state <= next_state;
            if (current_state == IDLE && start_op) begin
                op_addr <= addr_in;
            end
        end
    end

    // Data Out Register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 8'b0;
        end
         else if (current_state == READ_WAIT) begin
            data_out <= ram_data_out_in;
        end
    end

    assign scan_out = current_state[0];

    // FSM Next State Logic
    always @(*)
    begin
        next_state = current_state;
        done = 1'b0;
        mem_ren_wen = 1'b0;
        ram_read_addr = 8'b0;
        ram_write_addr = 8'b0;
        ram_data_in = 8'b0;

        case (current_state)
            IDLE: begin
                if (start_op) begin
                    if (op_type == 1'b0) begin
                        next_state = READ_SETUP;
                    end else begin
                        next_state = WRITE_SETUP;
                    end
                end
            end
            READ_SETUP: begin
                ram_read_addr = op_addr;
                next_state = READ_WAIT;
            end
            READ_WAIT: begin
                next_state = DONE_STATE;
            end
            WRITE_SETUP: begin
                ram_write_addr = op_addr; 
                ram_data_in = data_in;
                next_state = WRITE_WAIT;
            end
            WRITE_WAIT: begin
                mem_ren_wen = 1'b1; 
                ram_write_addr = op_addr;
                ram_data_in = data_in;
                next_state = DONE_STATE;
            end
            DONE_STATE: begin
                done = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
