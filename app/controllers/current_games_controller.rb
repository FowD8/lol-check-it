class CurrentGamesController < ApplicationController
  def index
    if params[:search].blank?
      flash[:alert] = "Please enter a Summoner name"
      redirect_to root_path and return
    end
    
    region = params[:region] || "na"
    current_game = RiotAPI.current_game_by_name params[:search], region
    
    if ResponseError.is_error(current_game)
      if current_game.code == 404 # not found
        flash[:alert] = "Summoner was not found or not in a game"
      else
        flash[:error] = "#{current_game.code} -  #{current_game.message}"
      end
      
      redirect_to root_path and return
    end
    
    summoners = RiotAPI::CurrentGame.summoners current_game
    summoners = RiotAPI::CurrentGame.add_rank summoners
    
    @summoners_red = RiotAPI::CurrentGame.summoners_of_team summoners, "red"
    @summoners_blue = RiotAPI::CurrentGame.summoners_of_team summoners, "blue"
    @champions = Champion.all
    @summoner_spells = SummonerSpell.all
  end
end
