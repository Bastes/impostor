# Impostor

## How to play

### `!new_impostor_game`

Starts the game. You get a message like this one:

```elixir
################################
# Let's prepare your new game. #
#                              #
# Players:                     #
# @player_1_nick               #
# @player_2_nick               #
# ...                          #
#                              #
# [ Join! ]                    #
################################
```

A list of players already joined and ready and a list of pending players are
displayed, and updated whenever a player joins.

The players join clicking the `[ Join! ]`. They get this confirmation:

```elixir
# You are joining the game of impostor!
# Welcome, you will get your own word soon.
```

The player who created the game clicks the button last, whichs starts the game
round. The game then sends each player their word as a DM:

```elixir
# The game is starting, here is your word:
# (word)
# Now go and confuse your friends!
```

The main message is edited to be:

```elixir
##############################################
# Game in progress.                          #
#                                            #
# Players:                                   #
# @player_1_nick (word #1, word #2, word #3) #
# @player_2_nick (word #1, word #2, word #3) #
# ...                                        #
#                                            #
# @player_1_nick, this is your turn!         #
# Give your word with the `!word` command:   #
# `!word [your word here]`                   #
##############################################
```

### `!word [word]`

Is how players give their word. If a player is giving their word out of turn,
the word is removed automatically by the bot. If the word is given on turn, it
is removed and integrated to the game message.

Once each player has give their word 3 times, each player is invited to give
their pronostic on who the impostor is like this:

```elixir
##############################################
# Game in progress.                          #
#                                            #
# Players:                                   #
# @player_1_nick (word #1, word #2, word #3) #
# @player_2_nick (word #1, word #2, word #3) #
# ...                                        #
#                                            #
# Now point to the impostor!                 #
# [ @player_1_nick ]                         #
# [ @player_2_nick ]                         #
# ...                                        #
##############################################
```

Clicking on a player's button registers one's vote for that player as the
impostor.

Once everyone has voted, depending on the tally:

* If no majority was attained, or the majority pointed to someone who isn't the
  impostor, the impostor has won! The game's message will reflect that:

```elixir
##############################################
# Game Over.                                 #
#                                            #
# Hidden in the shadows, @player_1_nick wins #
# as the impostor.                           #
#                                            #
# Players:                                   #
# @player_1_nick (word #1, word #2, word #3) #
# @player_2_nick (word #1, word #2, word #3) #
# ...                                        #
##############################################
```

* If the majority has pointed to the impostor, the latter is in trouble! But
  they can still win. All they have to do is type the word they think was given
  to non-impostors.

```elixir
##############################################
# Impostor unmasked!                         #
#                                            #
# The impstor @player_1_nick was unmasked,   #
# but they can still try and turn the tides  #
# in their favor if they find the secret     #
# code word.                                 #
#                                            #
# Do so with the `!word [word]` command,     #
# @player_1_nick, earn your happy ending!    #
#                                            #
# Players:                                   #
# @player_1_nick (word #1, word #2, word #3) #
# @player_2_nick (word #1, word #2, word #3) #
# ...                                        #
##############################################
```

They can then try and type the `!word [word]` command to give the word they
believe was the code word. The message is then removed and depending on the
word, they get a different game over screen.

* If the impostor was discovered but gave the right word, they get their happy
  ending after all:

```elixir
##############################################
# Game Over.                                 #
#                                            #
# The impstor @player_1_nick was unmasked,   #
# but their wits turned the tides in their   #
# favor.                                     #
#                                            #
# Yes @player_1_nick, the code word was:     #
# (word)                                     #
#                                            #
# Players:                                   #
# @player_1_nick (word #1, word #2, word #3) #
# @player_2_nick (word #1, word #2, word #3) #
# ...                                        #
##############################################
```

* If the impostor was discovered and gave the wrong word, then the team wins
instead:

```elixir
##############################################
# Game Over.                                 #
#                                            #
# The impstor @player_1_nick was unmasked,   #
# and they missed the code word.             #
#                                            #
# @player_1_nick's guess: (word)             #
# Actual code word: (word)                   #
#                                            #
# Players:                                   #
# @player_1_nick (word #1, word #2, word #3) #
# @player_2_nick (word #1, word #2, word #3) #
# ...                                        #
##############################################
```

## Installation

/!\ FIXME: write installation process down

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/impostor>.

