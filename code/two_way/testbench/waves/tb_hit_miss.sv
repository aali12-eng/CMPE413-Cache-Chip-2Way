# SimVision waveform window of tb_hit_miss (dut: hit_miss).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_hit_miss:$sig simulator::tb_hit_miss.$sig :$sig tb_hit_miss:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_hit_miss.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add tag 1
tbw_add stored_tag 1
tbw_add valid 0

catch {waveform add -label {Outputs}}
tbw_add hit 0
tbw_add miss 0
