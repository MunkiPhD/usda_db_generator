@current_directory = File.expand_path File.dirname(__File__)

foods = []
file_location = File.join(@current_directory, '/data_import/', 'ABBREV.txt')
file = File.new(file_location, "r")
split_hash = ""
food_names = generate_food_names_hash
additional_nutrients = "" # get_missing_nutrients_hash
weights = generate_weight_hash


while(line = file.gets)
	split_hash = line.split('^')

	ndb_no = remove_delimeter split_hash[0]

	unless weights[ndb_no].nil? # if it's not null, we're going to iterate over all the weights for this food item
		# weights.each do |key, value| 
		weights[ndb_no].each do |sequence, subvalue|
			# puts "Key: #{key}"

			# puts ">> GRAMS: #{weights[key][sequence].fetch :grams} SERVING_SIZE: #{weights[key][sequence].fetch :serving_size}" 
			food_name = "" 
			brand_name = ""

			begin
				food_name = food_names[ndb_no].fetch :name
				brand_name = food_names[ndb_no].fetch :brand
			rescue  
				puts "Failed when getting the name/brand name for #{ndb_no}: #{$!}"
			end

			serving_size = weights[ndb_no][sequence].fetch :serving_size
			gram_weight = weights[ndb_no][sequence].fetch :grams

			food_instance = Food.new
			food_instance.ndb_no = ndb_no
			food_instance.name = "#{food_name} (#{serving_size})"
			food_instance.brand = brand_name
			food_instance.usda = true
			food_instance.serving_size = "#{serving_size} (#{gram_weight})"

			foods << mold_food(food_instance, split_hash, ndb_no, gram_weight, additional_nutrients)

			if !food_instance.valid?
				puts "Errors for #{food_instance.name}: "
				food_instance.errors.each_full {|msg| puts " >> #{msg}"}
				puts "\n"
			end #end if
		end # end inner weights iteration
		#  end # end outer weights iteration
	end # end unless condition

end # end while`
puts "=============================="
puts "Beginning database insert..."

before_insert = Food.count
puts "Total food count before bulk insert: #{before_insert}";

# perform the actual import
Food.import foods, :validate => true, :on_duplicate_key_update => [:name]

puts "Database insert finished"
after_insert = Food.count
puts "Total food count in Database: #{after_insert}"
puts "#{after_insert - before_insert} items added successfully."

puts "\n >> Happy Eating! << \n"




# --------------------------------
# Generates a hash for all the weights specified for each ndb_no
# --------------------------------
def generate_weight_hash
	file_location = File.join(@current_directory, "/data_import/", "WEIGHT.txt")
	file = File.new(file_location, "r")
	puts "Generating Weight Hash..."
	weights = {}
	while(line = file.gets)
		vals = line.split('^')
		ndb_no = remove_delimeter vals[0]
		sequence = vals[1]
		amount = vals[2]
		description = "#{amount} #{remove_delimeter vals[3]}"
		grams = vals[4].to_f

		internal = { :grams => grams, :serving_size => description }

		if weights[ndb_no].nil?
			weights[ndb_no] = {}
		end

		weights[ndb_no].store(sequence, internal)
	end

	puts "#{weights.count} Food items with known weight measurements"
	puts "Completed weight hash generation"

	return weights # lets make it explicit so that we know
end



# ---------------------------------------
#
# This will set all the values correctly based on the gram weight
#
# ---------------------------------------
def mold_food(food, values, ndb_no, gram_weight, additional_nutrients)

	#  ndb_no = remove_delimeter values[0]
	#  item_name = "#{food_names[ndb_no].fetch :name} (#{serving_size_one})" # split_hash[1][1..-2] 
	#  serving_size = "#{serving_size_one} (#{gram_weight_one}g)"

	#  food.ndb_no = ndb_no
	# food.name = item_name
	#  food.brand = food_names[ndb_no].fetch :brand
	#  food.usda = true
	#  food.serving_size = serving_size

	food.calories = denormalize gram_weight, values[3] 
	food.total_fat = denormalize gram_weight, values[5]
	food.calories_from_fat = (denormalize gram_weight, values[5]) * 9
	food.saturated_fat = denormalize gram_weight, values[44]
	food.polyunsaturated_fat = denormalize gram_weight, values[46]
	food.monounsaturated_fat = denormalize gram_weight, values[45]
	food.cholesterol = denormalize gram_weight, values[47]
	food.sodium = denormalize gram_weight, values[15]
	food.carbs = denormalize gram_weight, values[7]
	food.dietary_fiber = denormalize gram_weight, values[8]
	food.sugars = denormalize gram_weight, values[9]
	food.protein = denormalize gram_weight, values[4]
	food.vitamin_a = denormalize gram_weight, values[32]
	food.vitamin_c = denormalize gram_weight, values[20]
	food.calcium = denormalize gram_weight, values[10]
	food.iron = denormalize gram_weight, values[11]
	food.vitamin_d = denormalize gram_weight, values[41]
	food.vitamin_e = denormalize gram_weight, values[40]
	food.vitamin_k = denormalize gram_weight, values[43]
	food.thiamin = denormalize gram_weight, values[21]
	food.riboflavin = denormalize gram_weight, values[22]
	food.niacin = denormalize gram_weight, values[23]
	food.vitamin_b6 = denormalize gram_weight, values[25]
	food.pantothenic_acid = denormalize gram_weight, values[24]
	food.phosphorus = denormalize gram_weight, values[13]
	food.magnesium = denormalize gram_weight, values[12]
	food.zinc = denormalize gram_weight, values[16]
	food.selenium = denormalize gram_weight, values[19]
	food.copper = denormalize gram_weight, values[17]
	food.manganese = denormalize gram_weight, values[18]
	# food_instance.chromium = 0,
	# food_instance.molybednum = 0, 
=begin
		food.caffeine = additional_nutrients[ndb_no].fetch :caffeine
		food.alcohol = additional_nutrients[ndb_no].fetch :alcohol
	rescue
		puts "Error when getting additional nutrients for #{ndb_no}: #{$!}"
=end
	# food_instance.biotin = 0
	# food_instance.iodine = 0 

	if food.calories_from_fat > food.calories
		food.calories = food.calories_from_fat
	end

	food
end

# ----------------------------------------
# Denormalizes the weight to the actual value for that measurement
# ----------------------------------------
def denormalize(gram_weight, value)
	if value.nil? || value == ""
		return 0
	end

	(value.to_f * gram_weight) / 100
end

# -------------------------------------------
# we're going to create a hash of the names for the NDB_IDs so that we can add it to the description
# -------------------------------------------
def generate_food_names_hash
	puts "Generating the food name hash..."
	file_location = File.join(@current_directory, '/data_import/', 'FOOD_DES.txt')
	food_names = {}
	file = File.new(file_location, "r")

	longest_string = 0

	while(line = file.gets)
		split_line = line.split('^')

		# we need to trim the ~ from the beginning and the ends of the strings
		ndb_id = remove_delimeter split_line[0]
		name = remove_delimeter split_line[2]
		brand = remove_delimeter split_line[5]

		# the ndb_id is the first value
		food_names[ndb_id] = {:name => name, :brand => brand}

		if name.size > longest_string
			longest_string = name.size
		end 
	end

	puts "Longest name length was #{longest_string}"
	puts "Completed generating the food name hash. #{food_names.count} items added"

	return food_names
end

# -------------------------------------------
# Retrieves a hash of the missing nutrients with ndb_no as the key
# -------------------------------------------
def get_missing_nutrients_hash
	# food_instance.chromium = 0,
	# food_instance.molybednum = 0, 
	# caffeine id = 262
	# food_instance.caffeine = 0,
	# alcohol id = 221
	# food_instance.alcohol = 0
	# food_instance.biotin = 0
	# food_instance.iodine = 0 
	puts "Generating missing nutrients hash..."
	file_location = File.join(@current_directory, '/data_import/', 'NUT_DATA.txt')
	additional_nutrients = {}
	file = File.new(file_location, "r")

	while(line = file.gets)
		split_line = line.split('^')
		nutrient_id = split_line[1]
		ndb_no = remove_delimeter split_line[0]

		additional_nutrients[ndb_no] = { :alcohol => 0, :caffeine => 0 } # initialize the hash inside the hash

		# if the nutrient we're looking for is alcohol, set it in the nested hash
		if nutrient_id == "221" # alcohol
			additional_nutrients[ndb_no].store :alcohol, split_line[2].to_f
		end

		# if the nutrient we're looking for is caffeine, set it in the nested hash
		if nutrient_id == "262" # caffeine
			additional_nutrients[ndb_no].store :caffeine, split_line[2].to_f
		end

	end #end while loop

	puts "Completed generating missing nutrients list."

	return additional_nutrients
end

# -------------------------------------------
# Removes the "~" character from the beginning and the end of a string
# -------------------------------------------
def remove_delimeter(str)
	str[1..-2]
end

