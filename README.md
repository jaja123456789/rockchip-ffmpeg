FFmpeg README
=============

# Intention of this repository

In this repository I maintain the [rockchip linux ffmpeg project](https://github.com/rockchip-linux/ffmpeg) ,
which implements the hardware encoding and decoding features for rockchip SoCs and merge them with
changes from the [ffmpeg github repository](https://github.com/ffmpeg/ffmpeg) .

## Compile it on rockchip

[compile_ffmpeg_rockchip.sh](compile_ffmpeg_rockchip.sh) is a tutorial for how you get the dependencies for ffmpeg and rockchip
and how I compile the dependencies and ffmpeg. I do not cross-compile ffmpeg, so it takes some time. ~1 hour for the dependencies and ffmpeg
with `ccache` enabled. I put two links in the script for setting up ccache. The first time for compiling everything will take longer.

### Preparation

- Set the `FFMPEG_COMPILE_DIR` variable to the destination where all sources and built files will be placed.

	Note! Everytime you open a new shell, you have to set all environment variables again!

- Install yasm and nasm as instructed in the tutorial.

Configure ffmpeg with the options, codecs etc. you need in the `PATH="$FFMPEG_BIN:$PATH" ./configure` part.

### Compilation

- You have to export all environment variables. See the part `## Define environment variables` in [compile_ffmpeg_rockchip.sh](compile_ffmpeg_rockchip.sh).
- Execute all commands
	- Every command, which is not needed, is commented
	- Compile scripts are placed in blocks. You can recognize them by the backslashes at the end of a line `\`.
	That means, you can copy the complete block.

At the end of each compile block you mostly find a `tail` command, which opens a file, where the log of the compile process is written to the console output.
That's because the commands are run in the background, which you can recognize by the single `&` before the backslash at the end of the line
and the following `disown` command.
So you can let it run in the background and have no fear, that the SSH connection interrupts.
The logs are written with a timestamp and the command name (e.g. `-make-` `-cmake`) to the `_SOURCES` directory of each project.
For example: `${MPP_SOURCES}/log-cmake-2019-09-02_01:00:48.txt`


### My system, where I compile ffmpeg

## Software

- [Debian stretch minial from ayufan](https://github.com/ayufan-rock64/linux-build/releases)
- [nasm](https://www.nasm.us/) from the current debian ARM64 sources. The needed version is not in the stretch repositories of ARM64.
So we get it from a newer debian version.
The tutorial contains installation constructions for a working version.
- [yasm](http://yasm.tortall.net/) from the current debian ARM64 sources. The needed version is not in the stretch repositories of ARM64.
So we get it from a newer debian version.
The tutorial contains installation constructions for a working version.

## Hardware

- [ROCK64](https://www.pine64.org/devices/single-board-computers/rock64/)
- [RK3328](http://opensource.rock-chips.com/wiki_RK3328)

### Additional information

There are a few steps in the tutorial, such as the `make install` steps, for which I think, that you don't need them, but for me
it worked only with them. Maybe there are some misconfigurations in the system.

Report me, if there are unneeded steps, errors or if you need more information to get it run.

I will celebrate it, when the [rockchip MPP API](https://trac.ffmpeg.org/wiki/HWAccelIntro)
is fully implemented (that means the encoder) in the original ffmpeg project.

# Original ffmpeg README

FFmpeg is a collection of libraries and tools to process multimedia content
such as audio, video, subtitles and related metadata.

## Libraries

* `libavcodec` provides implementation of a wider range of codecs.
* `libavformat` implements streaming protocols, container formats and basic I/O access.
* `libavutil` includes hashers, decompressors and miscellaneous utility functions.
* `libavfilter` provides a mean to alter decoded Audio and Video through chain of filters.
* `libavdevice` provides an abstraction to access capture and playback devices.
* `libswresample` implements audio mixing and resampling routines.
* `libswscale` implements color conversion and scaling routines.

## Tools

* [ffmpeg](https://ffmpeg.org/ffmpeg.html) is a command line toolbox to
  manipulate, convert and stream multimedia content.
* [ffplay](https://ffmpeg.org/ffplay.html) is a minimalistic multimedia player.
* [ffprobe](https://ffmpeg.org/ffprobe.html) is a simple analysis tool to inspect
  multimedia content.
* Additional small tools such as `aviocat`, `ismindex` and `qt-faststart`.

## Documentation

The offline documentation is available in the **doc/** directory.

The online documentation is available in the main [website](https://ffmpeg.org)
and in the [wiki](https://trac.ffmpeg.org).

### Examples

Coding examples are available in the **doc/examples** directory.

## License

FFmpeg codebase is mainly LGPL-licensed with optional components licensed under
GPL. Please refer to the LICENSE file for detailed information.

## Contributing

Patches should be submitted to the ffmpeg-devel mailing list using
`git format-patch` or `git send-email`. Github pull requests should be
avoided because they are not part of our review process and will be ignored.
