# Ruby Object Mapper

ROM is an experimental ruby ORM.

## Status

[![Gem Version](https://badge.fury.io/rb/rom.png)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/rom-rb/rom.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/rom-rb/rom/badge.png?branch=master)][coveralls]
[![Inline docs](http://inch-ci.org/github/rom-rb/rom.png)][inchpages]

[gem]: https://rubygems.org/gems/rom
[travis]: https://travis-ci.org/rom-rb/rom
[gemnasium]: https://gemnasium.com/rom-rb/rom
[codeclimate]: https://codeclimate.com/github/rom-rb/rom
[coveralls]: https://coveralls.io/r/rom-rb/rom
[inchpages]: http://inch-ci.org/github/rom-rb/rom/

Project is being rebuilt from scratch. Watch this space.

## ROADMAP

The interface will be very similar to previous versions. The biggest
change is using Sequel for RDBMS and adding a new RA in-memory layer for
combining data in-memory.

Here's a top-level TODO:

* Add adapter interface
* Add sequel adapter
* Add redis adapter (just to prove that stuff works with different adapters)
* Add a couple of RA operations
* Rebuild relation and mapper definition DSL
* Release 0.3.0 \o/

## Community

* [![Gitter chat](https://badges.gitter.im/rom-rb/chat.png)](https://gitter.im/rom-rb/chat)
* [Ruby Object Mapper](https://groups.google.com/forum/#!forum/rom-rb) mailing list

## License

See `LICENSE` file.
