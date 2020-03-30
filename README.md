# TDAC

## Installation

To install the package, open the [Julia
REPL](https://docs.julialang.org/en/v1/stdlib/REPL/), enter the package manager
with `]`, then run the command

```
add https://github.com/Team-RADDISH/TDAC.jl.git
```

If you plan to develop the package (make changes, submit pull requests, etc), in
the package manager mode run this command

```
dev https://github.com/Team-RADDISH/TDAC.jl.git
```

This will automatically clone the repository to your local directory
`~/.julia/dev/TDAC`.

You can exit from the package manager mode by pressing `CTRL + C` or,
alternatively, the backspace key when there is no input in the prompt.

## Usage

After installing the package, you can start using the package in the Julia REPL
with

```julia
using TDAC
```

## Testing

We have a basic test suite for `TDAC.jl`.  You can run the tests by entering the
package manager mode in the Julia REPL with `]` and running the command

```
test TDAC
```

## License

The `TDAC.jl` package is licensed under the MIT "Expat" License.  This is partly
based on the [tsunami data assimilation code](https://github.com/tktmyd/tdac) by
Takuto Maeda.
