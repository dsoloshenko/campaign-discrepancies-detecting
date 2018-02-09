require 'net/http'
require 'uri'

# Service for detecting discrepancies between adds and job campaign database records
# It should return for example :
=begin
[
  {:message=>"Deleted in db, exists in adds", :adds=>[{"reference"=>"3", "status"=>"enabled", "description"=>"Description for campaign 13"}]}
  {:message=>"Paused in db, not disabled in adds", :adds=>[]}
  {:message=>"Actve in db, not enabled in adds", :adds=>[]}
]
=end

class DetectCampaignDiscrepanciesService

  # Url for gettings adds
  ADS_URL = "http://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df"

  def initialize
    # TODO: maybe use it as job campaign scopes, need to think
    @campaigns = JobCampaign.all
    @deleted_campaigns = @campaigns.select{ |campaign| campaign.status == "deleted" }
    @paused_campaigns = @campaigns.select{ |campaign| campaign.status == "paused" }
    @active_campaigns = @campaigns.select{ |campaign| campaign.status == "active" }
  end

  def perform
    get_ads
    detect_campaign_discrepancies
  end

  private

=begin
   Getting adds Response example
  Example:
    {
      "ads":
    [
      {
        "reference": "1",
    "status": "enabled",
    "description": "Description for campaign 11"
  },
    {
      "reference": "2",
    "status": "disabled",
    "description": "Description for campaign 12"
  },
    {
      "reference": "3",
    "status": "enabled",
    "description": "Description for campaign 13"
  }
  ]
  }
=end

  def get_ads
    url = URI.parse(ADS_URL)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    @ads_list = JSON.parse(res.body)['ads']
  end

  # We return an array
  def detect_campaign_discrepancies
    campaign_discrepancies = []
    # Getting an array of references ids
    server_all_ads =  @ads_list.each_with_object({}) { |v,h| h[v["reference"].to_i] = v }

    # This can be a bit dirty and can be dried
    unless @deleted_campaigns.blank?
      # We get an array of referencies of the recods that exists in ads but also exists in db but have status deleted
      # We suppose that deleted records should not exist in ads
     deleted_campaign_discrepancies_keys = @deleted_campaigns.pluck(:external_reference)&server_all_ads.keys
     deleted_campaign_discrepancies = server_all_ads.select {|key, value| deleted_campaign_discrepancies_keys.include?(key) }
     campaign_discrepancies << {message: "Deleted in db, exists in adds", adds: deleted_campaign_discrepancies.values} if deleted_campaign_discrepancies.length > 0
    end

    unless @paused_campaigns.blank?
      paused_campaigns_keys = @paused_campaigns.pluck(:external_reference)&server_all_ads.keys
      paused_campaign_discrepancies = server_all_ads.select {|key, value| paused_campaigns_keys.include?(key) }.values.select{ |campaign| campaign["status"] != "disabled" }
      campaign_discrepancies << {message: "Paused in db, not disabled in adds", adds: paused_campaign_discrepancies} if deleted_campaign_discrepancies.length > 0
    end

    unless @active_campaigns.blank?
      active_campaigns_keys = @active_campaigns.pluck(:external_reference)&server_all_ads.keys
      active_campaign_discrepancies = server_all_ads.select {|key, value| active_campaigns_keys.include?(key) }.values.select{ |campaign| campaign["status"] != "enabled" }
      campaign_discrepancies << {message: "Actve in db, not enabled in adds", adds: active_campaign_discrepancies} if deleted_campaign_discrepancies.length > 0
    end

    campaign_discrepancies
  end

end