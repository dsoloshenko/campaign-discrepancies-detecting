class Job < ApplicationRecord
  #Suppose that every job can has many campaigns
  has_many :job_campaigns
  validates_presence_of :title, :company

end