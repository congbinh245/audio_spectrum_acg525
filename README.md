# Real-time Audio Spectrum Visualizer on Gowin ACG525 FPGA

A real-time audio spectrum analyzer and visualizer implemented on the **Gowin ACG525 FPGA** board (Gowin GW2A / LittleBee series). The system acquires analog or digital audio signals, computes the frequency spectrum using an on-chip FFT (Fast Fourier Transform) pipeline, and renders the spectrum in real time (via VGA/HDMI or LED Matrix/OLED).

---

## 📌 Features

- **Real-time Signal Processing:** Computes frequency bins via hardware FFT core with low latency.
- **Audio Acquisition:** Audio sampling via on-board ADC / external I2S Codec (WM8960 / ES8388 or line-in ADC).
- **Visualization:** 
  - Dynamic frequency bars mapped to display output (VGA / HDMI / LED matrix).
  - Peak detection and decay fall-off animation.
- **Configurable Parameters:** Adjustable gain, color modes, and frequency scale (Linear/Logarithmic).

---

## 🛠 Hardware & Toolchain

### 1. Hardware Requirements
- **FPGA Board:** Gowin ACG525 Development Kit (Gowin GW2A-LV18PG256 / GW5A series).
- **Audio Source:** 3.5mm AUX Cable / Microphone Module / I2S Audio Module.
- **Display Output:** VGA Monitor / HDMI Screen / Onboard LEDs.
- **Downloader:** Gowin Cable Programmer (USB-JTAG on-board).

### 2. Software & Toolchain
- **EDA Tool:** Gowin EDA (Gowin YunYuan Software Suite v1.9.9+).
- **HDL Language:** Verilog HDL / SystemVerilog.
- **IP Cores Used:** Gowin FFT IP Core, Gowin BSRAM, PLL / Clock Divider.

---

## 🏗 System Architecture

The pipeline consists of four main stages:
