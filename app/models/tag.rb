class Tag < ApplicationRecord
  belongs_to :journal
  belongs_to :todo, optional: true
end
