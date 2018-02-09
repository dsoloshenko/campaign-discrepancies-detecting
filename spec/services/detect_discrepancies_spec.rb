require 'rails_helper'

RSpec.describe DetectCampaignDiscrepanciesService do

  before(:all){
    @job = Job.create(title: "Rails Developer", company: "HeyJobs")
    @active_campaign = @job.job_campaigns.create(external_reference: 1, status: "active", ad_description: 'active campaign')
    @paused_campaign = @job.job_campaigns.create(external_reference: 2, status: "paused", ad_description: 'paused campaign')
    @deleted_campaign = @job.job_campaigns.create(external_reference: 3, status: "deleted", ad_description: 'deleted campaign')
    @campaign_discrepancies = DetectCampaignDiscrepanciesService.new
  }

  it 'creates campaign discrepances if campaigns are deleted in db but still exist in Ad Server' do
    @active_campaign.update_attribute(:status, :deleted)
    discrepance = @campaign_discrepancies.perform.first
    expect(discrepance[:message]).to eq("Deleted in db, exists in adds")
  end

end

