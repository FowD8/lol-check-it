class CreateSummonerSpells < ActiveRecord::Migration
  def change
    create_table :summoner_spells do |t|
      t.string :name
      t.text :description
      t.integer :summoner_level
      t.string :key

      t.timestamps null: false
    end
  end
end
