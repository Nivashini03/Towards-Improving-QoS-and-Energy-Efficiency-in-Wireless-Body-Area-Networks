
# ======================================================================
# Define options
# ======================================================================

set val(chan)            Channel/WirelessChannel    ;# channel type
set val(prop)            Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)           Phy/WirelessPhy            ;# network interface type
set val(mac)             Mac/802_11            ;# MAC type
set val(ifq)             Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)              LL                        ;# link layer type
set val(ant)             Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)          100000000000000000             ;# max packet in ifq
set val(nn)              42               ;# number of mobilenodes
Mac/802_11 set dataRate_ 11Mb 
Mac/802_11 set basicRate_ 2Mb
set val(rp)              AODV   	     ;# routing protocol
set val(x)               1300            ;# X dimension of topography
set val(y)               1300          ;# Y dimension of topography
set val(cp)              us6
set val(sc)              us5
set val(initialenergy)   10     ;# Initial energy for nodes
set val(stop)            60 ;# time of simulation end           
set val(pr)              aodv.cc
set val(energymodel)    EnergyModel			;#Energy set up
# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

# create simulator instance


set ns            [new Simulator]
	
# setup topography object

set topo	[new Topography]

# create trace object for ns and nam

set tracefd       [open us2.tr w]	
set namtrace       [open usor2.nam w]	

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# define topology
 
$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
set god_ [create-god $val(nn)]

#
# define how node should be created
#

#global node setting


set chan0 [new $val(chan)]
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channelType $val(chan) \
                -topoInstance $topo \
                -energyModel $val(energymodel) \
	         -initialEnergy 100 \
                 -rxPower 0.5 \
		 -txPower 1.0 \
                 -idlePower 0.0 \
	         -sensePower 0.3 \
                -agentTrace ON\
                -routerTrace ON \
                -macTrace ON \
                -movementTrace OFF



#
#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 
# disable random motion
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns node]	
	$node_($i) random-motion 0		;# disable random motion
}



puts "Loading connection pattern..."
source $val(cp)

# 
# Define traffic model
#
puts "Loading scenario file..."
source $val(sc)



# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    $ns initial_node_pos $node_($i) 40

}

set enr(0) 1

for {set i 0} {$i < $val(nn)} {incr i} {

set enr($i) [expr {int(rand()*100)}]

$ns at 40 "$ns trace-annotate \" energy of $i : $enr($i)  \""

}





#~~~~~~~~~~~~~~~~ Calculation of distance~~~~~~~~~~~~~~~~~~~
proc distance { n1 n2 nd1 nd2} {

set nbr [open Neighbor a]
set x1 [expr int([$n1 set X_])]
set y1 [expr int([$n1 set Y_])]
set x2 [expr int([$n2 set X_])]
set y2 [expr int([$n2 set Y_])]
set d [expr int(sqrt(pow(($x2-$x1),2)+pow(($y2-$y1),2)))]

if {$nd2!=$nd1} {

puts $nbr "\t$nd1\t\t$nd2\t\t\t$x1\t\t$y1\t\t$d"

}
close $nbr
}


set nbr [open Neighbor w]
puts $nbr "\t\t\t\t\tNeighbor Detail"
puts $nbr "\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts $nbr "\tSource\t\tNeighbor\t\tX-Pos\t\tY-Pos\t\tDistance(d)"
puts $nbr "\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
close $nbr



global ns node_ val
set nbr [open Neighbor w]
puts $nbr "\t\t\t\t\tNeighbor Detail"
puts $nbr "\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts $nbr "\tSource\t\tNeighbor\t\tX-Pos\t\tY-Pos\t\tDistance(d)"
puts $nbr "\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
close $nbr
for {set i 0} {$i <$val(nn)} {incr i} {
for {set j 0} {$j <$val(nn)} {incr j} {
$ns at 1 "distance $node_($i) $node_($j) $i $j" 
}
}

set dist(0,0) 1

for {set i 0} {$i < $val(nn)} { incr i } {

for {set j 0} {$j < $val(nn)} { incr j } {

set x1 [expr int([$node_($i) set X_])]
set y1 [expr int([$node_($i) set Y_])]
set x2 [expr int([$node_($j) set X_])]
set y2 [expr int([$node_($j) set Y_])]
set d [expr int(sqrt(pow(($x2-$x1),2)+pow(($y2-$y1),2)))]

set dist($i,$j) $d

}

}

set sx 1015.99
set sy 675.658


for {set i 0} {$i < $val(nn)} {incr i} {

set x1 [$node_($i) set X_]
set y1 [$node_($i) set Y_]

set dx0 [expr $x1 - $sx ]
set dy0 [expr $y1 - $sy ]
set dis0 [expr { sqrt( $dx0 * $dx0 + $dy0 * $dy0 ) }]

$ns at 5 "$ns trace-annotate \"distance $dis0 \""

set disarray($i) $dis0

$ns at 5 "$ns trace-annotate \"distance array $disarray($i) \""

if {[expr $i] == $val(nn)} {
set nbr1 $disarray(0)
for {set j 0} {$j < $val(nn)} {incr j} {
if {[expr $nbr1] > $disarray($j)} {
set nbr1 $disarray($j)
set neighbor1 $j
}
}
}
}

array set rt1 {
0 3
1 12 
2 0
3 37
4 27
5 9
6 21
7 5


}

array set rt2 {
0 35
1 36  
2 4
3 1
4 12
5 37
6 27
7 13
8 8
9 6
10 38

}

array set rt3 {
0 35
1 32  
2 31
3 36
4 14
5 3
6 0
7 37
8 27
9 9
10 10
11 28
12 5
13 11

}

set fit_rt1 [expr { $enr($rt1(0)) + $enr($rt1(1)) + $enr($rt1(2)) + $enr($rt1(3)) + $enr($rt1(4)) + $enr($rt1(5)) + $enr($rt1(6)) + $enr($rt1(7))}]

set fit_rt2 [expr {$enr($rt2(0)) + $enr($rt2(1)) + $enr($rt2(2)) + $enr($rt2(3)) + $enr($rt2(4)) + $enr($rt2(5)) + $enr($rt2(6)) + $enr($rt2(7)) + $enr($rt2(8)) + $enr($rt2(9)) + $enr($rt2(10)) }]

set fit_rt3 [expr {$enr($rt3(0)) + $enr($rt3(1)) + $enr($rt3(2)) + $enr($rt3(3)) + $enr($rt3(4)) + $enr($rt3(5)) + $enr($rt3(6)) + $enr($rt3(7)) + $enr($rt3(8)) + $enr($rt3(9)) + $enr($rt3(10)) + $enr($rt3(11))  + $enr($rt3(12)) + $enr($rt3(13))}]

set fit_rt11 [expr { $fit_rt1 / 8} ]

set fit_rt22 [expr { $fit_rt2 / 11} ]

set fit_rt33 [expr { $fit_rt3 / 14} ]

array set route_fit {

0 $fit_rt11

1 $fit_rt22

2 $fit_rt33

}


set bstrt 0

set hgst $route_fit(0)

set smst $route_fit(0)

for { set i 1} { $i < 3 } { incr i } {

if { [expr $route_fit($i)] > [ expr $hgst ]} {

set hgst $route_fit($i)

} elseif {[expr $route_fit($i)] < [ expr $smst ] } {

set smst $route_fit($i)

}



if { [expr $i] == 2} {

set bstrt $hgst

}

}


if { $bstrt == $route_fit(0) } {

$ns at 40.0 "$node_(3) color blue"
$ns at 40.0 "$node_(12) color blue"
$ns at 40.0 "$node_(0) color blue"
$ns at 40.0 "$node_(37) color blue"
$ns at 40.0 "$node_(27) color blue"
$ns at 40.0 "$node_(9) color blue"
$ns at 40.0 "$node_(28) color blue"
$ns at 40.0 "$node_(15) color blue"

$ns at 40.1 "$ns trace-annotate \" Optimized route  : 3-->12-->0-->37-->27-->9-->28-->15 \""

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(25) $tcp
$ns attach-agent $node_(3) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 40 "$ftp start"
$ns at 42 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(3) $tcp
$ns attach-agent $node_(12) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 42 "$ftp start"
$ns at 43 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(12) $tcp
$ns attach-agent $node_(0) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 43 "$ftp start"
$ns at 44 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(37) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 44 "$ftp start"
$ns at 45 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(37) $tcp
$ns attach-agent $node_(27) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 45 "$ftp start"
$ns at 46 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(27) $tcp
$ns attach-agent $node_(9) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 46 "$ftp start"
$ns at 47 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(9) $tcp
$ns attach-agent $node_(28) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 47 "$ftp start"
$ns at 48 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(28) $tcp
$ns attach-agent $node_(15) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 48 "$ftp start"
$ns at 49 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(15) $tcp
$ns attach-agent $node_(16) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 49 "$ftp start"
$ns at 52 "$ftp stop"

}

if { $bstrt == $route_fit(1) } {

$ns at 40.0 "$node_(14) color blue"
$ns at 40.0 "$node_(1) color blue"
$ns at 40.0 "$node_(17) color blue"
$ns at 40.0 "$node_(12) color blue"
$ns at 40.0 "$node_(0) color blue"
$ns at 40.0 "$node_(37) color blue"
$ns at 40.0 "$node_(27) color blue"
$ns at 40.0 "$node_(9) color blue"
$ns at 40.0 "$node_(21) color blue"
$ns at 40.0 "$node_(5) color blue"
$ns at 40.0 "$node_(15) color blue"

$ns at 40.1 "$ns trace-annotate \" Optimized route  : 14-->1-->17-->12-->0-->37-->27-->9-->21-->5-->15 \""

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(14) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 40 "$ftp start"
$ns at 42 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(1) $tcp
$ns attach-agent $node_(17) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 42 "$ftp start"
$ns at 43 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(17) $tcp
$ns attach-agent $node_(12) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 43 "$ftp start"
$ns at 44 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(12) $tcp
$ns attach-agent $node_(0) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 44 "$ftp start"
$ns at 45 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(37) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 45 "$ftp start"
$ns at 46 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(37) $tcp
$ns attach-agent $node_(27) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 46 "$ftp start"
$ns at 47 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(27) $tcp
$ns attach-agent $node_(9) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 47 "$ftp start"
$ns at 48 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(9) $tcp
$ns attach-agent $node_(21) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 48 "$ftp start"
$ns at 49 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(21) $tcp
$ns attach-agent $node_(5) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 49 "$ftp start"
$ns at 50 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(5) $tcp
$ns attach-agent $node_(15) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 50 "$ftp start"
$ns at 51 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(15) $tcp
$ns attach-agent $node_(16) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 51 "$ftp start"
$ns at 53 "$ftp stop"

}

if { $bstrt == $route_fit(2) } {

$ns at 40.0 "$node_(35) color blue"
$ns at 40.0 "$node_(36) color blue"
$ns at 40.0 "$node_(30) color blue"
$ns at 40.0 "$node_(4) color blue"
$ns at 40.0 "$node_(17) color blue"
$ns at 40.0 "$node_(12) color blue"
$ns at 40.0 "$node_(0) color blue"
$ns at 40.0 "$node_(37) color blue"
$ns at 40.0 "$node_(27) color blue"
$ns at 40.0 "$node_(9) color blue"
$ns at 40.0 "$node_(21) color blue"
$ns at 40.0 "$node_(6) color blue"
$ns at 40.0 "$node_(11) color blue"
$ns at 40.0 "$node_(39) color blue"

$ns at 40.1 "$ns trace-annotate \" Optimized route  : 35-->36-->30-->4-->17-->12-->0-->37-->27-->9-->21-->6-->11-->39 \""

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(35) $tcp
$ns attach-agent $node_(36) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 40 "$ftp start"
$ns at 42 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(36) $tcp
$ns attach-agent $node_(30) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 42 "$ftp start"
$ns at 43 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(30) $tcp
$ns attach-agent $node_(4) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 43 "$ftp start"
$ns at 44 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(4) $tcp
$ns attach-agent $node_(17) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 44 "$ftp start"
$ns at 45 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(17) $tcp
$ns attach-agent $node_(12) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 45 "$ftp start"
$ns at 46 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(12) $tcp
$ns attach-agent $node_(0) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 46 "$ftp start"
$ns at 47 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(37) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 47 "$ftp start"
$ns at 48 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(37) $tcp
$ns attach-agent $node_(27) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 48 "$ftp start"
$ns at 49 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(27) $tcp
$ns attach-agent $node_(9) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 49 "$ftp start"
$ns at 50 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(9) $tcp
$ns attach-agent $node_(21) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 50 "$ftp start"
$ns at 51 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(21) $tcp
$ns attach-agent $node_(6) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 51 "$ftp start"
$ns at 52 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(6) $tcp
$ns attach-agent $node_(11) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 52 "$ftp start"
$ns at 53 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(11) $tcp
$ns attach-agent $node_(39) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 53 "$ftp start"
$ns at 54 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
set sink [new Agent/TCPSink]
$ns attach-agent $node_(39) $tcp
$ns attach-agent $node_(16) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 54 "$ftp start"
$ns at 56 "$ftp stop"

}

$ns at 40.2 "$ns trace-annotate \" Data transfered in Optimized route \""

for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}


$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"


# finish procedure

proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam usor2.nam & 

exec awk -f graph1.awk us2.tr > DE_Normal
exec awk -f graph2.awk us2.tr > DE_Existing
exec awk -f graph3.awk us2.tr > DE_Proposed

exec awk -f graph4.awk us2.tr > THR_Normal
exec awk -f graph5.awk us2.tr > THR_Existing
exec awk -f graph6.awk us2.tr > THR_Proposed

exec awk -f graph7.awk us2.tr > EC_Normal
exec awk -f graph8.awk us2.tr > EC_Existing
exec awk -f graph9.awk us2.tr > EC_Proposed

exec awk -f graph10.awk us2.tr > PDR_Normal
exec awk -f graph11.awk us2.tr > PDR_Existing
exec awk -f graph12.awk us2.tr > PDR_Proposed


exec xgraph DE_Normal DE_Existing DE_Proposed -t "End to End Delay" -x "no of users" -y "No of routes required"  &
exec xgraph THR_Normal THR_Existing THR_Proposed -t "Average Throughput" -x "no of users" -y "Throughput"  &
exec xgraph EC_Normal EC_Existing EC_Proposed -t "Energy Consumption" -x "no of users" -y "Energy"  &
exec xgraph PDR_Normal PDR_Existing PDR_Proposed -t "Packet Delivery Ratio" -x "no of users" -y "Packet exchanges"  &


}

$ns run
