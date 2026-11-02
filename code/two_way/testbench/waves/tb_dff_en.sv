# SimVision waveform window of tb_dff_en (dut: dff_en).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_dff_en:$sig simulator::tb_dff_en.$sig :$sig tb_dff_en:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_dff_en.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Clock / reset}}
tbw_add clk 0

catch {waveform add -label {Inputs}}
tbw_add d 0
tbw_add load 0

catch {waveform add -label {Outputs}}
tbw_add q 0
