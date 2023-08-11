defmodule Luminous.Panel.Stat do
  alias Luminous.Query
  require Decimal
  @behaviour Luminous.Panel

  @type panel_type :: :stat

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
      hook: Keyword.get(opts, :hook, nil)
    }
  end

  @impl true
  # do we have a single number?
  def transform(%Query.Result{rows: n}) when is_number(n) or Decimal.is_decimal(n) do
    [%{title: nil, value: n, unit: nil}]
  end

  # we have a map of values and the relevant attributes potentially
  def transform(%Query.Result{rows: rows, attrs: attrs}) when is_map(rows) or is_list(rows) do
    rows
    |> Enum.sort_by(fn {label, _} -> if(attr = attrs[label], do: attr.order) end)
    |> Enum.map(fn {label, value} ->
      %{
        title: if(attr = attrs[label], do: attr.title),
        value: value,
        unit: if(attr = attrs[label], do: attr.unit)
      }
    end)
  end

  # fallback
  def transform(_), do: []
end
