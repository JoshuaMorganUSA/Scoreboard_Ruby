## Parses the HTML

# Generic ScoreParser Error Class
class ScoreParserError < StandardError; end

# Error thrown when regexp returns an error parsing the html
class ScoreParserUndefinedMatchError < ScoreParserError; end

# ScoreParser class to extract scores from html page
class ScoreParser

	# Constants used to parse data
	NEWLINE_DELIMITER 	 = /ncb_s_left\d+=/
	FIRST_LINE_DELIMITER = /&ncb_s_delay=/
	TEAM_NAME_REGEX 	 = /[\w\s\-'\(\)]+?/
	GAME_INFO_REGEX   	 = /^\^?(?<ranking1>\(\d+\))?\s*\^?(?<team1>#{TEAM_NAME_REGEX})\s*(?<score1>\d+)\s*\^?(?<ranking2>\(\d+\))?\s*\^?(?<team2>#{TEAM_NAME_REGEX})\s*(?<score2>\d+)\s*((?<time_left>\(((\d+:\d+\s*IN\s*(1ST|2ND|(\w*\sOT))|HALFTIME|FINAL.*)|(END\sOF\s2ND)|)\)))/
	FUTURE_GAME_REGEX    = /^\^?(?<ranking1>\(\d+\))?\s*\^?(?<team1>#{TEAM_NAME_REGEX})\s*(at)+\s*\^?(?<ranking2>\(\d+\))?\s*(?<team2>#{TEAM_NAME_REGEX})\s*((?<start_time>\(\d+:\d+\s*(AM|PM)\s*ET\)))/
	# self.parse
	# Description:
	# Parse the raw html data and return a hash of usable keys
	def self.parse( html_string )
		all_games = { :live => {}, :final => {}, :future => {} }
		# Split string into lines, where each line is a game
		raw_lines = html_string.split( NEWLINE_DELIMITER )
		raw_lines.delete_if{ |line| FIRST_LINE_DELIMITER === line }
		raw_lines.each{ |raw_line|
			# Remove %20 characters and turn into spaces
			line_with_spaces = raw_line.gsub( '%20', ' ' )
			# Remove %26 characters and turn into and (& is unneccessary)
			line_with_spaces = line_with_spaces.gsub( '%26', 'and')
			# Parse line for game information
			if( game = line_with_spaces.match( GAME_INFO_REGEX ) )
				if game[:time_left].match( /FINAL/ ).nil?
					all_games[:live][game[:team1]] = {
						:score => game[:score1],
						:ranking => game[:ranking1],
						:opponent => game[:team2]
					}
					all_games[:live][game[:team2]] = {
						:score => game[:score2],
						:ranking => game[:ranking2],
						:opponent => game[:team1]
					}
				else
					all_games[:final][game[:team1]] = {
						:score => game[:score1],
						:ranking => game[:ranking1],
						:opponent => game[:team2]
					}
					all_games[:final][game[:team2]] = {
						:score => game[:score2],
						:ranking => game[:ranking2],
						:opponent => game[:team1]
					}
				end
			# Parse line for future game information
			elsif( game = line_with_spaces.match( FUTURE_GAME_REGEX ) )
				all_games[:future][game[:team1]] = {
					:ranking => game[:ranking1],
					:start_time => game[:start_time],
					:opponent => game[:team2]
				}
				all_games[:future][game[:team2]] = {
					:ranking => game[:ranking2],
					:start_time => game[:start_time],
					:opponent => game[:team1]
				}
			else
				raise ScoreParserUndefinedMatchError, "The line: #{line_with_spaces} does not match anything", caller
			end
		}
		return all_games
		# Create regexp to parse all of the optional data
		# Use a case statement to parse first line or second line
	end
end #ScoreParser class
