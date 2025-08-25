class Journal < ApplicationRecord
  belongs_to :user
  has_many :todos
  has_many :tags
end
