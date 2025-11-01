# Stashsphere Documentation

This repository provides a nix flake that builds and serves the
project documentation of *stashsphere* that is written in markdown
and generated as HTML by the mkdocs tool.

## Usage

To view the checked-out version, clone the repository and from inside, run:

```sh
nix develop
mkdocs serve
```

Build the html pages for hosting.

```sh
# local checkout
nix build .#html
```

## License

- Content: CC-BY-SA 4.0 (see LICENSE)
- Nix Code: MIT

## Credits

- @tfc for writing the mkdocs+nix template at
  [https://github.com/tfc/mkdocs-plantuml-c4](https://github.com/tfc/mkdocs-plantuml-c4)
  (MIT License)
