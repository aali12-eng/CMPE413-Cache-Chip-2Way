# SimVision waveform window of tb_way_select (dut: way_select).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_way_select:$sig simulator::tb_way_select.$sig :$sig tb_way_select:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_way_select.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add hit0 0
tbw_add hit1 0
tbw_add valid0 0
tbw_add valid1 0
tbw_add lru_way 0

catch {waveform add -label {Outputs}}
tbw_add hit 0
tbw_add miss 0
tbw_add hit_way 0
tbw_add victim 0
