module CurrentGamesHelper
  def champion_splash champion_id
    champion = @champions.find_by_id champion_id
    if champion.nil?
      image_tag "", class: "splash-image"
    else
      image_tag "http://ddragon.leagueoflegends.com/cdn/img/champion/loading/#{champion.key}_0.jpg", class: "splash-image"
    end
  end
  
  def champion_name_from_id champion_id
    champion = @champions.find_by_id champion_id
    if champion.nil?
      "Not Found"
    else
      champion.name
    end
  end
  
  def summoner_spell summoner_spell_id
    summoner_spell = @summoner_spells.find_by_id summoner_spell_id
    if summoner_spell.nil?
      image_tag "", class: "splash-image"
    else
      image_tag "http://ddragon.leagueoflegends.com/cdn/6.1.1/img/spell/#{summoner_spell.key}.png", class: "summoner-spell"
    end
  end
end
