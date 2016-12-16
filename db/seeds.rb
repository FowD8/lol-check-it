# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

##################
# Champion Table #
##################

champions = RiotAPI.static_champions_basic

champions[:data].each do |champ, data|
  Champion.find_or_create_by(id: data[:id]).update(data)
end

#######################
# SummonerSpell Table #
#######################

summoner_spells = RiotAPI.static_summoner_spells_basic

summoner_spells[:data].each do |spell, data|
  SummonerSpell.find_or_create_by(id: data[:id]).update(data)
end