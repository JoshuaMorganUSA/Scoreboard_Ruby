#Output snowday joy
require 'serialport'


#Determine upstairs/downstairs mode
mode = File.exist?('../UPSTAIRS') ? "UPSTAIRS" : "DOWNSTAIRS"


port_str = "/dev/ttyUSB0"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

COLOR = "0,0,255!"
PAUSE = 30

#Determine message to use
msg = (mode == "UPSTAIRS") ? "G,O," : "U,K,"





sp = SerialPort.new( port_str, baud_rate, data_bits, stop_bits, parity )

sleep(2)
i = sp.gets.chomp

begin
	while true
		com_str = msg + COLOR
		puts "Writing #{com_str}"
		sp.write( com_str )
		sleep(PAUSE)
	end
ensure
	sp.close
end
