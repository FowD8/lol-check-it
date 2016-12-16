class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
      t.string :name
      t.string :rank
      t.integer :profile_icon_id
      t.integer :summoner_level
      t.integer :revision_date

      t.timestamps null: false
    end
    add_index :summoners, :rank
  end
end
