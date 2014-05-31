describe AbbreviatedParser do
	let(:baked_beans) { "~16200~^~CAMPBELL'S BRN SUGAR&BACON FLAV BKD BNS~^69.40^123^3.85^1.92^1.75^23.08^6.2^10.00^31^1.11^^^^362^^^^^0.0^^^^^^^^^^^^0^^^^^^^^^^^^0.385^^^4^130^~.5 cup~^130^~1 serving~^0" }

	describe '.parse' do
		it 'returns the correct information baked beans' do
			r = AbbreviatedParser.parse(baked_beans)
			expect(r[:ndb_id]).to eq 16200
			expect(r[:calories]).to eq 160
			expect(r[:total_fat]).to eq 2
			expect(r[:saturated_fat]).to eq 1
			expect(r[:polyunsaturated_fat]).to eq 0
			expect(r[:monounsaturated_fat]).to eq 0
			expect(r[:cholesterol]).to eq 3
			expect(r[:sodium]).to eq 471
			expect(r[:potassium]).to eq 0
			expect(r[:total_carbs]).to eq 30
			expect(r[:dietary_fiber]).to eq 8
			expect(r[:sugars]).to eq 13
			expect(r[:protein]).to eq 5
			expect(r[:calcium]).to eq 40
			expect(r[:iron]).to eq 1

		end
	end
end
