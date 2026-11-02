# SimVision waveform window of tb_pos_dff (dut: pos_dff).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_pos_dff:$sig simulator::tb_pos_dff.$sig :$sig tb_pos_dff:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_pos_dff.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Clock / reset}}
tbw_add clk 0

catch {waveform add -label {Inputs}}
tbw_add d 0

catch {waveform add -label {Outputs}}
tbw_add q 0
