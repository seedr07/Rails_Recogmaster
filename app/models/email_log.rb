class EmailLog < ActiveRecord::Base
  belongs_to :user, foreign_key: "email"
  attr_accessible :from, :to, :subject, :body, :date
  validates :from, :to, :subject, :body, :date, presence: true
end