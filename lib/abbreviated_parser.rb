class AbbreviatedParser
	def self.parse(str)
		split_hash = str.split('^')
		data = {}
		data[:ndb_id] = split_hash[0][1..-2].to_i
		data
	end
end
