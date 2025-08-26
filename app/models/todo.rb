class Todo < ApplicationRecord
  belongs_to :journal
  belongs_to :user
  has_many :reminders
  has_many :tags
end
