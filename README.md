# HDL Fault Detection FSM
This project implements a Finite State Machine (FSM) in SystemVerilog for battery fault detection and management. The FSM monitors battery parameters such as cell voltage, current, and temperature, and transitions across the following states: Normal, Warning, Fault and Shutdown.
Key features include debounce filtering, persistence checks, fault masking, and fault priority handling to ensure reliable operation and safety.
It also compares two FSM models-Moore and Mealy-for fault detection purposes in battery systems.
 ## Objectives
- Develop a robust FSM that transitions through NORMAL, WARNING, FAULT, and SHUTDOWN states based on fault persistence and severity.
- Implement fault detection logic for overvoltage, undervoltage, overtemperature, imbalance, and overcurrent conditions.
- Incorporate cell-level masking to selectively ignore faulty or inactive cells during fault evaluation.
- Apply debounce logic to prevent false fault escalation due to transient spikes.
- Introduce priority-based fault scoring, allowing configurable weights for each fault type and intelligent shutdown decisions.
- Compare Mealy and Moore FSM models in terms of responsiveness, output stability, and fault handling behavior.
- Simulate fault scenarios using SystemVerilog testbenches and visualize results with GTKWave.


## Tools used
- Platform: EdaPlayground
- Language: SystemVerilog
- Waveform Genarator: GTKWave


## Result
- FSM transitions correctly through all states. 
- Shutdown signal was asserted only when fault score exceeds threshold.
- Masking successfully excludes selected cells from fault checks.
- Waveforms confirm debounce behavior and fault prioritization.
- Compared both the models.

## Conclusion:
HDL-implemented fault detection FSM was designed, implemented, and successfully verified through simulation. Mealy FSM supports speedy exit-to-input response path and so immediately assert shutdown signal once critical fault like overcurrent occurs; the Moore FSM provides a stateful-mode control that only asserts shutdown upon entering the SHUTDOWN state.
The project confirms that real-time battery fault monitoring is feasible by applying a compact FSM solution and can be configured for larger packs and practical BMS integration. Future innovations may include auto-recovery mechanisms, advanced thermal modeling, and FPGA/ASIC prototyping to study timing effects on real hardware. 
