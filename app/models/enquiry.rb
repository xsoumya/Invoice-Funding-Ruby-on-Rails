class Enquiry < ApplicationRecord
  ENQUIRY_TYPES = ["Product information", "Partnership", "Support", "Something else"].freeze

  validates :first_name, :last_name, :email, :enquiry_type, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, length: { maximum: 2000 }
end
