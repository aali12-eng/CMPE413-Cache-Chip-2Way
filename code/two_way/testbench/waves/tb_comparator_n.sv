# SimVision waveform window of tb_comparator_n (dut: comparator_n).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_comparator_n:$sig simulator::tb_comparator_n.$sig :$sig tb_comparator_n:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_comparator_n.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add a 1
tbw_add b 1

catch {waveform add -label {Outputs}}
tbw_add eq 0
