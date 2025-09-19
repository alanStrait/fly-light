defmodule FlyKv.Region do
  defstruct [:code, :location, :status ]

  @type t :: %__MODULE__{
    code: binary(),
    location: binary(),
    status: binary(),
  }

  NimbleCSV.define(RegionParser, separator: ",", escape: "\"")

  def new(%{code: code, location: location, status: status}) do
    %FlyKv.Region{
      code: code,
      location: location,
      status: status
    }
  end

  @region_data_file Path.join(File.cwd!(), "priv/data/fly_io_regions.csv")
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
  end

  @spec key(__MODULE__.t()) :: binary()
  def key(%__MODULE__{} = region) do
    region.code
  end
end
