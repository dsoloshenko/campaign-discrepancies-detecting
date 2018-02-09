# Run service that returns an array of hashes: messages, adds - adds are the hashes that have the discrepancies with relevant records in db
# We can use system cron script, or whenever gem for making a schedule of it running
namespace :ad_server do
  desc "checking of the discrepancies between adds and apps campaigns"
  task detect_discrepances: :environment do
    DetectCampaignDiscrepanciesService.new.perform
  end
end