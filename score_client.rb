## Call espn class to download the score
## Write score out to LED strip

require_relative 'espn'
require_relative 'team_colors'
#require 'debugger'
require 'serialport'

TEAM = "Kentucky"
MODE = "TEAM"

# ScoreBoardClient
# Description:
# Download score
# Change LED strip
class ScoreBoardClient

	# initialize
	# Description:
	# Will check if website can be reached in validate method
	# Call Method to download the score
	# Call Method to change LED strip configuration
	def initialize
		validate
	end #initialize

	# validate
	# Description:
	# Check that the website can be reached
	# Check if TEAM has a game that's currently live
	# Check communication to LED strips
	def validate
		ESPN.check_bottomline_connection
		if !ESPN.is_team_live?
			if ( start_time = ESPN.is_team_scheduled? )
				raise "#{TEAM} is currently not live but will have a game at #{start_time}"
			end
			raise "#{TEAM} is not currently playing a game"
		end
	end
	
	# update_scoreboard
	# Description:
	# Get the points for each team
	# Call ruby serial to send data to Arduino
	def update_scoreboard( serial_port )
		team_score = ESPN.get_team_score
		opponent_score = ESPN.get_opponent_score
		# Have to check that score is less than 100
		unless team_score.to_i > 99 || opponent_score.to_i > 99
			# Send game data to Arduino
			if MODE == "TEAM"
				puts "Updating score for #{TEAM} to #{team_score} with color #{TEAM_COLOR.inspect}"
				com_string = "#{team_score[0]},#{team_score[1]},#{TEAM_COLOR["R"]},#{TEAM_COLOR["G"]},#{TEAM_COLOR["B"]}!"
				serial_port.write( com_string )
			elsif MODE == "OPPONENT"
				puts "Updating score for #{OPPONENT} to #{opponent_score} with color #{OPPONENT_COLOR.inspect}"
				com_string = "#{opponent_score[0]},#{opponent_score[1]},#{OPPONENT_COLOR["R"]},#{OPPONENT_COLOR["G"]},#{OPPONENT_COLOR["B"]}!"
				serial_port.write( com_string )
			end
		end
	end # update_scoreboard
end #ScoreBoardClient class

# Invoke scoreboard
scoreboard = ScoreBoardClient.new

# Invoke Team Colors
team_colors = TeamColors.new
TEAM_COLOR = team_colors.get_colors( TEAM )
OPPONENT = ESPN.get_opponent
OPPONENT_COLOR = team_colors.get_colors( OPPONENT )

# Set up constants for the serial port (via USB)
port_str = "/dev/ttyUSB0"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE
begin
	serial_port = SerialPort.new( port_str, baud_rate, data_bits, stop_bits, parity )
	while ESPN.is_team_live?
		scoreboard.update_scoreboard( serial_port )
		sleep(10)
	end
ensure
	serial_port.close
end

puts "Program has exited cleanly"
