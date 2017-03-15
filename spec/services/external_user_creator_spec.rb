require 'spec_helper'

describe ExternalUserCreator do 
  describe 'creation' do
    let(:temp_user) { FactoryGirl.build(:active_user) }
    let(:network) { FactoryGirl.generate(:email).split("@")[1] }
    let(:creator) { ExternalUserCreator.new(email: temp_user.email, first_name: temp_user.first_name, last_name: temp_user.last_name, network: network) }

    shared_examples_for "existing_user_external_user_creator" do
      before do
        setup_spec if defined?(setup_spec)
        creator.create
      end

      it "should not create user and return existing user" do
        expect(creator.user).to eq(existing_user)
        expect(creator.user.errors[:email]).to_not be_present
      end
    end

    shared_examples_for "valid_external_user_creator" do

      before do
        setup_spec if defined?(setup_spec)
        creator.create
      end

      it "should create user" do
        expect(creator.user).to be_persisted, creator.user.errors.full_messages.join(", ")
        expect(creator.user.network).to eq(network)
        expect(creator.user.company.domain).to eq(network)

        # send recognition to newly created user
        sender = FactoryGirl.create(:active_user)
        recognition = nil
        expect{ recognition = sender.recognize!(creator.user, nil, nil) }.to_not raise_exception
        expect(recognition).to be_persisted
        expect(recognition.recipients).to eq([creator.user])
      end

    end

    context "when company exists for network" do
      before do
        company = Company.create!(domain: network)
      end

      it_behaves_like "valid_external_user_creator"
    end

    context "when company does not exist for network" do      
      it_behaves_like "valid_external_user_creator"
    end

    context "when same email address but different network that does exist" do
      let(:existing_user) { FactoryGirl.create(:active_user)}
      let(:network) { "abcd.io" }
      let(:temp_user) { User.new(email: existing_user.email, first_name: existing_user.first_name, last_name: existing_user.last_name)}

      it_behaves_like "valid_external_user_creator"
    end

    context "when same email address and same network" do
      let(:existing_user) { FactoryGirl.create(:active_user)}
      let(:temp_user) { User.new(email: existing_user.email, first_name: existing_user.first_name, last_name: existing_user.last_name)}
      let(:setup_spec) {
        existing_user.update_column(:network, network)
      }

      it_behaves_like "existing_user_external_user_creator"
    end

    context "when just email address and network" do
      let(:creator) { ExternalUserCreator.new(email: temp_user.email, network: network) }
      it_behaves_like "valid_external_user_creator"
    end

    context "when just email address" do
      let(:network) { temp_user.email.split("@")[1] }
      let(:creator) { ExternalUserCreator.new(email: temp_user.email) }
      it_behaves_like "valid_external_user_creator"
    end

  end
end