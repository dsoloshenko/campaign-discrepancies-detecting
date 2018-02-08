class JobCampaign < ApplicationRecord
  belongs_to :job
  validates_presence_of :ad_description, :status, :external_reference

end
