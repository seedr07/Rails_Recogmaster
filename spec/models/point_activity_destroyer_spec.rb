require 'spec_helper'

describe PointActivity::Destroyer do
  let(:point_values) { recognition.sender.company.point_values }
  let(:sent_recognition_value) { point_values[:sent_recognition_value] }
  let(:received_approval_value) { point_values[:received_approval_value] }
  let(:sent_approval_value) { point_values[:sent_approval_value] }
  let(:received_recognition_value) { recognition.badge.points }
  let(:recipients) { recognition.recipients(with_deleted: true) }

  describe "destroying recognition" do

    context "sanity check" do
      let(:recognition) { FactoryGirl.create(:recognition) }

      it "has proper points for sender and receiver" do
        recognition.reload
        expect(recognition.sender.total_points).to eq(sent_recognition_value)
        expect(recognition.user_recipients[0].total_points).to eq(received_recognition_value)
      end
    end

    context "when single user recipient" do
      let(:recognition) { FactoryGirl.create(:recognition) }

      it "updates sender and recipient points" do
        recognition.destroy
        expect(recognition.sender.total_points).to eq(0)
        expect(recipients[0].total_points).to eq(0)
      end

    end

    context "when single team recipient" do
      let(:team) { FactoryGirl.create(:team_with_users) }
      let(:recognition) { FactoryGirl.create(:recognition, recipients: "Team:#{team.id}") }

      it "updates sender and recipient points" do
        expect(recognition.sender.total_points).to eq(sent_recognition_value)
        expect(team.reload.total_points).to eq(received_recognition_value)

        recognition.destroy

        expect(recognition.sender.total_points).to eq(0)
        expect(team.reload.total_points).to eq(0)

      end      
    end

    context "when team and user recipient" do
      let(:team) { FactoryGirl.create(:team_with_users) }
      let(:recipient) { FactoryGirl.create(:active_user, email: "abc@#{team.network}") }
      let(:recognition) { FactoryGirl.create(:recognition, recipients: ["Team:#{team.id}", recipient]) }

      it "updates sender and recipient points" do
        expect(recognition.sender.total_points).to eq(sent_recognition_value)
        expect(team.reload.total_points).to eq(received_recognition_value)
        expect(recipient.reload.total_points).to eq(received_recognition_value)

        recognition.destroy

        expect(recognition.sender.total_points).to eq(0)
        expect(team.reload.total_points).to eq(0)
        expect(recipient.reload.total_points).to eq(0)
      end      
    end
  end

  describe "destroying recognition approval" do
    context "when single user recipient" do
      let(:recognition) { FactoryGirl.create(:recognition) }
      let(:approver) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{recognition.sender.network}") }
      let!(:recognition_approval) { recognition.approve_by(approver) }

      # sanity check
      it "has appropriate points before destruction" do
        expect(approver.reload.total_points).to eq(sent_approval_value)
        expect(recognition.recipients[0].total_points).to eq(received_recognition_value + received_approval_value)
      end

      it "updates points appropriately" do
        expect{recognition_approval.destroy}.to_not change{recognition.sender.total_points}
        expect(recognition.recipients[0].total_points).to eq(received_recognition_value)
        expect(approver.reload.total_points).to eq(0)
      end

    end

    context "when single team recipient" do
      let(:team) { FactoryGirl.create(:team_with_users) }
      let(:recognition) { FactoryGirl.create(:recognition, recipients: "Team:#{team.id}") }
      let(:approver) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{recognition.sender.network}") }
      let!(:recognition_approval) { recognition.approve_by(approver) }

      # sanity check
      it "has appropriate points before destruction" do
        expect(approver.reload.total_points).to eq(sent_approval_value)
        expect(team.reload.total_member_points).to eq(0)
        expect(team.total_team_points).to eq(received_recognition_value + received_approval_value)
        team.users.each do |user|
          expect(user.reload.total_points).to eq(received_recognition_value + received_approval_value)
        end
      end

      it "updates points appropriately" do
        expect{recognition_approval.destroy}.to_not change{recognition.sender.total_points}
        expect(team.reload.total_member_points).to eq(0)
        expect(team.total_team_points).to eq(received_recognition_value)
        team.users.each do |user|
          expect(user.reload.total_points).to eq(received_recognition_value)
        end
        expect(approver.reload.total_points).to eq(0)

      end
      
    end

    context "when team and user recipient" do
      let(:team) { FactoryGirl.create(:team_with_users) }
      let(:recipient) { FactoryGirl.create(:active_user, email: "abc@#{team.network}") }
      let(:recognition) { FactoryGirl.create(:recognition, recipients: ["Team:#{team.id}", recipient]) }
      let(:approver) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{recognition.sender.network}") }
      let!(:recognition_approval) { recognition.approve_by(approver) }

      # sanity check
      it "has appropriate points before destruction" do
        expect(approver.reload.total_points).to eq(sent_approval_value)
        expect(team.reload.total_member_points).to eq(0)
        expect(team.total_team_points).to eq(received_recognition_value + received_approval_value)
        expect(recipient.reload.total_points).to eq(received_recognition_value + received_approval_value)
        team.users.each do |user|
          expect(user.reload.total_points).to eq(received_recognition_value + received_approval_value)
        end
      end

      it "updates points appropriately" do
        expect{recognition_approval.destroy}.to_not change{recognition.sender.total_points}
        expect(team.reload.total_member_points).to eq(0)
        expect(team.total_team_points).to eq(received_recognition_value)
        team.users.each do |user|
          expect(user.reload.total_points).to eq(received_recognition_value)
        end
        expect(approver.reload.total_points).to eq(0)

      end

     
    end

    context "when recipient is on team and team and recipient are recognized" do
      let(:team) { FactoryGirl.create(:team_with_users) }
      let(:recipient) { FactoryGirl.create(:active_user, email: "abc@#{team.network}") }
      let(:recognition) { FactoryGirl.create(:recognition, recipients: ["Team:#{team.id}", recipient]) }
      let(:approver) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:count)}@#{recognition.sender.network}") }

      before do
        team.users << recipient
        @approval = recognition.approve_by(approver)
      end

      # sanity check
      it "has appropriate points before destruction" do
        expect(approver.reload.total_points).to eq(sent_approval_value)
        expect(team.reload.total_member_points).to eq(received_recognition_value + received_approval_value)
        expect(team.total_team_points).to eq(received_recognition_value + received_approval_value)
        expect(recipient.reload.total_points).to eq(2*(received_recognition_value + received_approval_value)) # double points!
        team.users.each do |user|
          if user != recipient
            expect(user.reload.total_points).to eq(received_recognition_value + received_approval_value)
          end
        end
      end

      it "updates points appropriately" do
        expect{@approval.destroy}.to_not change{recognition.sender.total_points}
        expect(team.reload.total_member_points).to eq(received_recognition_value)
        expect(team.total_team_points).to eq(received_recognition_value)
        expect(recipient.reload.total_points).to eq(2*(received_recognition_value)) 
        team.users.each do |user|
          if user != recipient
            expect(user.reload.total_points).to eq(received_recognition_value)
          end
        end
        expect(approver.reload.total_points).to eq(0)

      end      
    end

  end

end
