# SimVision waveform window of tb_mux4_n (dut: mux4_n).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_mux4_n:$sig simulator::tb_mux4_n.$sig :$sig tb_mux4_n:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_mux4_n.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add d0 1
tbw_add d1 1
tbw_add d2 1
tbw_add d3 1
tbw_add s 1

catch {waveform add -label {Outputs}}
tbw_add y 1
