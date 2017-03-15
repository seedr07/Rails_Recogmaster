require 'spec_helper'

describe YearsOfService do 
	let!(:company) { FactoryGirl.create(:company) }
	#let!(:team){FactoryGirl.create(:team)}
	let!(:user_with_anniversary) { 
		FactoryGirl.create(:active_user, 
			email: "a#{FactoryGirl.generate(:count)}@#{company.domain}",
			start_date: DateTime.now - 1.year)}
	let!(:user_without_anniversary) { FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{company.domain}")}

	before do
	  company.reload # ensure that company has the users we've created
	end
	describe 'getting todays anniversaries' do

		context 'when a users anniversary matches today' do
			
			it 'finds user' do
				# YearsOfService.new.get_anniversaries.should include(user_with_anniversary)
				# YearsOfService.new.get_anniversaries.should_not include(user_with_anniversary)
				expect(YearsOfService.new.get_todays_anniversaries(company)).to include(user_with_anniversary)
				
			end

			context 'even if the actual anniversary was the past weekend' do
				before do
					Timecop.freeze(Date.parse('11-05-2015'))
					user_with_anniversary.start_date = DateTime.now - 1.day - 1.year
					user_with_anniversary.save
				end

				it 'finds the user' do
					expect(YearsOfService.new.get_todays_anniversaries(company)).to include(user_with_anniversary)
				end

				after do
					Timecop.return
					user_with_anniversary.start_date = DateTime.now - 1.year
					user_with_anniversary.save
				end
			end
		end

		context 'when a users anniversary does not match today' do
			it 'does not find user' do
				expect(YearsOfService.new.get_todays_anniversaries(company)).to_not include(user_without_anniversary)
			end

		end

		context 'when a user should get notified' do
			before do
				first_team = company.teams.first
				company.anniversary_notifieds = {:role_ids => [2, 5], :user_ids => [], :team_ids => [first_team.id]}
				user_with_anniversary.add_team!(first_team.id)
				first_team.managers << user_with_anniversary
				user_without_anniversary.roles << Role.find_by_name(:company_admin)
			end

			it 'finds email recipients' do 
				email_recipients = YearsOfService.new.get_email_recipients(company).keys
				expect(email_recipients).to include(user_with_anniversary.id)
				expect(email_recipients).to include(user_without_anniversary.id)
			end

			it 'connects email recipients to users with anniversaries' do 
				anniversaries_hash = YearsOfService.new.get_anniversaries_hash(company)
				expect(anniversaries_hash[user_without_anniversary.id]).to include(user_with_anniversary)
				expect(anniversaries_hash[user_with_anniversary.id]).to include(user_with_anniversary)
				expect(anniversaries_hash[user_without_anniversary.id]).to_not include(user_without_anniversary)
				expect(anniversaries_hash[user_with_anniversary.id]).to_not include(user_without_anniversary)
			end

			it 'sends an email' do 
				email = AnniversaryNotifier.notify_anniversaries(user_without_anniversary, [user_with_anniversary])
				expect{email.deliver}.to change{ActionMailer::Base.deliveries.length}.by(1)
			end

		end

		context 'when no users should get notified' do
			it 'finds no email recipients' do
				email_recipients = YearsOfService.new.get_email_recipients(company).keys
				expect(email_recipients).to_not include(user_with_anniversary.id)
				expect(email_recipients).to_not include(user_without_anniversary.id)
			end
		end

	end
end