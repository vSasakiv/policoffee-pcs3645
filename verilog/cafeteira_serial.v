module cafeteira_serial (
    input clock,
    input reset,
    input rxd,
    output reg pronto,
    output reg [1:0] modo
);

wire s_finished;
wire [7:0] s_data;

parameter [1:0] pequeno = 2'b01;
parameter [1:0] grande  = 2'b10;

uart_rx receptor_serial (
    .clk      (clock),
    .reset    (reset),
    .rxd      (rxd),
    .finished (s_finished),
    .data     (s_data)
);

always @(posedge clock) begin
    if (s_finished) begin
        if      (s_data == "P") modo <= pequeno;
        else if (s_data == "G") modo <= grande;
        pronto <= 1'b1;
    end
    else if (reset) begin
        modo <= 2'b0;
        pronto <= 1'b0;
    end
    else begin
        pronto <= 1'b0;
    end
end
    
endmodule