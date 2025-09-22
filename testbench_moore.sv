module tb_fault_fsm_moore;

  logic clk, reset;
  logic [15:0] cell_voltage [4];
  logic [15:0] current;
  logic [7:0]  temp_flag [4];
  logic [3:0]  mask;
  logic [1:0]  state;
  logic shutdown_signal;

  fault_fsm_moore dut (
    .clk(clk),
    .reset(reset),
    .cell_voltage(cell_voltage),
    .current(current),
    .temp_flag(temp_flag),
    .mask(mask),
    .state(state),
    .shutdown_signal(shutdown_signal)
  );
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_fault_fsm_moore);
  end

  
  function string state_name(input logic [1:0] s);
    case (s)
      2'b00: return "NORMAL";
      2'b01: return "WARNING";
      2'b10: return "FAULT";
      2'b11: return "SHUTDOWN";
      default: return "UNKNOWN";
    endcase
  endfunction

 
  task set_normal();
    for (int i = 0; i < 4; i++) begin
      cell_voltage[i] = 3700;
      temp_flag[i] = 25;
    end
    current = 500;
    mask = 4'b0000;
    $display("[%0t] Set NORMAL conditions", $time);
  endtask

  task set_transient_spike();
    cell_voltage[1] = 4500;
    $display("[%0t] Inject TRANSIENT overvoltage in cell 1", $time);
  endtask

  task set_persistent_fault();
    cell_voltage[1] = 4500;
    temp_flag[2] = 90;
    current = 1200;
    $display("[%0t] Inject PERSISTENT fault: OV, OT, OC", $time);
  endtask

  task set_imbalance_fault();
    cell_voltage[0] = 3700;
    cell_voltage[1] = 3700;
    cell_voltage[2] = 3700;
    cell_voltage[3] = 3900;
    $display("[%0t] Inject VOLTAGE IMBALANCE", $time);
  endtask

  task set_masked_fault();
    cell_voltage[1] = 4500;
    mask[1] = 1;
    $display("[%0t] Inject MASKED fault in cell 1", $time);
  endtask


  initial begin
    $display("=== Starting FSM Fault Test ===");
    $display("Time\tState\t\tShutdown");

    reset = 1;
    #10 reset = 0;

    set_normal();         #50;
    set_transient_spike();#10;
    set_normal();         #30;
    set_persistent_fault();#60;
    set_imbalance_fault();#60;
    set_normal();         set_masked_fault(); #60;

    $display("=== Test Complete ===");
    $finish;
  end
  always @(posedge clk) begin
    $display("%0t\t%s\t%b", $time, state_name(state), shutdown_signal);
  end

endmodule