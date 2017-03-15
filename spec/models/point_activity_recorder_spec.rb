require 'spec_helper'

describe PointActivity::Recorder do
  describe 'Creating activity records' do
    let(:recognition) { FactoryGirl.create(:recognition) }

    describe 'Creating a recognition' do

      it 'adds activity records for sender and receiver' do
        expect{ recognition }.to change{PointActivity.count}.by(2)

        sender_activity = PointActivity.where(activity_type: "recognition_sender")
        recipient_activity = PointActivity.where(activity_type: "recognition_recipient")

        expect(sender_activity.count).to eq(1)
        expect(sender_activity[0].amount).to eq(Report::User::DEFAULT_POINTS[:sent_recognition_value])
        expect(recipient_activity.count).to eq(1)
        expect(recipient_activity[0].amount).to eq(recognition.badge.points)
      end
    end

    describe 'Creating a recognition approval' do
      let(:giver) { FactoryGirl.create(:active_user) }
      it 'adds activity records for sender and receiver' do
        recognition
        expect{ RecognitionApproval.create(giver: giver, recognition: recognition) }.to change{PointActivity.count}.by(2)

        giver_activity = PointActivity.where(activity_type: "recognition_approval_giver")
        receiver_activity = PointActivity.where(activity_type: "recognition_approval_receiver")

        expect(giver_activity.count).to eq(1)
        expect(giver_activity[0].amount).to eq(Report::User::DEFAULT_POINTS[:sent_approval_value])
        expect(receiver_activity.count).to eq(1)
        expect(receiver_activity[0].amount).to eq(Report::User::DEFAULT_POINTS[:received_approval_value])
      end
    end

  end
end
