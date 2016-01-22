require 'serialport'

port_str = "/dev/ttyUSB0"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

test_string = "4,5,255,255,255!"

sp = SerialPort.new( port_str, baud_rate, data_bits, stop_bits, parity )

got_start = true
i = sp.gets.chomp
puts i

#puts "Here now"
begin
	sp.write( test_string )
ensure
	sp.close
end