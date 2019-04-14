defmodule BlackJack do
  @moduledoc """
  Documentation for BlackJack.
  """
  
  @values_to_string %{
    1 => "Ace",
    2 => "Two",
    3 => "Three",
    4 => "Four",
    5 => "Five",
    6 => "Six",
    7 => "Seven",
    8 => "Eight",
    9 => "Nine",
    10 => "Ten",
    :jack => "Jack",
    :queen => "Queen",
    :king => "King"
  }

  def init do
    start_dealer()
    hit_me()
    hit_me()
    player_loop()
  end

  def player_loop do
    {_deck, _dealer, player} = Agent.get(__MODULE__, & &1)

    if evaluate_hand(player) > 21 do

      IO.puts("\nYour current hand:")
      print_hand(player)

      endgame()

    else
      
      IO.puts("\nYour current hand:")
      print_hand(player)
      
      <<action :: utf8, _ :: binary>> = String.downcase(IO.gets("Draw another card?"))
      case action do
        ?y ->
          IO.puts("yesbox!")
          hit_me()
          player_loop()
        ?n ->
          IO.puts("nobox...")
          dealer_loop()
        _ ->
          IO.puts("Excuse me?")

      end
    end
  end

  def dealer_loop do
    hit_dealer()
    
    {_deck, dealer, _player} = Agent.get(__MODULE__, & &1)

    IO.puts("\nDealers current hand:")
    print_hand(dealer)

    points = evaluate_hand(dealer)

    Process.sleep(500)

    if points < 17 do
      dealer_loop()
    else
      endgame()
    end
  end

  def endgame do
    {_deck, dealer, player} = Agent.get(__MODULE__, & &1)

    IO.puts("\nPlayer hand:")
    player
      |> Enum.reverse()
      |> Enum.map(& card_to_string(&1))
      |> Enum.join(", ")
      |> IO.puts
    IO.puts("Dealer hand:")
    dealer
      |> Enum.reverse()
      |> Enum.map(& card_to_string(&1))
      |> Enum.join(", ")
      |> IO.puts

    Agent.stop(__MODULE__)

    cond do
      evaluate_hand(player) > 21 ->
        IO.puts("You lose!")
        :lose
      evaluate_hand(dealer) > 21 ->
        IO.puts("You win!")
        :win
      evaluate_hand(player) > evaluate_hand(dealer) ->
        IO.puts("You win!")
        :win
      evaluate_hand(player) < evaluate_hand(dealer) ->
        IO.puts("You lose!")
        :lose
      evaluate_hand(player) == evaluate_hand(dealer) ->
        IO.puts("It's even!")
        :even
      true ->
        IO.puts("what")
        :error
    end
  end

  def start_dealer do
    Agent.start_link(fn -> {Enum.shuffle(create_deck()), [], []} end, name: __MODULE__)
  end

  def hit_me do
    Agent.update(__MODULE__, fn({deck, dealer, player}) ->
      case draw(deck) do
        {:ok, card, cards} ->
          IO.puts("Card drawn")
          {cards, dealer, [card | player]}
        :empty ->
          IO.puts("Deck is empty")
          {deck, dealer, player}
      end
    end)
  end

  def hit_dealer do
    Agent.update(__MODULE__, fn({deck, dealer, player}) ->
      case draw(deck) do
        {:ok, card, cards} ->
          IO.puts("Dealer drew a card")
          {cards, [card | dealer], player}
        :empty ->
          IO.puts("Deck is empty")
          {deck, dealer, player}
      end
    end)
  end

  def create_deck do
    colors = [:hearts, :spades, :diamonds, :clubs]
    values = Enum.to_list(1..10) ++ [:jack, :queen, :king]

    Enum.map(values, fn(v) -> Enum.map(colors, fn(c) -> {c, v} end) end)
      |> List.flatten
  end

  def draw([]) do
    :empty
  end
  def draw([card | cards]) do
    {:ok, card, cards}
  end

  def evaluate_hand(hand) do
    {aces, rest} = hand
      |> Enum.map(fn {_color, value} -> if is_atom(value), do: 10, else: value end)
      |> Enum.split_with(fn value -> value == 1 end)
    
    part_sum = rest
      |> Enum.reduce(0, fn k, n -> k + n end)
    
    aces
      |> Enum.reduce(part_sum, fn _, n -> if n <= 11, do: n + 10, else: n + 1 end)
  end

  def card_to_string({color, value}) do
    "#{@values_to_string[value]} of #{Atom.to_string(color)}"
  end

  def print_hand(hand) do
    hand
      |> Enum.reverse()
      |> Enum.map(& IO.puts(card_to_string(&1)))
  end
end