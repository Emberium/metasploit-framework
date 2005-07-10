require 'rex/parser/arguments'

module Msf
module Ui
module Console
module CommandDispatcher

class Nop

	@@generate_opts = Rex::Parser::Arguments.new(
		"-b" => [ true,  "The list of characters to avoid: '\\x00\\xff'" ],
		"-t" => [ true,  "The output type: ruby, perl, c, or raw."       ],
		"-c" => [ false, "Non-random sled generation."                   ])

	include Msf::Ui::Console::ModuleCommandDispatcher

	def commands
		return {
				"generate" => "Generates a NOP seld",
			}
	end

	#
	# Generates a NOP sled
	#
	def cmd_generate(args)

		# No arguments?  Tell them how to use it.
		if (args.length == 0)
			print(
				"Usage: generate [options] length\n\n" +
				"Generates a NOP sled of a given length.\n" +
				@@generate_opts.usage)
			return false
		end

		# Parse the arguments
		badchars = nil
		type     = "ruby"
		length   = 200
		random   = true

		@@generate_opts.parse(args) { |opt, idx, val|
			case opt
				when nil
					length = val.to_i	
				when '-b'
					badchars = [ val.downcase.gsub(/\\x([a-f0-9][a-f0-9])/, '\1') ].pack("H*")
				when '-t'
					type = val
				when '-c'
					random = false
			end
		}

		# Generate the sled
		begin
			sled = mod.generate_sled(
				length, 
				'Badchars' => badchars,
				'Random'   => random)
		rescue
			print_error("Sled generation failed: #{$!}.")
			return false
		end

		# Output the sled
		case type
			when "ruby"
				print(Rex::Text.to_ruby(sled))
			when "c"
				print(Rex::Text.to_c(sled, 60, "nop_sled"))
			when "perl"
				print(Rex::Text.to_perl(sled))
			when "raw"
				print(sled)
		end

		return true
	end

end

end end end end
