class WeightParser
	def self.parse(str)
		split_str = str.split("^")
		data = {}
		data[:ndb_id] = remove_delimeter(split_str[0]).to_i
		data[:sequence] = split_str[1].to_i
		data[:serving_amount] = split_str[2].to_f
		data[:description] = remove_delimeter split_str[3]
		data[:grams] = split_str[4].to_f
		data
	end

	private
	def self.remove_delimeter(str)
		str.delete("~")
	end
end
