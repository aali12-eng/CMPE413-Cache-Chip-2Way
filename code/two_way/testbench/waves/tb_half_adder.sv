# SimVision waveform window of tb_half_adder (dut: half_adder).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_half_adder:$sig simulator::tb_half_adder.$sig :$sig tb_half_adder:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_half_adder.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add a 0
tbw_add b 0

catch {waveform add -label {Outputs}}
tbw_add sum 0
tbw_add carry 0
