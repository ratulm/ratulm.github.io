

The directory contains data for a week (5 working days). This is a
subset of the data used in the following paper:

Understanding WiFi-based Connectivity From Moving Vehicles
Ratul Mahajan, John Zahorjan, and Brian Zill
ACM/Usenix Internet Measurement Conference (IMC), October 2007


The name of the directory is the date. There are three kinds of files
in each directory.

A. Application-level traces
--------------------------- 

The workload for these traces consisted of an application broadcasting
packets periodically on each of the two interfaces. The nodes logged
all packets they sent or heard from other nodes. The filenames for
such traces are in the following format:

<node-name>.<start-time>.<interface>.bcast-bcast<k>.gz

node-name: name of the machine where this trace was collected. 
           r-1 was a van, and details on the basestations are below.

start-time: when the tracing started in the machine's local time

interface: the interface on which the trace was collected. 
           ath5211 was on channel 1 and ath6211 was on channel 11.

Traces were rotated after a million packets. The filename suffix <k>
changed upon rotation.

The format in these file is:

(S|R): 2007-01-22T06:48:18.5156250-08:00 10.198.17.102 2007-01-22T06:47:43.9687500-08:00 309 1000 1

Column 1: S is for sent packets, and R is received packets
Column 2: Timestamp when the packet was logged
Column 3: Interface IP addresses of the packet source
Column 4: Experiment Id of the packet sourcing application
          This Id was simply timestamp when the application was started
Column 5: Source-specific sequence number of the packet
Column 6: Transmission rate (in Kbps) at which the packet was sent


B. Wifi traces from a van
-------------------------

These contain all Wifi packets sent and captured by the van, including
beacons from all APs in the environment and data packets from the
application above.

The filename format is:
  <node-name>.<start-time>.<interface>.bcast-wifi<k>.gz

See above for the meaning of each component.

The format in these files is: 
 2007-01-22T06:47:45.4062500-08:00 471 2566571334 2412 0 9 1000 89 MGMT_BEACON F 00:02:6F:3E:1D:77 FF:FF:FF:FF:FF:FF 02:03:04:05:06:07 DS:00 2270 Vanlan-g2412

Column 1: Timestamp (application-level)
Column 2 and 3: Upper and lower 32 bits of the hardware timestamp
Column 4: Frequency of the logged packet
Column 5: status of this packet.
          0 means the packet was correctly received
          102 means the packet was successfully transmitted
          Ignore other status values
Column 6: RSSI
Column 7: Transmission rate of the packet (in Kbps)
Column 8: Packet size
Column 9: Retry?
Column 10: Source MAC address
Column 11: Destination MAC address
Column 12: BSSID
Column 13: DS field values; FromDS:ToDS
Column 14: Sequence number of the packet
Column 15: For beacons, the SSID
           For other packets, you can ignore everything beyond this column


C.  GPS logs from a van
-----------------------

GPS data was logged by the van at most once per second.  

The filename format is:
   <node-name>.<start-time>.COM4.gps

The format of these traces is:
  2007-01-22T06:47:57.3593750-08:00 2007-01-22T14:47:15.0000000 47.644565 N 122.13342 W 0.13 157 2.9 1 2.7

Column 1: Machine time
Column 2: UTC time
Column 3: Latitude in degrees, followed by N (for north)
Column 5: Longitude in degrees, following by W (for west)
Column 7: Speed in knots (1 knot = 1.852 Kmph)
Column 8: Direction of motion
Columns 9, 10, 11: Percent, horizontal, and vertical dilution of precision


==========================

The positions of basestations are:

our %BsCoords = (bs_1_1  => {lat => 47.6411476269696, lon => -122.125589847565},
                 bs_1_2  => {lat => 47.6406705247778, lon => -122.125589847565},
                 bs_3_1  => {lat => 47.6405584774192, lon => -122.125096321106},
                 bs_3_2  => {lat => 47.6400777553792, lon => -122.125096321106},
                 bs_4_1  => {lat => 47.6399729357003, lon => -122.125563025475},
                 bs_4_2  => {lat => 47.6394922082725, lon => -122.125563025475},
                 bs_5_1  => {lat => 47.6394054599949, lon => -122.125074863434},
                 bs_5_2  => {lat => 47.6389138837009, lon => -122.125096321106},
                 bs_5_3  => {lat => 47.6389138837009, lon => -122.125836610794},
                 bs_6_1  => {lat => 47.6388921964049, lon => -122.126222848892},
                 bs_6_2  => {lat => 47.6389066546033, lon => -122.126973867416});


The mapping from IP address to node-name:interface pair is:

our %Ip2Name = ("10.198.17.2" => "bs_1_1:5211",
                "10.198.18.2" => "bs_1_1:6211",

                "10.198.17.3" => "bs_1_2:5211",
                "10.198.18.3" => "bs_1_2:6211",

                "10.198.17.4" => "bs_3_1:5211",
                "10.198.18.4" => "bs_3_1:6211",

                "10.198.17.5" => "bs_3_2:5211",
                "10.198.18.5" => "bs_3_2:6211",

                "10.198.17.6" => "bs_4_1:5211",
                "10.198.18.6" => "bs_4_1:6211",

                "10.198.17.7" => "bs_4_2:5211",
                "10.198.18.7" => "bs_4_2:6211",

                "10.198.17.8" => "bs_5_1:5211",
                "10.198.18.8" => "bs_5_1:6211",

                "10.198.17.9" => "bs_5_2:5211",
                "10.198.18.9" => "bs_5_2:6211",

                "10.198.17.10" => "bs_5_3:5211",
                "10.198.18.10" => "bs_5_3:6211",

                "10.198.17.11" => "bs_6_1:5211",
                "10.198.18.11" => "bs_6_1:6211",

                "10.198.17.12" => "bs_6_2:5211",
                "10.198.18.12" => "bs_6_2:6211",

                "10.198.17.102" => "r_1:5211",
                "10.198.18.102" => "r_1:6211",

                "10.198.17.103" => "r_2:5211",
                "10.198.18:103" => "r_2:6211",
               );
