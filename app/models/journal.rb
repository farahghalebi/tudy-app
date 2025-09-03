class Journal < ApplicationRecord
  belongs_to :user
  has_many :todos
  has_many :tags
  has_one_attached :file

  validates :content, presence: true, unless: ->(journal) {journal.file.attached?}
  # validates :content, presence: {message: "can't be blank"}

  validate :file_size_validation

  MAX_FILE_SIZE_MB = 10

  private

  def file_size_validation
    if file.attached? && file.byte_size > MAX_FILE_SIZE_MB.megabytes
      errors.add(:file, "size must be less than #{MAX_FILE_SIZE_MB}MB")
    end
  end

end
