require 'rails_helper'

RSpec.describe JobCampaign, type: :model do
  it { should belong_to (:job) }
  it { should validate_presence_of (:ad_description) }
  it { should validate_presence_of (:status) }
  it { should validate_presence_of (:external_reference) }
end