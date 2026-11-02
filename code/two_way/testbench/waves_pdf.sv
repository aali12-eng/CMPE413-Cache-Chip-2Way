# SimVision command script: the waveform window of cmpe413_project_desired_waveforms.pdf.
# Sourced by waves_pdf.tcl (./run_*.sh pdf). Same signals and order as the PDF, under
# "CPU Interface" and "Memory Interface" headings, buses in hex.
# Zoom like the PDF pages, at the SimVision> prompt:  page1  (read miss)   page2  (write hit / read hit / write miss)
# Every step is tried on its own, so a step this SimVision version does not support is skipped.

catch {waveform clearall}
catch {waveform set -signalnames name}

# add one chip_test signal; the path form differs between SimVision versions
proc pdf_add {sig label hex} {
    foreach path [list simulator::chip_test:$sig simulator::chip_test.$sig :$sig chip_test:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$hex} { catch {waveform format $id -radix %x} }
            catch {waveform format $id -name $label}
            return $id
        }
    }
    puts "waves_pdf.sv: could not add $sig"
    return ""
}

pdf_add clk_count CLOCK_COUNT    0
pdf_add clock     CLOCK          0
pdf_add reset     RESET          0

catch {waveform add -label {CPU Interface}}
pdf_add cpu_add    CPU_ADDRESS   1
pdf_add cpu_data   CPU_DATA      1
pdf_add cpu_rd_wrn READ_WRITE    0
pdf_add start      START         0
pdf_add busy       BUSY          0

catch {waveform add -label {Memory Interface}}
pdf_add mem_add  MEMORY_ADDRESS  1
pdf_add mem_data MEMORY_DATA     1
pdf_add mem_en   MEMORY_ENABLE   0

# PDF page 1: reset and the read miss (clocks 0-21); page 2: write hit, read hit, write miss (clocks 22-33)
proc page1 {} { waveform xview limits 0ns 225ns }
proc page2 {} { waveform xview limits 220ns 340ns }
