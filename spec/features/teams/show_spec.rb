require 'spec_helper'

#- first user in a company
# - existing teams stuff 
#  - create a new team
# - 2nd user in a company
#  - existing teams stuff 
#  - create a new team

describe "TeamsController", js: true do
  describe '#show' do
    let(:user) { FactoryGirl.create(:company_admin) }
    let(:team) { FactoryGirl.create(:team, company_id: user.company_id) }
    
    context "when logged in" do
      before(:each) do
        login_as(user)
        visit team_path(team)
      end

      context 'when viewing page' do
        it 'should show team name' do
          expect(page).to have_content(team.name)
        end

        it 'should show the company admin as manager' do
          # this is true until another manager is assigned, 
          # although company admins always have permission to edit team
        end

        context "when recognitions" do
          before do
            user.teams << team
            FactoryGirl.create(:recognition, recipient_emails: [user.email])
            visit team_path(team)
          end

          it "shows recognitions" do
            page.should have_selector("#recognitions-wrapper li")
          end
        end      

        context "when there aren't recognitions" do
          it "shows placeholder image" do
            page.should have_selector("#recognitions-wrapper .placeholder-image")
            page.should have_selector("#badges-wrapper .placeholder-image")
          end
        end
      end

      context 'when editing managers' do

        it "should open modal when clicking add" do
          page.find("#managers-wrapper .remote-overlay").click
          sleep 1
          page.should have_content("Pick people to add")
          page.should have_selector(".people-picker label")
        end

        # should open modal when clicking add
        # should see list of users
        # should be able to select one
        # should be able to save that user

        
      end

      context 'when edit members' do
        # should open modal when clicking add
        # should see list of users
        # should be able to select one
        # should be able to save that user
        
      end
    end

    context "when logged out" do
      before(:each) do
        visit teams_path(team)
      end

      it "shows login page" do
        page.should have_selector("#user_sessions-new")
      end
    end
  end
end