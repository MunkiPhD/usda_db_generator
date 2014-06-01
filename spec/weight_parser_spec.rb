require 'weight_parser'

describe WeightParser do
	describe '.parse' do
		let(:entry_one){ "~01001~^4^1^~stick~^113^^" }

		it 'returns correct info' do
			result = WeightParser.parse(entry_one)
			expect(result[:ndb_id]).to eq 1001
			expect(result[:sequence]).to eq 4
			expect(result[:serving_amount]).to eq 1.0
			expect(result[:description]).to eq "stick"
			expect(result[:grams]).to eq 113.0
		end
	end
end
