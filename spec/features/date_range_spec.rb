require 'spec_helper'

describe "DateRange", type: :feature, js: true do
  include DateRangeHelper

  let(:user) { login_as(:company_admin) }
  let(:company) { user.company }
  let(:param_scope) { nil }
  
  before do
    setup_spec if respond_to?(:setup_spec)
  end

  shared_examples_for "working date range control" do
    it "has working controls" do
      within container do 
        expect(page).to have_content "MONTH"
        expect(page).to have_content "QUARTER"
        expect(page).to have_content "YEAR"
        expect(page).to have_content "CUSTOM"
        wait_until_js(%Q(window.R.Select2), 15)
        expect(page).to have_content default_interval_label
        expect(selected_wrapper).to have_content(default_interval_label)
        wait_until_ajax_completes

        # check default values
        [Interval.monthly, Interval.quarterly, Interval.yearly].each do |interval|
          if default_interval == interval
            expect_interval_is_selected(interval, default_interval_label)
          else
            expect_interval_is_unselected(interval)
          end
        end

        expect_custom_range_to_be(nil, nil)

        # try changing values
        expect_select_to_change_to(Interval.monthly, Time.now) unless default_interval.monthly?
        expect_select_to_change_to(Interval.quarterly, Time.now) unless default_interval.quarterly?
        expect_select_to_change_to(Interval.yearly, Time.now) unless default_interval.yearly?

        expect_custom_range_to_change_to(1.week.from_now, 2.weeks.from_now)

      end
    end

  end

  describe 'CompanyAdmin' do
    before {  visit company_path(network: user.network)  }

    describe '#Recognitions' do
      let(:container) { "#recognitions" }
      let(:param_scope) { "recognitions" }

      before do
        click_on "Recognitions"
      end

      it_behaves_like "working date range control"
    end

    describe '#TopEmployees' do
      let(:container) { "#rank" }
      before do
        click_on "Top Employees"
      end
      it_behaves_like "working date range control"
    end

  end

  describe 'Stats page' do
    let(:container) { ".page-main" }
    before { visit reports_path(network: user.network) }
    it_behaves_like "working date range control"
  end


end