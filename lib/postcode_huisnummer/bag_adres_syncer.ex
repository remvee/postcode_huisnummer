defmodule PostcodeHuisnummer.BagAdresSyncer do
  use GenServer
  alias PostcodeHuisnummer.Repo

  #@bag_zip_url 'http://localhost/~me/bag.zip'
  #@bag_zip_url 'http://localhost/~me/bag-adressen-laatst.csv.zip'
  @bag_zip_url 'http://data.nlextract.nl/bag/csv/bag-adressen-laatst.csv.zip'

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    Process.send_after(self(), :tick, 1000)
    {:ok, []}
  end

  def handle_info(:tick, _) do
    result = sync()
    Process.send_after(self(), :tick, 1000 * 60 * 60 * 24)
    {:noreply, result}
  end

  def sync do
    case HttpcHelpers.last_modified(@bag_zip_url) do
      {:ok, last_modified} -> sync_if_needed(last_modified)
      _ -> []
    end
  end

  def sync_if_needed(last_modified) do
    if PostcodeHuisnummer.BagAdresSync.need_sync?(last_modified) do
      started_at = DateTime.utc_now
      fetch_and_insert_modified()
      Repo.insert(
        %PostcodeHuisnummer.BagAdresSync{
          started_at: Ecto.DateTime.cast!(started_at),
          finished_at: Ecto.DateTime.cast!(DateTime.utc_now),
          last_modified: Ecto.DateTime.cast!(last_modified)
        }
      )
    end
  end

  def fetch_and_insert_modified do
    to_bool = fn "f" -> false; "t" -> true end
    to_int = fn x -> String.to_integer(x) end
    to_float = fn x -> Float.parse(x) |> elem(0) end

    {:ok, _} = Repo.query("TRUNCATE TABLE bagadressen_tmp")

    ChunkyStreams.stream_http(@bag_zip_url)
    |> ChunkyStreams.unzip_single_file_stream
    |> ChunkyStreams.split_lines_stream
    |> Stream.transform(false, fn(line, started) ->
      if started do
        [
          openbareruimte,
          huisnummer,
          huisletter,
          huisnummertoevoeging,
          postcode,
          woonplaats,
          gemeente,
          provincie,
          object_id,
          object_type,
          nevenadres,
          x,
          y,
          lon,
          lat
        ] = String.split(line, ";")
        {
          [
            %{
              openbareruimte: openbareruimte,
              huisnummer: to_int.(huisnummer),
              huisletter: huisletter,
              huisnummertoevoeging: huisnummertoevoeging,
              postcode: postcode,
              woonplaats: woonplaats,
              gemeente: gemeente,
              provincie: provincie,
              object_id: to_int.(object_id),
              object_type: object_type,
              nevenadres: to_bool.(nevenadres),
              x: to_float.(x),
              y: to_float.(y),
              lon: to_float.(lon),
              lat: to_float.(lat)
            }
          ],
          true
        }
      else
        if line == "openbareruimte;huisnummer;huisletter;huisnummertoevoeging;postcode;woonplaats;gemeente;provincie;object_id;object_type;nevenadres;x;y;lon;lat" do
          {[], true}
        else
          raise "Malformed CSV"
        end
      end
    end)
    |> Stream.chunk(1000, 1000, [])
    |> Stream.each(fn recs ->
      Repo.insert_all("bagadressen_tmp", recs)
    end)
    |> Stream.run

    Repo.transaction(fn ->
      {:ok, _} = Repo.query("ALTER TABLE bagadressen RENAME TO bagadressen_old")
      {:ok, _} = Repo.query("TRUNCATE TABLE bagadressen_old")
      {:ok, _} = Repo.query("ALTER TABLE bagadressen_tmp RENAME TO bagadressen")
      {:ok, _} = Repo.query("ALTER TABLE bagadressen_old RENAME TO bagadressen_tmp")
    end)
  end
end
