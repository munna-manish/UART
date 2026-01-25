# 📡 Full-Duplex UART in Verilog

A synthesizable, robust **Universal Asynchronous Receiver-Transmitter (UART)** implementation designed in Verilog HDL. This project demonstrates a complete serial communication pipeline with a self-checking testbench using loopback verification.

## Output:-
<img width="1667" height="283" alt="Screenshot 2026-01-25 111030" src="https://github.com/user-attachments/assets/789186cc-0cf4-4e87-9660-722b19191826" />

## 🚀 Key Features
* **Full Duplex:** Simultaneous transmission and reception capabilities.
* **Configurable Baud Rate:** Parameterized design (Default: 9600 baud at 50MHz Clock).
* **Standard Protocol:** 1 Start Bit, 8 Data Bits, 1 Stop Bit (8N1).
* **Robust FSM:** Finite State Machine implementation for reliable data framing.
* **Status Flags:** `Active` signal to indicate busy status and prevent data corruption.
* **Verified:** Includes a self-checking testbench with a "Watchdog Timer" to detect simulation timeouts.

## 🛠️ Technical Implementation

### 1. Design Specs
* **Clock Frequency:** 50 MHz
* **Baud Rate:** 9600 bps
* **Clocks per Bit:** $50,000,000 / 9600 \approx 5208$ cycles
* **Bits per Packet:** 10 (1 Start + 8 Data + 1 Stop)

### 2. Simulation & Verification
The testbench implements a **Loopback Test**:
1.  **Input:** A parallel byte `0xA6` (10100110) is loaded into the Transmitter.
2.  **Serialization:** The TX module converts it to a serial stream on the `tx` line.
3.  **Loopback:** The `tx` line is physically connected to the `rx` line (`w_loopback`).
4.  **Reconstruction:** The RX module captures the serial bits and reconstructs the parallel byte.
5.  **Check:** The testbench compares the received byte with the sent byte.

## 💻 How to Run (using Icarus Verilog)

**Prerequisites:**
* Icarus Verilog (`iverilog`)
* GTKWave (for waveform viewing)

## 🐛 Challenges & Solutions
During development, I encountered and solved several common digital design challenges:
* **Multiple Driver Conflicts:** resolved "Red Wave" (X state) errors by ensuring registers like `tx_cnt` were not driven by multiple `always` blocks.
* **Signal Initialization:** Fixed initialization bugs by ensuring control signals (`tx_busy`, `rx_busy`) had defined reset values to prevent "X" propagation.
* **Testbench Race Conditions:** Implemented a robust "Watchdog Timer" using parallel `initial` blocks to safely handle simulation timeouts without using `fork/join`.

## 🔮 Future Improvements
* Add a Parity Bit for error checking.
* Implement a FIFO buffer for buffering data.
* Synthesize the design for an FPGA (e.g., Basys3 or DE10-Lite).
