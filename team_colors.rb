## Parses team_colors.txt for color information to certain university teams

# Generic Error class
class TeamColorsError < StandardError; end

# Class defining the Team Colors
class TeamColors

	COLOR_FILE = "team_colors.txt"
	DEFAULT_COLORS = { "R" => 0, "G" => 0, "B" => 0 }

	# initialize
	# Description:
	# Store team colors in class variable hash
	def initialize
		text = read_file
		@colors_hash = parse_data( text )
	end # initialize
	
	private
	
	# read_file
	# Description:
	# Read the text file containing color information
	def read_file
		return File.readlines( COLOR_FILE ).map{ |line| line.chomp }
	end #read_file

	# parse_data
	# Description:
	# Split the text lines into a hash with team and rgb values
	def parse_data( text )
		# Sample line of text:
		# Kentucky:23,56,89
		# Will look like: { "Kentucky" => { "R" => 23, "G" => 56, "B" => 89 } }
		color_hash = {}
		text.each{ |line|
			team, colors = line.split( ":" )
			r,g,b = colors.split( "," )
			color_hash[team] = { "R" => r, "G" => g, "B" => b }
		}
		return color_hash
	end #parse_data
	
	public
	
	# get_colors
	# Description:
	# Return a hash of colors for a team, or default color values if team does not have a pre-defined
	# color value
	def get_colors( team )
		if @colors_hash.has_key?( team )
			return @colors_hash[team]
		else
			return DEFAULT_COLORS
		end
	end #get_colors

end