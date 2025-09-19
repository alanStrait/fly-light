defmodule FlyKv.Machine do
  defstruct [
    :region_code,
    :address,
    :scheme,
    :datacenter,
    :http_path_username,
    :http_auth_password,
    :wait_time,
    :token,
    :tls_config_address,
    :tls_config_ca_path,
    :tls_config_ca_file,
    :tls_config_cert_file,
    :tls_config_key_file,
    :tls_config_insecure_skip_verify
  ]

  @type t :: %__MODULE__{
    region_code: binary(),
    address: binary(),
    scheme: binary(),
    datacenter: binary(),
    http_path_username: binary(),
    http_auth_password: binary(),
    wait_time: integer(),
    token: binary(),
    tls_config_address: binary() | nil,
    tls_config_ca_path: binary() | nil,
    tls_config_cert_file: binary() | nil,
    tls_config_key_file: binary() | nil,
    tls_config_insecure_skip_verify: boolean()
  }

  NimbleCSV.define(MachineParser, separator: ",")

  @machine_data_file Path.join(File.cwd!(), "priv/data/machine.csv")
  def read_machine_data do
    _csv_data =
      @machine_data_file
      |> File.stream!
      |> MachineParser.parse_stream()
      |> Stream.map(fn [region_code, address, scheme, datacenter, http_path_username, http_auth_password,
                        wait_time, token, tls_config_address, tls_config_ca_path, tls_config_ca_file,
                        tls_config_cert_file, tls_config_key_file, tls_config_insecure_skip_verify] ->
        %{
          region_code: region_code, address: address, scheme: scheme, datacenter: datacenter,
          http_path_username: http_path_username, http_auth_password: http_auth_password,
          wait_time: String.to_integer(wait_time), token: token, tls_config_address: tls_config_address,
          tls_config_ca_path: tls_config_ca_path, tls_config_ca_file: tls_config_ca_file,
          tls_config_cert_file: tls_config_cert_file, tls_config_key_file: tls_config_key_file,
          tls_config_insecure_skip_verify: tls_config_insecure_skip_verify
        }
      end)
      |> Enum.map(&struct(__MODULE__, &1))
      |> Enum.into([])
  end

  def key(%__MODULE__{} = machine) do
    machine.region_code <> "::" <> machine.address
  end

end
