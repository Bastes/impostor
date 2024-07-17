import Config

config :nostrum,
  token: System.fetch_env!("DISCORD_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages,
    :message_content,
    :direct_messages
  ]
