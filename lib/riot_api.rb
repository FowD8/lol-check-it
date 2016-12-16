class RiotAPI
  
  ##################
  # Public Methods #
  ##################
  
  class << self
    def summoner_by_names summoner_names, region="na"
      summoner_names = summoner_names.join(",") if summoner_names.class == Array
      req_path = "/api/lol/#{region}/v1.4/summoner/by-name/#{summoner_names}"
      
      summoners = parsed_response req_path, region
      
      return check_for_errors summoners
    end
    
    def summoner_by_ids summoner_ids, region="na"
      summoner_ids = summoner_ids.join(",") if summoner_ids.class == Array
      req_path = "/api/lol/#{region}/v1.4/summoner/#{summoner_ids}"
      
      summoners = parsed_response req_path, region
      
      return check_for_errors summoners
    end
    
    def featured_games region="na"
      req_path = "/observer-mode/rest/featured"
      
      featured_games = parsed_response req_path, region
      
      return check_for_errors featured_games
    end
    
    def current_game_by_id summoner_id, region="na", platform_id="NA1"
      req_path = "/observer-mode/rest/consumer/getSpectatorGameInfo/#{platform_id}/#{summoner_id}"
      
      current_game = parsed_response req_path, region
      
      return check_for_errors current_game
    end
    
    def league_by_summoner_ids summoner_ids, region="na"
      summoner_ids = summoner_ids.join(",") if summoner_ids.class == Array
      req_path = "/api/lol/#{region}/v2.5/league/by-summoner/#{summoner_ids}"
      
      leagues = parsed_response req_path, region
      
      return check_for_errors leagues
    end
    
    def games_by_summoner_id summoner_id, region="na"
      req_path = "/api/lol/#{region}/v1.3/game/by-summoner/#{summoner_id}/recent"
      
      games = parsed_response req_path, region
      
      return check_for_errors games
    end
    
    def match_by_match_id match_id, region="na"
      req_path = "/api/lol/#{region}/v2.2/match/#{match_id}"
      
      matches = parsed_response req_path, region
      
      return check_for_errors matches
    end
    
    #######################
    # Static Data Methods #
    #######################
    
    def static_champions_basic region="na"
      req_path = "/api/lol/static-data/#{region}/v1.2/champion"
      
      champions = parsed_response req_path, region, var_params=nil, static_data=true
      
      return check_for_errors champions
    end
    
    def static_summoner_spells_basic region="na"
      req_path = "/api/lol/static-data/#{region}/v1.2/summoner-spell"
      
      summoner_spells = parsed_response req_path, region, var_params=nil, static_data=true
      
      return check_for_errors summoner_spells
    end
  end
  
  ##########################
  # Public General Methods #
  ##########################
  
  class << self
    def current_game_by_name summoner_name, region="na", platform_id="NA1"
      summoner_id = self.summoner_id_of_name summoner_name
      
      return summoner_id if ResponseError.is_error summoner_id
      
      current_game = self.current_game_by_id summoner_id, region, platform_id
      
      return check_for_errors current_game
    end
    
    def summoner_id_of_name summoner_name, region="na"
      summoner = self.summoner_by_names summoner_name
      
      return summoner if ResponseError.is_error summoner
      
      summoner_ids = self::Summoners.summoner_ids summoner
      summoner_id = summoner_ids.first
      
      return summoner_id
    end
    
    def last_match_of_summoner_name summoner_name, region="na"
      summoner_id = self.summoner_id_of_name summoner_name, region
      
      return summoner_id if ResponseError.is_error summoner_id
      
      games = self.games_by_summoner_id summoner_id
      
      return games if ResponseError.is_error games
      
      game_id = self::Games.first_game_id_of_games games
      byebug
      match = self.match_by_match_id game_id
      
      return check_for_errors match
    end
    
    #######################
    # Static Data Methods #
    #######################
    
    # def static_champion_key_by_id champion_id, region="na"
    #   champion = self.static_champion_by_id champion_id, region
      
    #   champion[:key]
    # end
    
    # def static_champion_name_by_id champion_id, region="na"
    #   champion = self.static_champion_by_id champion_id, region
      
    #   champion[:name]
    # end
  end
  
  ###################
  # Private Methods #
  ###################
  
  class << self
    private
    
    def parsed_response req_path=nil, region="na", var_params=nil, static_data=false
      key = ENV["RIOT_API_KEY"]
      api_url = "https://#{region}.api.pvp.net"
      
      query = { api_key: key }
      
      if !static_data
        ApiAccess.sleep_clear
        ApiAccess.create
      end
      
      req_response = HTTParty.get(URI.encode(api_url.to_s+req_path.to_s), query: query)
      
      return req_response.parsed_response if req_response.code == 200
      
      return ResponseError.new(req_response.code, req_response.message)
    end
    
    def check_for_errors object
      return object if ResponseError.is_error object
      
      return object.symbolize!
    end
  end
  
  ###########
  # Modules #
  ###########
  
  module FeaturedGames
    class << self
      def clean_up games
        games[:game_list].each do |game|
          game.delete(:participants)
          game.delete(:observers)
          game.delete(:banned_champions)
        end
        
        return games[:game_list]
      end
      
      def remove_arams games
        return games.delete_if { |game| game[:game_mode] == "ARAM" }
      end
    end
  end
  
  module Summoners
    class << self
      def summoner_ids summoners
        summoners.map{ |name, summoner| summoner[:id] }
      end
    end
  end
  
  module SummonerSpells
    class << self
      
    end
  end
  
  module CurrentGame
    class << self
      def summoners game
        game[:participants]
      end
      
      def summoners_of_team summoners, team
        if team == "blue"
          team_id = 100
        elsif team == "red"
          team_id = 200
        end
        
        summoners_team = []
        
        summoners.each do |summoner|
          summoners_team << summoner if summoner[:team_id] == team_id
        end
        
        return summoners_team
      end
      
      def add_rank summoners, region="na"
        summoner_ids = ids_of_summoners summoners
        
        leagues = RiotAPI.league_by_summoner_ids summoner_ids, region
        
        if ResponseError.is_error(leagues)
          return leagues if leagues.code != 404
          
          summoner_ids_with_ranking = {}
        else
          summoner_ids_with_ranking = RiotAPI::League.summoner_rankings_of_summoner_ids leagues, summoner_ids
        end
        
        
        
        summoners.each do |summoner|
          rank = summoner_ids_with_ranking[summoner[:summoner_id].to_s]
          rank = "unranked" if rank.nil?
          
          summoner[:rank] = rank
        end
        
        return summoners
      end
      
      private
      
      def ids_of_summoners summoners
        summoner_ids = []
        
        summoners.each do |summoner|
          summoner_ids << summoner[:summoner_id]
        end
        
        return summoner_ids
      end
    end
  end
  
  module League
    class << self
      def summoner_rankings_of_summoner_ids leagues, summoner_ids
        summoner_ids_with_ranking = {}
        
        leagues.each do |summoner_id, league_info|
          summoner_ids_with_ranking[summoner_id.to_s] = league_info.first[:tier]
        end
        
        return summoner_ids_with_ranking
      end
    end
  end
  
  module Games
    class << self
      def first_game_id_of_games games
        first_game_id = games[:games].first[:game_id]
        
        return first_game_id
      end
    end
  end
  
end