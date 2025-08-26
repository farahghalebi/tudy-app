class Tag < ApplicationRecord
  belongs_to :journal, optional: true
  belongs_to :todo, optional: true
end
