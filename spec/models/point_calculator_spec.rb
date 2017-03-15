require 'spec_helper'

describe Points::Calculator do
	let(:company) { FactoryGirl.create(:company) }	
  describe 'Company#reset_interval' do
    it 'has default reset interval' do
      expect(company.reset_interval).to eq(Interval::MONTHLY)
    end

    it "sets reset interval" do
      company.reset_interval = Interval::QUARTERLY
      company.save
      expect(company.reload.reset_interval).to eq(Interval::QUARTERLY)
    end
  end

  describe 'Users points' do
    let(:user) { FactoryGirl.create(:user) }
    context 'when no recognitions' do
      it 'has 0 points and interval points' do
        user.reload
        expect(user.total_points).to eq(0)
        expect(user.interval_points).to eq(0)
      end
    end

    context "when a recognition is sent" do
      let(:recognition) { FactoryGirl.create(:recognition) }
      let(:user) { @user }

      before do
        User.where.not(id: User.system_user.id).destroy_all
        @user = recognition.recipients[0].reload
      end

      it 'has User with the appropriate points' do
        expect(user.total_points).to eq(recognition.badge.points)
        expect(user.interval_points).to eq(recognition.badge.points)
      end

      context "and points are reset" do   
        before { Timecop.freeze(Time.now.beginning_of_month) }
        after { Timecop.return }

        it "has User with zero points" do          
          Points::Resetter.reset_monthly!
          user.reload
          expect(user.total_points).to eq(recognition.badge.points)
          expect(user.interval_points).to eq(0)
        end

        context "and a month has passed" do
          before do 
            Timecop.freeze(Time.now + 1.month)
          end

          after do
            Timecop.return
          end

          it "should not pull in previous recognition in point totals" do
            user.update_all_points!
            expect(user.reload.total_points).to eq(recognition.badge.points)
            expect(user.reload.interval_points).to eq(0)

          end

          context "and a new recognition is sent" do
            before do
              FactoryGirl.create(:recognition, recipients: "User:#{user.id}")
            end

            it 'has User with the appropriate points' do
              user.reload
              user.update_all_points!
              expect(user.total_points).to eq(recognition.badge.points*2) # 2x for total
              expect(user.interval_points).to eq(recognition.badge.points) # 1x for interval
            end            
          end
        end
      end
    end

  end

  describe 'Teams points' do
    let(:team) { FactoryGirl.create(:team_with_users) }

    context "when no recognitions" do
      it 'has 0 points and interval points' do
        expect(team.total_points).to eq(0)
        expect(team.interval_team_points).to eq(0)
        expect(team.interval_member_points).to eq(0)
      end
    end

    context "when a recognition is sent to team" do
      let(:recognition) { FactoryGirl.create(:recognition, recipients: "Team:#{team.id}") }

      it 'has Team with the appropriate points' do
        recognition
        team.reload
        expect(team.total_points).to eq(recognition.badge.points)
        expect(team.interval_team_points).to eq(recognition.badge.points)
        expect(team.interval_member_points).to eq(0)
      end

      context "when a recognition is sent to member of team" do
        let(:user) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{team.company.domain}")}
        let(:recognition) { FactoryGirl.create(:recognition, message: "yoyo", recipients: "User:#{user.id}") }

        before do
          team.users << user
          recognition
        end

        it "has Team with the appropriate points" do
          team.reload
          expect(team.total_points).to eq(recognition.badge.points)
          expect(team.interval_team_points).to eq(0)
          expect(team.interval_member_points).to eq(recognition.badge.points)

        end

        context "and points are reset" do
          it "has team with zero points" do
            Timecop.freeze(Time.now + 1.month)
            Points::Resetter.reset_monthly!
            team.reload
            expect(team.total_points).to eq(recognition.badge.points)
            expect(team.interval_team_points).to eq(0)
            expect(team.interval_member_points).to eq(0)
            Timecop.return
          end

          context "and a month has passed" do
            before do 
              Timecop.freeze(1.month.from_now)
            end

            after do
              Timecop.return
            end

            it "should not pull in previous recognition in point totals" do
              team.reload.update_all_points!
              expect(team.total_points).to eq(recognition.badge.points)
              expect(team.interval_team_points).to eq(0)
              expect(team.interval_member_points).to eq(0)

            end

            context "and a new recognition is sent" do
              before do
                FactoryGirl.create(:recognition, recipients: "Team:#{team.id}", message: "its been a month")
              end

              it 'has Team with the appropriate points' do
                team.update_all_points!
                expect(team.total_points).to eq(recognition.badge.points*2) # 1x for team, 1x for explicit member
                expect(team.interval_team_points).to eq(recognition.badge.points) # 1x for interval
                expect(team.interval_member_points).to eq(0)
              end            
            end
          end

        end
      end
    end
  end
end