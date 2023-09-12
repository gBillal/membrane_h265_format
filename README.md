# Membrane Multimedia Framework: H265 video format

This package provides H265 video format definition (so-called caps) for the [Membrane Multimedia Framework](https://membraneframework.org/)


## Installation

Unless you're developing a Membrane Element it's unlikely that you need to use this package directly in your app, as normally it is going to be fetched as a dependency of any element that operates on H265 video stream.

However, if you are developing an Element or need to add it due to any other reason, just add the following line to your `deps` in the `mix.exs` and run mix `deps.get`.

```elixir
def deps do
  [
    {:membrane_h265_format, "~> 0.2.0"}
  ]
end
```