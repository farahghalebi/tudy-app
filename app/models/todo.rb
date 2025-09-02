# app/models/todos.rb

class Todo < ApplicationRecord
  belongs_to :journal, optional: true
  belongs_to :user
  has_many :reminders, dependent: :destroy
  has_many :tags, dependent: :destroy
end
