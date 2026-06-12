
//TESTBENCH
module uart_tb;
    reg r_clk=0;
    reg [7:0] r_data_in=0;
    reg r_tx_start=0;
    wire w_loopback;
    wire w_tx;
    wire [7:0] w_data_out;
    wire w_active;

    uart_tx_rx UUT(
        .clk(r_clk),
        .data_in(r_data_in),
        .rx(w_loopback),
        .tx_start(r_tx_start),
        .tx(w_loopback),
        .data_out(w_data_out),
        .active(w_active)
    );
    always #10 r_clk=~r_clk;

    initial begin
        $dumpfile("uart_waves.vcd");
        $dumpvars(0,uart_tb);

        r_clk = 0;
        r_data_in = 8'h00;
        r_tx_start = 0;

        #100;
        r_data_in = 8'b10100110;
        r_tx_start = 1;
        #20;
        r_tx_start = 0;
        #100;
        wait(w_active==1);
        wait(w_active==0);
        #100;
        if(w_data_out==8'b10100110) begin
            $display("Success! Input = %b | Output = %b",r_data_in,w_data_out);
        end
        else begin
            $display("Failed!");
        end

        #20; $finish;
    end

    initial begin
        #2000000; 
        $display("ERROR: Simulation timed out! Stuck in wait loop.");
        $finish; 
    end  

endmodule
