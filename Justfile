doc:
    vimcats -t -f -c -a \
    lua/dotmd/init.lua \
    lua/dotmd/config.lua \
    lua/dotmd/types.lua \
    > doc/dotmd.nvim.txt

set shell := ["bash", "-cu"]

fmt-check:
    stylua --config-path=.stylua.toml --check lua

fmt:
    stylua --config-path=.stylua.toml lua

test:
    @echo "Running tests in headless Neovim using test_init.lua..."
    nvim -l tests/minit.lua --minitest
