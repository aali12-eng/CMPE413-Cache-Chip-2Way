# chip_test waveforms laid out like cmpe413_project_desired_waveforms.pdf. Loaded by "./run_*.sh pdf".
# Records the PDF's signals, has SimVision draw them with waves_pdf.sv, and runs to 370 ns.
# If SimVision cannot take waves_pdf.sv, the same signals are added plainly (as in waves_course.tcl).
# Zoom like the PDF pages, at the SimVision> prompt:  page1  or  page2

probe -create -shm :clk_count :clock :reset :cpu_add :cpu_data :cpu_rd_wrn :start :busy :mem_add :mem_data :mem_en

if {[catch {simvision -input waves_pdf.sv}]} {
    puts "waves_pdf.tcl: SimVision did not take waves_pdf.sv, adding the signals plainly"
    probe -create -waveform :clk_count :clock :reset
    probe -create -waveform :cpu_add :cpu_data :cpu_rd_wrn :start :busy
    probe -create -waveform :mem_add :mem_data :mem_en
}

run 370 ns
