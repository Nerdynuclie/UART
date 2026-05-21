# Micro UART

A complete UART (Universal Asynchronous Receiver Transmitter) communication system designed and verified using Verilog HDL.  
This project includes a UART Transmitter, UART Receiver, Baud Rate Generator, and a self-checking verification environment with coverage analysis.

---

## Project Overview

UART is one of the most commonly used serial communication protocols in embedded systems and digital hardware design.  
This project implements a synthesizable UART communication system capable of serial transmission and reception with protocol verification.

The design supports:
- UART serial transmission
- UART serial reception
- Baud-rate clock generation
- FSM-based transmitter and receiver
- Self-checking testbench
- Coverage-driven verification

---

## Features

- Synthesizable Verilog RTL
- Configurable baud rate
- UART Transmitter (`u_xmit`)
- UART Receiver (`u_rec`)
- Baud Generator
- FSM-based architecture
- Reset handling
- Back-to-back transmission support
- Coverage analysis using Questa SIM
- Directed and random verification tests

---

## Design Architecture

The UART system consists of three major blocks:

1. **Baud Generator**
   - Generates UART clock from system clock
   - Operates at 16x baud rate timing

2. **UART Transmitter**
   - Converts parallel input data into serial UART frames
   - Handles:
     - Start bit
     - Data bits
     - Stop bit

3. **UART Receiver**
   - Detects UART frames
   - Samples incoming serial data
   - Reconstructs parallel output data

---

## Module Description

### 1. Baud Generator

#### Inputs
| Signal | Description |
|---|---|
| `sys_clk` | System clock |
| `sys_rst_l` | Active-low reset |

#### Outputs
| Signal | Description |
|---|---|
| `uart_clk` | Generated UART clock |

---

### 2. UART Transmitter (`u_xmit`)

#### Inputs
| Signal | Description |
|---|---|
| `uart_clk` | UART baud clock |
| `sys_rst_l` | Active-low reset |
| `xmit_h` | Transmission enable |
| `xmit_data_h` | Parallel data input |

#### Outputs
| Signal | Description |
|---|---|
| `xmit_done_h` | Transmission complete |
| `xmit_active` | Transmitter busy indicator |
| `uart_xmit_data_h` | Serial transmit line |

---

### 3. UART Receiver (`u_rec`)

#### Inputs
| Signal | Description |
|---|---|
| `uart_clk` | UART sampling clock |
| `sys_rst_l` | Active-low reset |
| `uart_rec_data_h` | Serial receive line |

#### Outputs
| Signal | Description |
|---|---|
| `rec_busy` | Receiver busy |
| `rec_ready` | Receiver ready |
| `rec_data_h` | Received parallel data |

---

## FSM States

| State | Value | Description |
|---|---|---|
| `idle` | `2'd0` | Wait for start bit |
| `start_bit` | `2'd1` | Validate start bit |
| `data_bits` | `2'd2` | Receive data bits |
| `stop_bit` | `2'd3` | Validate stop bit |

---

## Functional Flow

1. Parallel data is applied to the transmitter.
2. The transmitter serializes the data.
3. UART frame is transmitted over the serial line.
4. Receiver detects the start bit.
5. Receiver samples incoming bits.
6. Received serial data is converted back to parallel format.
7. Stop bit validation completes the transaction.

---

## Verification Environment

The project uses a modular self-checking testbench architecture.

### Verification Components
- Clock Generator
- Reset Generator
- DUT Instance
- Stimulus Generator
- UART Driver
- Monitor
- Scoreboard / Self-Checking Logic
- Pass/Fail Counter
- Coverage Collection
- Waveform Dumping

---

## Test Cases Performed

The design was verified using:
- Directed Tests
- Random Tests
- Reset Tests
- Back-to-Back Transmission Tests
- Noise Tests
- Corner Case Tests

---

## Coverage Analysis

Coverage was analyzed using **Questa SIM**.

Coverage Metrics:
- Statement Coverage
- Branch Coverage
- Toggle Coverage
- FSM Coverage

High functional and structural coverage was achieved.

---

## Tools Used

| Tool | Purpose |
|---|---|
| Vivado | RTL Simulation & Synthesis |
| Questa SIM | Coverage Analysis |
| Verilog HDL | RTL Design |

---

## Simulation

### Typical Simulation Flow

```bash
vlog *.v
vsim uart_tb
run -all
