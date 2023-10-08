defmodule NotaktoWeb.GameLive do
  alias Notakto.Game

  use NotaktoWeb, :live_view

  def mount(_params, _session, socket) do
    socket = socket
    |> assign(:game_state, init_game_state(3))
    |> assign(:winner, :none)
    |> assign(:size, 3)

    {:ok, socket}
  end

  def handle_event("start_game", %{"size" => size}, socket) do
    size = String.to_integer(size)

    socket = socket
    |> assign(:game_state, init_game_state(size))
    |> assign(:winner, :none)
    |> assign(:size, size)

    {:noreply, socket}
  end

  def handle_event("play", %{"row" => row, "col" => col}, socket) do
    row = String.to_integer(row)
    col = String.to_integer(col)

    IO.puts("row: #{row}, col: #{col}")

    state = socket.assigns.game_state
    state = Game.nextState(state, [row, col])

    winner = Game.winner(state)
    [winner, state] = if winner == :none do
      bestPlay = MCTS.search(state, 1000)
      state = Game.nextState(state, bestPlay)
      winner = Game.winner(state)

      [winner, state]
    else
      [winner, state]
    end

    socket = if winner != :none do
      socket |> assign(:winner, winner)
    else
      socket
    end

    socket = assign(socket, :game_state, state)

    {:noreply, socket}
  end

  defp init_game_state(n) do
    Game.start(n)
  end
end
