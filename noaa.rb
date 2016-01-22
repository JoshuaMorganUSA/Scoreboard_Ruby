# This script will download weather data and output the temperature
# on 4 7-segment LED boards

VERSION = "2015-01-18/22:15"

require 'rubygems'
require 'weather-api'
require 'serialport'

port_str = "/dev/ttyUSB0"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new( port_str, baud_rate, data_bits, stop_bits, parity )
sleep(2)
initialize_msg = sp.gets.chomp

begin
	MODE = "UPSTAIRS" # or DOWNSTAIRS
	COLOR = "30,30,160!"
	UNIT_COLOR = "120,0,0!"
	
	while true
		response = Weather.lookup( 2438841, Weather::Units::FAHRENHEIT )

		temperature = response.condition.temp.to_i
		temp = temperature.to_s
		puts temperature

		temp_str = ""

		case MODE
		when "UPSTAIRS"
			if temperature < 0 && temperature > -10
				# First digit is -, second digit is number
				temp_str = "-,#{temp[1]},#{COLOR}"
			elsif temperature > 0 && temperature < 10
				# First digit is zero, second digit is ones
				temp_str = "0,#{temp[0]},#{COLOR}"
			elsif temperature > 10
				# First digit is tens, second digit is ones
				temp_str = "#{temp[0]},#{temp[1]},#{COLOR}"
			elsif temperature == 0
				# First digit is 0, second digit is off
				temp_str = "0,,#{COLOR}"
			end
		when "DOWNSTAIRS"
			temp_str = "DEGREE,F,#{UNIT_COLOR}"
		end

		puts "Writing #{temp_str}"
		sp.write( temp_str )
		sleep(120)
	end
	
ensure
	sp.close
end
