#Output snowday joy
require 'serialport'


#Determine upstairs/downstairs mode
MODE = ""
if File.exist?('../UPSTAIRS')
	MODE = "UPSTAIRS"
elsif File.exist?('../DOWNSTAIRS')
	 MODE = "DOWNSTAIRS"
end



port_str = "/dev/ttyUSB0"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

COLOR = "0,0,255!"
PAUSE = 30

#Determine message to use
MSG = ""
if MODE == "UPSTAIRS"
	MSG = "G,O,"
elsif MODE == "DOWNSTAIRS"
	MSG = "U,K,"
end


sp = SerialPort.new( port_str, baud_rate, data_bits, stop_bits, parity )

sleep(2)
i = sp.gets.chomp

begin
	while true
		com_str = MSG + COLOR
		puts "Writing #{com_str}"
		sp.write( com_str )
		sleep(PAUSE)
	end
ensure
	sp.close
end
