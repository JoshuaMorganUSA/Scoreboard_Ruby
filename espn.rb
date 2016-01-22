## Access the http://sports.espn.go.com/mens-college-basketball/bottomline/scores site
## Contains class methods for checking web connection
## Contains method to check for existance of live basketball game
## Downloads the HTML
## ESPN API

require_relative 'espn_parser'
require 'open-uri'

URL = "http://sports.espn.go.com/mens-college-basketball/bottomline/scores"

# Generic ESPN Error
# ESPN Class errors will inherit from this
class ESPNError < StandardError; end

# This error is raised when the URL is inaccessible
class ESPNNoAccessError < ESPNError; end

# ESPN class
# AIP for retrieveing information from the bottomline score file
class ESPN
	@games = {}
		
	# self.check_bottomline_connection
	# Description:
	# Try to establish a connection
	def self.check_bottomline_connection
		begin
			URI.parse( URL ).read
		rescue OpenURI::HTTPError => e
			raise ESPNNoAccessError, "The ESPN page can not be accessed currently: #{e}", caller
		end
	end #self.check_bottomline_connection

	# self.is_team_live?
	# Description:
	# Download and parse data to see if there is a game where TEAM
	# is currently playing
	# Return true|false if there is a current game for Team
	def self.is_team_live?
		download_scores # Get updated scores data
		return @games[:live].keys.member?( TEAM )
	end #self.is_team_live?
	
	# self.is_team_scheduled?
	# Description:
	# Return true|false if TEAM has a game scheduled for later
	def self.is_team_scheduled?
		return @games[:future].keys.member?( TEAM ) ? @games[:future][TEAM][:start_time] : false
	end #self.is_team_scheduled?
	
	# self.get_team_score
	# Description:
	# Access the hash and get the live game score of TEAM
	def self.get_team_score
		return @games[:live][TEAM][:score]
	end # self.get_team_score

	# self.get_opponent
	# Description:
	# Return the name of the opponent
	def self.get_opponent
		return @games[:live][TEAM][:opponent]
	end
	
	# self.get_opponent_score
	# Description:
	# Access the hash and get the live game score of TEAM opponent
	def self.get_opponent_score
		# Find the opponent
		opponent = get_opponent
		opponent_score = @games[:live][opponent][:score]
		return opponent_score
	end # self.get_opponent_score
	
	private
	
	# self.download_scores
	# Description:
	# Download the html
	# Parse the html
	def self.download_scores
		raw_html = download_html
		@games = parse_html( raw_html )
		return @games
	end #self.download_scores

	# self.download_html
	# Description:
	# Connect to URL and return raw data
	def self.download_html
		return URI.parse( URL ).read
	end #self.download_html
	
	# self.parse_html
	# Description:
	# Call the ESPN Scoreparser class to human readable data
	def self.parse_html( raw_html )
		all_games = ScoreParser.parse( raw_html )
	end #self.parse_html
end #ESPN classThank you so much it works