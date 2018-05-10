vsim work.main
add wave -r /*
mem load -i {/media/sobeih/New Volume/Projects during college/DCNN-Accelerator/Src/ram.mem} /main/dma/ram/ram
force -freeze sim:/main/reset 1 0
force -freeze sim:/main/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/main/algo 0 0
force -freeze sim:/main/ws 1 0
force -freeze sim:/main/stride 0 0
run
force -freeze sim:/main/reset 0 0
force -freeze sim:/main/start 1 0