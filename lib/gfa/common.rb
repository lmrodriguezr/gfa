class GFA
   def self.assert_format(value, regex, message)
      unless value =~ regex
	 raise "#{message}: #{value}."
      end
   end
end
