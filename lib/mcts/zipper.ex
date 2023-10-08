defmodule MCTS.Zipper do
  alias MCTS.{Breadcrumb, Node}

  @enforce_keys [:focus]
  defstruct(focus: nil, breadcrumbs: [], metadata: %{})

  @type t :: %__MODULE__{focus: Node.t(), breadcrumbs: [Breadcrumb.t()]}

  @spec root?(__MODULE__.t()) :: boolean()
  def root?(zipper = %__MODULE__{}) do
    Enum.empty?(zipper.breadcrumbs)
  end

  @spec up(__MODULE__.t()) :: __MODULE__.t()
  def up(zipper = %__MODULE__{}) do
    if root?(zipper) do
      zipper
    else
      [last_breadcrumb | remaining_breadcrumbs] = zipper.breadcrumbs

      %{
        zipper
        | focus: %Node{
            payload: last_breadcrumb.payload,
            children: last_breadcrumb.left_nodes ++ [zipper.focus] ++ last_breadcrumb.right_nodes
          },
          breadcrumbs: remaining_breadcrumbs
      }
    end
  end

  @spec down(__MODULE__.t(), non_neg_integer()) :: __MODULE__.t()
  def down(zipper = %__MODULE__{}, index) when is_integer(index) do
    cond do
      Node.leaf?(zipper.focus) ->
        # Raise a custom exception here?
        raise "focus node has no children"

      index >= length(zipper.focus.children) ->
        raise ArgumentError,
          message: "no child node at index: #{index} (index may not be negative)"

      true ->
        {left_nodes, new_focus, right_nodes} = break(zipper.focus.children, index)

        %{
          zipper
          | focus: new_focus,
            breadcrumbs: [
              %Breadcrumb{
                payload: zipper.focus.payload,
                left_nodes: left_nodes,
                right_nodes: right_nodes
              }
              | zipper.breadcrumbs
            ]
        }
    end
  end

  @spec break([Node.t()], non_neg_integer()) :: {[Node.t()], Node.t(), [Node.t()]}
  defp break(nodes, index) do
    left_items =
      if index == 0 do
        []
      else
        Enum.slice(nodes, 0, index)
      end

    {
      left_items,
      Enum.at(nodes, index),
      Enum.slice(nodes, (index + 1)..-1)
    }
  end
end
