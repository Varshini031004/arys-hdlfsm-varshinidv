module fault_fsm_moore (
    input  logic clk,
    input  logic reset,
    input  logic [15:0] cell_voltage [4],
    input  logic [15:0] current,
    input  logic [7:0]  temp_flag [4],
    input  logic [3:0]  mask,
    output logic [1:0]  state,
    output logic shutdown_signal
);

 
  parameter int VOLTAGE_MIN = 3000;
  parameter int VOLTAGE_MAX = 4200;
  parameter int CURRENT_MAX = 1000;
  parameter int TEMP_MAX = 80;
  parameter int IMBALANCE_THRESHOLD = 100;
  parameter int DEBOUNCE_LIMIT = 5;

  typedef enum logic [1:0] {
    NORMAL    = 2'b00,
    WARNING   = 2'b01,
    FAULT     = 2'b10,
    SHUTDOWN  = 2'b11
  } state_t;

  state_t current_state, next_state;

  logic fault_oc, fault_ot, fault_ov, fault_uv, fault_imb;
  logic [2:0] debounce_counter;
  logic [15:0] max_voltage, min_voltage;

  always_comb begin
    max_voltage = cell_voltage[0];
    min_voltage = cell_voltage[0];
    fault_oc = 0;
    fault_ot = 0;
    fault_ov = 0;
    fault_uv = 0;

    for (int i = 0; i < 4; i++) begin
      if (!mask[i]) begin
        if (cell_voltage[i] > VOLTAGE_MAX)
          fault_ov = 1;
        if (cell_voltage[i] < VOLTAGE_MIN)
          fault_uv = 1;
        if (temp_flag[i] > TEMP_MAX)
          fault_ot = 1;
        if (cell_voltage[i] > max_voltage)
          max_voltage = cell_voltage[i];
        if (cell_voltage[i] < min_voltage)
          min_voltage = cell_voltage[i];
      end
    end

    fault_oc = (current > CURRENT_MAX);
    fault_imb = ((max_voltage - min_voltage) > IMBALANCE_THRESHOLD);
  end

  logic any_fault;
  assign any_fault = fault_oc | fault_ot | fault_ov | fault_uv | fault_imb;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= NORMAL;
      debounce_counter <= 0;
    end else begin
      current_state <= next_state;
      if (any_fault)
        debounce_counter <= debounce_counter + 1;
      else
        debounce_counter <= 0;
    end
  end

  always_comb begin
    next_state = current_state;
    shutdown_signal = 0;

    case (current_state)
      NORMAL: if (any_fault) next_state = WARNING;
      WARNING: if (debounce_counter >= DEBOUNCE_LIMIT) next_state = FAULT;
      FAULT: if (fault_oc && debounce_counter >= DEBOUNCE_LIMIT) next_state = SHUTDOWN;
      SHUTDOWN: shutdown_signal = 1;
    endcase
  end

  assign state = current_state;
endmodule

