class MailersController < ApplicationController

  def year_in_review
    @mail = EmailBlast.yearly_blast(*year_in_review_args)
    render action: "show"
  end

  private
  def year_in_review_args
    args = [current_user]
    args << Report::Company.new(current_user.company, 1.year.ago.beginning_of_year, 1.year.ago.end_of_year, {interval: Interval.yearly})
    args << Report::Company.new(current_user.company)
    return args
  end
end