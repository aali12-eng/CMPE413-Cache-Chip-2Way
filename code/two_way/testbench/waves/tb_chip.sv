# SimVision waveform window of tb_chip (dut: chip).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_chip:$sig simulator::tb_chip.$sig :$sig tb_chip:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_chip.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Clock / reset}}
tbw_add clk 0
tbw_add reset 0

catch {waveform add -label {Inputs}}
tbw_add cpu_add 1
tbw_add cpu_rd_wrn 0
tbw_add start 0
tbw_add mem_data 1

catch {waveform add -label {Outputs}}
tbw_add cpu_data 1
tbw_add busy 0
tbw_add mem_en 0
tbw_add mem_add 1
