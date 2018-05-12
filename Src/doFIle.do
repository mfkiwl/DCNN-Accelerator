vsim work.main
mem load -i {D:\Projects\DCNN-Accelerator\Src/ram.mem} /main/dma/ram/ram
add wave -r /*
force -freeze sim:/main/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/main/algo 0 0
force -freeze sim:/main/ws 1 0
force -freeze sim:/main/start 0 0
force -freeze sim:/main/stride 0 0
run
force -freeze sim:/main/start 1 0
