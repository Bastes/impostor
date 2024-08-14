defprotocol Impostor.Game.Player do
  def screen_name(player)
  def screen_name_and_words(player)
  def discord_id(player)
  def game_id(player)
  def words(player)
end
