module cafeteira_serial (
    input clock,
    input reset,
    input rxd,
    output reg pronto,
    output reg [7:0] dados
);

wire s_finished;
wire [7:0] s_data;

uart_rx receptor_serial (
    .clk      (clock),
    .reset    (reset),
    .rxd      (rxd),
    .finished (s_finished),
    .data     (s_data)
);

always @(posedge clock) begin
    if (s_finished) begin
        dados <= s_data;
        pronto <= 1'b1;
    end
    else if (reset) begin
        dados <= 8'b0;
        pronto <= 0'b0;
    end
    else begin
        pronto <= 1'b0;
    end
end
    
endmodule