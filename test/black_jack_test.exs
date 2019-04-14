defmodule BlackJackTest do
  use ExUnit.Case
  doctest BlackJack

  # test "correct values" do
  #   IO.inspect BlackJack.create()
  # end

  test "test" do
    assert 1 == 1
  end

  test "five six" do
    assert BlackJack.evaluate_hand([{:hearts, 5}, {:hearts, 6}]) == 11
  end

  test "two aces" do
    assert BlackJack.evaluate_hand([{:hearts, 1}, {:clubs, 1}, {:diamonds, 1}]) == 21
  end

  test "5 10 7" do
    assert BlackJack.evaluate_hand([{:spades, 7}, {:clubs, :jack}, {:diamonds, 5}]) == 22
  end
end
