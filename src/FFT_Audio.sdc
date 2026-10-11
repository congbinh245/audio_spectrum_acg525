// Timing Constraints file for FFT_Audio (GW5A-25A)
create_clock -name clk_50m -period 20 -waveform {0 10} [get_ports {clk}]
