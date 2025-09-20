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
    :tls_config_insecure_skip_verify,
    :memory_total,
    :memory_allocated,
    :cores_total,
    :cores_allocated,
    :status
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
    tls_config_insecure_skip_verify: boolean(),
    memory_total: integer(),
    memory_allocated: integer(),
    cores_total: integer(),
    cores_allocated: integer(),
    status: binary()
  }

  NimbleCSV.define(MachineParser, separator: ",")

  @data_path Application.compile_env(:fly_kv, __MODULE__)[:data_path]
  @machine_data_file Path.join(File.cwd!(), @data_path)
  def read_machine_data do
      @machine_data_file
      |> File.stream!
      |> MachineParser.parse_stream()
      |> Stream.map(fn [region_code, address, scheme, datacenter, http_path_username, http_auth_password,
                        wait_time, token, tls_config_address, tls_config_ca_path, tls_config_ca_file,
                        tls_config_cert_file, tls_config_key_file, tls_config_insecure_skip_verify,
                        memory_total, memory_allocated, cores_total, cores_allocated, status] ->
        %{
          region_code: region_code, address: address, scheme: scheme, datacenter: datacenter,
          http_path_username: http_path_username, http_auth_password: http_auth_password,
          wait_time: String.to_integer(wait_time), token: token, tls_config_address: tls_config_address,
          tls_config_ca_path: tls_config_ca_path, tls_config_ca_file: tls_config_ca_file,
          tls_config_cert_file: tls_config_cert_file, tls_config_key_file: tls_config_key_file,
          tls_config_insecure_skip_verify: tls_config_insecure_skip_verify,
          memory_total: memory_total, memory_allocated: memory_allocated,
          cores_total: cores_total, cores_allocated: cores_allocated, status: status
        }
      end)
      |> Enum.map(&struct(__MODULE__, &1))
      |> Enum.group_by(&(&1.region_code), &(&1))
      |> Map.new(fn {region, items} ->
          {region, Map.new(items, fn item -> {key(item), item} end)}
      end)
  end

  def key(%__MODULE__{} = machine) do
    machine.region_code <> "::" <> machine.address
  end

end
