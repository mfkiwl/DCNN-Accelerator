vsim work.main
mem load -i {/home/sobeih/Desktop/ram.mem} /main/dma/ram/ram
add wave -r /*
force -freeze sim:/main/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/main/algo 0 0
force -freeze sim:/main/ws 1 0
force -freeze sim:/main/start 0 0
force -freeze sim:/main/stride 0 0
force -freeze sim:/main/reset 0 0
run 100 ps
force -freeze sim:/main/reset 1 0
run 100 ps
force -freeze sim:/main/reset 0 0
force -freeze sim:/main/start 1 0
run 45000000 ps
mem save -o {/home/sobeih/Desktop/out.mem} -f {} /main/dma/ram/ram
