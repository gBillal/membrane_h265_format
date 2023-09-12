defmodule Membrane.H265 do
  @moduledoc """
  This module provides format definition for H265 video stream
  """

  @typedoc """
  Width of single frame in pixels.

  Allowed values may be restricted by used encoding parameters, for example, when using
  4:2:0 chroma subsampling dimensions must be divisible by 2.
  """
  @type width_t :: pos_integer()

  @typedoc """
  Height of single frame in pixels.

  Allowed values may be restricted by used encoding parameters, for example, when using
  4:2:0 chroma subsampling dimensions must be divisible by 2.
  """
  @type height_t :: pos_integer()

  @typedoc """
  Number of frames per second. To avoid using floating point numbers,
  it is described by 2 integers number of frames per timeframe in seconds.

  For example, NTSC's framerate of ~29.97 fps is represented by `{30_000, 1001}`
  If the information about the framerate is not present in the stream, `nil` value
  should be used.
  """
  @type framerate_t :: {frames :: pos_integer(), seconds :: pos_integer()} | nil

  @typedoc """
  Describes whether and how buffers are aligned.

  `:au` means each buffer contains one Access Unit - all the NAL units required to decode
  a single frame of video

  `:nalu` aligned stream ensures that no NAL unit is split between buffers, but it is possible that
  NALUs required for one frame are in different buffers
  """
  @type alignment_t :: :au | :nalu

  @typedoc """
  When alignment is set to `:au`, determines whether buffers have NALu info attached in metadata.

  If true, each buffer contains the NAL units list under `metadata.h265.nalus`. The list consists of
  maps with the following entries:
  - `prefixed_poslen: {pos, len}` - position and length of the NALu within the payload
  - `unprefixed_poslen: {pos, len}` - as above, but omits Annex B prefix
  - `metadata: metadata` - metadata that would be merged into the buffer metadata
    if `alignment` was `:nal`.
  """
  @type nalu_in_metadata_t :: boolean()

  @typedoc """
  Describes H265 stream structure.

  Annex B (ITU-T H.265 Recommendation)
  is suitable for writing to file or streaming with MPEG-TS.
  In this format each NAL unit is prefixed by three or four-byte start code (`0x(00)000001`)
  that allows to identify boundaries between them.

  hvc1 and hev1 are described by ISO/IEC 14496-15. In such stream a DCR (Decoder Configuration
  Record) is included out-of-band and NALUs lack the start codes, but are prefixed with their length.
  The length of these prefixes is contained in the stream's DCR. HEVC streams are more suitable for
  placing in containers (e.g. they are used by QuickTime (.mov), MP4, Matroska and FLV).
  In hvc1 streams PPSs, SPSs and VPSs (Picture Parameter Sets, Sequence Parameter Sets and Video Parameter Sets respectively)
  are transported in the DCR, when in hev1 they may be also present in the stream (in-band).
  """
  @type stream_structure :: :annexb | {:hvc1 | :hev1, dcr :: binary()}

  @typedoc """
  Profiles defining constraints for encoders and requirements from decoders decoding such stream
  """
  @type profile_t ::
          :main
          | :main_10
          | :main_still_picture
          | :rext

  @typedoc """
  Format definition for H265 video stream.
  """
  @type t :: %__MODULE__{
          width: width_t(),
          height: height_t(),
          framerate: framerate_t(),
          alignment: alignment_t(),
          nalu_in_metadata?: nalu_in_metadata_t(),
          profile: profile_t(),
          stream_structure: stream_structure()
        }

  defstruct width: nil,
            height: nil,
            profile: nil,
            alignment: :au,
            nalu_in_metadata?: false,
            framerate: nil,
            stream_structure: :annexb

  @doc """
  Checks if stream structure is :avc1 or :avc3
  """
  defguard is_hvc(stream_structure)
           when tuple_size(stream_structure) == 2 and elem(stream_structure, 0) in [:hvc1, :hev1]
end
