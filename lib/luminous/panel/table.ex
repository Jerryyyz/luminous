defmodule Luminous.Panel.Table do
  alias Luminous.Query
  @behaviour Luminous.Panel

  @type panel_type :: :table

  @type t :: %__MODULE__{
          id: atom(),
          title: binary(),
          type: panel_type(),
          description: binary(),
          queries: [Query.t()],
          hook: binary()
        }

  @enforce_keys [:id, :title, :queries, :hook]
  defstruct [
    :id,
    :title,
    :type,
    :description,
    :queries,
    :hook
  ]

  @doc """
  Initialize a panel at compile time.
  """
  @impl true
  @spec define(atom(), binary(), panel_type(), [Query.t()], Keyword.t()) :: t()
  def define(id, title, type, queries, opts \\ []) do
    %__MODULE__{
      id: id,
      title: title,
      type: type,
      queries: queries,
      description: Keyword.get(opts, :description),
      hook: Keyword.get(opts, :hook, "TableHook")
    }
  end

  @impl true
  def transform(%Query.Result{rows: rows, attrs: attrs}) do
    col_defs =
      attrs
      |> Enum.sort_by(fn {_, attr} -> attr.order end)
      |> Enum.map(fn {label, attr} ->
        %{
          field: label,
          title: attr.title || label,
          hozAlign: attr.halign,
          headerHozAlign: attr.halign
        }
      end)

    rows =
      Enum.map(rows, fn row ->
        Enum.reduce(row, %{}, fn {label, value}, acc -> Map.put(acc, label, value) end)
      end)

    [%{rows: rows, columns: col_defs}]
  end
end
