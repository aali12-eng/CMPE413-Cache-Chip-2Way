# SimVision waveform window of tb_decoder2to4 (dut: decoder2to4).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_decoder2to4:$sig simulator::tb_decoder2to4.$sig :$sig tb_decoder2to4:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_decoder2to4.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add a 1
tbw_add en 0

catch {waveform add -label {Outputs}}
tbw_add y 1
