defmodule Logproto.Direction do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :FORWARD, 0
  field :BACKWARD, 1
end

defmodule Logproto.PushRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :streams, 1, repeated: true, type: Logproto.StreamAdapter, deprecated: false
end

defmodule Logproto.PushResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3
end

defmodule Logproto.QueryRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :selector, 1, type: :string
  field :limit, 2, type: :uint32
  field :start, 3, type: Google.Protobuf.Timestamp, deprecated: false
  field :end, 4, type: Google.Protobuf.Timestamp, deprecated: false
  field :direction, 5, type: Logproto.Direction, enum: true
  field :shards, 7, repeated: true, type: :string, deprecated: false
  field :deletes, 8, repeated: true, type: Logproto.Delete
end

defmodule Logproto.SampleQueryRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :selector, 1, type: :string
  field :start, 2, type: Google.Protobuf.Timestamp, deprecated: false
  field :end, 3, type: Google.Protobuf.Timestamp, deprecated: false
  field :shards, 4, repeated: true, type: :string, deprecated: false
  field :deletes, 5, repeated: true, type: Logproto.Delete
end

defmodule Logproto.Delete do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :selector, 1, type: :string
  field :start, 2, type: :int64
  field :end, 3, type: :int64
end

defmodule Logproto.QueryResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :streams, 1, repeated: true, type: Logproto.StreamAdapter, deprecated: false
  field :stats, 2, type: Stats.Ingester, deprecated: false
end

defmodule Logproto.SampleQueryResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :series, 1, repeated: true, type: Logproto.Series, deprecated: false
  field :stats, 2, type: Stats.Ingester, deprecated: false
end

defmodule Logproto.LabelRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string
  field :values, 2, type: :bool
  field :start, 3, type: Google.Protobuf.Timestamp, deprecated: false
  field :end, 4, type: Google.Protobuf.Timestamp, deprecated: false
end

defmodule Logproto.RateLimitedStream do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :labels, 1, type: :string
end

defmodule Logproto.LabelResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :values, 1, repeated: true, type: :string
end

defmodule Logproto.StreamAdapter do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :labels, 1, type: :string, deprecated: false
  field :entries, 2, repeated: true, type: Logproto.EntryAdapter, deprecated: false
  field :hash, 3, type: :uint64, deprecated: false
end

defmodule Logproto.EntryAdapter do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :timestamp, 1, type: Google.Protobuf.Timestamp, deprecated: false
  field :line, 2, type: :string, deprecated: false
end

defmodule Logproto.Sample do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :timestamp, 1, type: :int64, deprecated: false
  field :value, 2, type: :double, deprecated: false
  field :hash, 3, type: :uint64, deprecated: false
end

defmodule Logproto.LegacySample do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :value, 1, type: :double
  field :timestamp_ms, 2, type: :int64, json_name: "timestampMs"
end

defmodule Logproto.Series do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :labels, 1, type: :string, deprecated: false
  field :samples, 2, repeated: true, type: Logproto.Sample, deprecated: false
  field :streamHash, 3, type: :uint64, deprecated: false
end

defmodule Logproto.TailRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :query, 1, type: :string
  field :delayFor, 3, type: :uint32
  field :limit, 4, type: :uint32
  field :start, 5, type: Google.Protobuf.Timestamp, deprecated: false
end

defmodule Logproto.TailResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :stream, 1, type: Logproto.StreamAdapter, deprecated: false
  field :droppedStreams, 2, repeated: true, type: Logproto.DroppedStream
end

defmodule Logproto.SeriesRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :start, 1, type: Google.Protobuf.Timestamp, deprecated: false
  field :end, 2, type: Google.Protobuf.Timestamp, deprecated: false
  field :groups, 3, repeated: true, type: :string
  field :shards, 4, repeated: true, type: :string, deprecated: false
end

defmodule Logproto.SeriesResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :series, 1, repeated: true, type: Logproto.SeriesIdentifier, deprecated: false
end

defmodule Logproto.SeriesIdentifier.LabelsEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Logproto.SeriesIdentifier do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :labels, 1, repeated: true, type: Logproto.SeriesIdentifier.LabelsEntry, map: true
end

defmodule Logproto.DroppedStream do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :from, 1, type: Google.Protobuf.Timestamp, deprecated: false
  field :to, 2, type: Google.Protobuf.Timestamp, deprecated: false
  field :labels, 3, type: :string
end

defmodule Logproto.TimeSeriesChunk do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :from_ingester_id, 1, type: :string, json_name: "fromIngesterId"
  field :user_id, 2, type: :string, json_name: "userId"
  field :labels, 3, repeated: true, type: Logproto.LabelPair
  field :chunks, 4, repeated: true, type: Logproto.Chunk
end

defmodule Logproto.LabelPair do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string
  field :value, 2, type: :string
end

defmodule Logproto.LegacyLabelPair do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :bytes
  field :value, 2, type: :bytes
end

defmodule Logproto.Chunk do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :data, 1, type: :bytes
end

defmodule Logproto.TransferChunksResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3
end

defmodule Logproto.TailersCountRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3
end

defmodule Logproto.TailersCountResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :count, 1, type: :uint32
end

defmodule Logproto.GetChunkIDsRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :matchers, 1, type: :string
  field :start, 2, type: Google.Protobuf.Timestamp, deprecated: false
  field :end, 3, type: Google.Protobuf.Timestamp, deprecated: false
end

defmodule Logproto.GetChunkIDsResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :chunkIDs, 1, repeated: true, type: :string
end

defmodule Logproto.ChunkRef do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :fingerprint, 1, type: :uint64, deprecated: false
  field :user_id, 2, type: :string, json_name: "userId", deprecated: false
  field :from, 3, type: :int64, deprecated: false
  field :through, 4, type: :int64, deprecated: false
  field :checksum, 5, type: :uint32, deprecated: false
end

defmodule Logproto.LabelValuesForMetricNameRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :metric_name, 1, type: :string, json_name: "metricName"
  field :label_name, 2, type: :string, json_name: "labelName"
  field :from, 3, type: :int64, deprecated: false
  field :through, 4, type: :int64, deprecated: false
  field :matchers, 5, type: :string
end

defmodule Logproto.LabelNamesForMetricNameRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :metric_name, 1, type: :string, json_name: "metricName"
  field :from, 2, type: :int64, deprecated: false
  field :through, 3, type: :int64, deprecated: false
end

defmodule Logproto.GetChunkRefRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :from, 1, type: :int64, deprecated: false
  field :through, 2, type: :int64, deprecated: false
  field :matchers, 3, type: :string
end

defmodule Logproto.GetChunkRefResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :refs, 1, repeated: true, type: Logproto.ChunkRef
end

defmodule Logproto.GetSeriesRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :from, 1, type: :int64, deprecated: false
  field :through, 2, type: :int64, deprecated: false
  field :matchers, 3, type: :string
end

defmodule Logproto.GetSeriesResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :series, 1, repeated: true, type: Logproto.IndexSeries, deprecated: false
end

defmodule Logproto.IndexSeries do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :labels, 1, repeated: true, type: Logproto.LabelPair, deprecated: false
end

defmodule Logproto.QueryIndexResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :QueryKey, 1, type: :string
  field :rows, 2, repeated: true, type: Logproto.Row
end

defmodule Logproto.Row do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :rangeValue, 1, type: :bytes
  field :value, 2, type: :bytes
end

defmodule Logproto.QueryIndexRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :Queries, 1, repeated: true, type: Logproto.IndexQuery
end

defmodule Logproto.IndexQuery do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :tableName, 1, type: :string
  field :hashValue, 2, type: :string
  field :rangeValuePrefix, 3, type: :bytes
  field :rangeValueStart, 4, type: :bytes
  field :valueEqual, 5, type: :bytes
end

defmodule Logproto.IndexStatsRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :from, 1, type: :int64, deprecated: false
  field :through, 2, type: :int64, deprecated: false
  field :matchers, 3, type: :string
end

defmodule Logproto.IndexStatsResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :streams, 1, type: :uint64, deprecated: false
  field :chunks, 2, type: :uint64, deprecated: false
  field :bytes, 3, type: :uint64, deprecated: false
  field :entries, 4, type: :uint64, deprecated: false
end