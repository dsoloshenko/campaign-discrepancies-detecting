class JobCampaigns < ActiveRecord::Migration[5.1]
  def change
    create_table :job_campaigns do |t|
      t.text          :ad_description
      t.integer       :external_reference
      t.string        :status, default: "paused"
      t.references    :job, index:true
      t.timestamps
    end
  end
end
