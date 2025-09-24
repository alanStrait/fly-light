defmodule FlyKv.Region do
  defstruct [:code, :location, :status ]

  @type t :: %__MODULE__{
    code: binary(),
    location: binary(),
    status: binary(),
  }

  NimbleCSV.define(RegionParser, separator: ",", escape: "\"")

  @doc """
  new is primarily used for testing while data is read in from a file.
  """
  def new(%{code: code, location: location, status: status}) do
    %__MODULE__{
      code: code,
      location: location,
      status: status
    }
  end

  @data_path Application.compile_env(:fly_kv, __MODULE__)[:data_path]
  @region_data_file Path.join(File.cwd!(), @data_path)

  @doc """
  read_region_data returns a map of `Region` types keyed by `key/1`.
  """
  def read_region_data do
    @region_data_file
    |> File.stream!
    |> RegionParser.parse_stream()
    |> Stream.map(fn [_original, code, location, status] ->
      %{
        code: code, location: location, status: status
      }
    end)
    |> Enum.map(&struct(__MODULE__, &1))
    |> Enum.into(%{}, fn region ->
      {__MODULE__.key(region), region}
    end)
  end

  @doc """
  key returns `Region` code to be used as the key.
  """
  @spec key(__MODULE__.t()) :: binary()
  def key(%__MODULE__{} = region) do
    region.code
  end
end
