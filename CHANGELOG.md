# Changelog

## [1.4.3](https://github.com/y3owk1n/dotmd.nvim/compare/v1.4.2...v1.4.3) (2025-07-20)


### Bug Fixes

* **docs:** switch doc gen from `pandocvim` to `vimcats` ([#69](https://github.com/y3owk1n/dotmd.nvim/issues/69)) ([c9cbdcb](https://github.com/y3owk1n/dotmd.nvim/commit/c9cbdcba1916a19c3ebce1e13ecf02d271766d52))
* remove whitespaces ([#71](https://github.com/y3owk1n/dotmd.nvim/issues/71)) ([5f9c84f](https://github.com/y3owk1n/dotmd.nvim/commit/5f9c84f1abfdf47024ccedc9c497762d811a25b1))

## [1.4.2](https://github.com/y3owk1n/dotmd.nvim/compare/v1.4.1...v1.4.2) (2025-04-16)


### Bug Fixes

* **commands.navigate:** respect `default_split` settings when using `navigate` ([#64](https://github.com/y3owk1n/dotmd.nvim/issues/64)) ([f51e4e2](https://github.com/y3owk1n/dotmd.nvim/commit/f51e4e2be6b10f5e5702c4427a8ee2ecbba8e23e))
* **config:** add completions for all user commands ([#67](https://github.com/y3owk1n/dotmd.nvim/issues/67)) ([0979255](https://github.com/y3owk1n/dotmd.nvim/commit/0979255d8561534aa7c2fac2fe580e0a5157c94e))
* **floating-win:** add reminder to `:wq` for floating footer ([#66](https://github.com/y3owk1n/dotmd.nvim/issues/66)) ([4a7583b](https://github.com/y3owk1n/dotmd.nvim/commit/4a7583b39c54b50eb35ff66d7e7a4eaf0181e803))
* **utils.get_files_recursive:** ignore if the directory does not exists instead of error-ing out ([#68](https://github.com/y3owk1n/dotmd.nvim/issues/68)) ([570ed8e](https://github.com/y3owk1n/dotmd.nvim/commit/570ed8e300611985bc7742f2cb44a13e67d5d796))
* **utils.open_file:** add `float` split with `snacks.win` detection ([#60](https://github.com/y3owk1n/dotmd.nvim/issues/60)) ([a2b6e59](https://github.com/y3owk1n/dotmd.nvim/commit/a2b6e59a312681e45962b5fdad5427efa6694d9f))
* **utils.open_file:** improve `float` behaviour to not opening float on top of each other ([#63](https://github.com/y3owk1n/dotmd.nvim/issues/63)) ([6572f6c](https://github.com/y3owk1n/dotmd.nvim/commit/6572f6cfc5add0dcbe13f592fc139a929d568371))

## [1.4.1](https://github.com/y3owk1n/dotmd.nvim/compare/v1.4.0...v1.4.1) (2025-04-13)


### Bug Fixes

* **commands.create_todo_today:** support rollover for multiple headings with configuration ([#57](https://github.com/y3owk1n/dotmd.nvim/issues/57)) ([dee260d](https://github.com/y3owk1n/dotmd.nvim/commit/dee260d96215b14235714218e44666f74fd02b83))

## [1.4.0](https://github.com/y3owk1n/dotmd.nvim/compare/v1.3.0...v1.4.0) (2025-04-13)


### Features

* **commands.pick:** add mini.pick support ([#51](https://github.com/y3owk1n/dotmd.nvim/issues/51)) ([c9bfd99](https://github.com/y3owk1n/dotmd.nvim/commit/c9bfd9913709f034d78f79f1f45399ada43cd046))
* **config:** disable `rollover` by default and add configurable `rollover.heading` ([#54](https://github.com/y3owk1n/dotmd.nvim/issues/54)) ([a687f2d](https://github.com/y3owk1n/dotmd.nvim/commit/a687f2d678ab4cd89fed65fc1e9c6b0f4a493a90))


### Bug Fixes

* **health:** better healthcheck for detecting pickers dependency ([#56](https://github.com/y3owk1n/dotmd.nvim/issues/56)) ([7568622](https://github.com/y3owk1n/dotmd.nvim/commit/7568622d33f9c708d8d90e33e47941ac44793664))

## [1.3.0](https://github.com/y3owk1n/dotmd.nvim/compare/v1.2.0...v1.3.0) (2025-04-12)


### Features

* **config:** pluralise config for keys `notes`, `todos`, `journals` ([#46](https://github.com/y3owk1n/dotmd.nvim/issues/46)) ([b3d64f0](https://github.com/y3owk1n/dotmd.nvim/commit/b3d64f091ab2a33aad0decfd55704cb327e989c4))


### Bug Fixes

* add trimming to note creation input ([#49](https://github.com/y3owk1n/dotmd.nvim/issues/49)) ([c7980cf](https://github.com/y3owk1n/dotmd.nvim/commit/c7980cf8304313a6f046ad9cfc3d2f4c2de97647))

## [1.2.0](https://github.com/y3owk1n/dotmd.nvim/compare/v1.1.0...v1.2.0) (2025-04-12)


### Features

* **commands.open:** add ability to `pluralised` the query ([#41](https://github.com/y3owk1n/dotmd.nvim/issues/41)) ([a6ddbaf](https://github.com/y3owk1n/dotmd.nvim/commit/a6ddbaf54c3ae90e383f1d2d73d8dda94d1c11ea))
* **commands.picker:** add `snacks`, `telescope` and `fzf-lua` picker ([#42](https://github.com/y3owk1n/dotmd.nvim/issues/42)) ([3a12efb](https://github.com/y3owk1n/dotmd.nvim/commit/3a12efb691a73999637c7d27d2507779b46243bc))
* **commands:** add `open` command ([#40](https://github.com/y3owk1n/dotmd.nvim/issues/40)) ([9ecf56f](https://github.com/y3owk1n/dotmd.nvim/commit/9ecf56f9fd3a9ed4d6e62f74c8adde607d5d59bd))


### Bug Fixes

* **commands.picker:** add checks for `allowed_pickers` to avoid hard error ([#43](https://github.com/y3owk1n/dotmd.nvim/issues/43)) ([b902a2e](https://github.com/y3owk1n/dotmd.nvim/commit/b902a2e3c82471efd20123bd510f62e04e7767e6))
* **commands.picker:** make the type to default to `all` instead of `notes` ([#45](https://github.com/y3owk1n/dotmd.nvim/issues/45)) ([82e9572](https://github.com/y3owk1n/dotmd.nvim/commit/82e95724762a0c90ad27892f3162711d8301b119))
* **commands.pick:** refactor select logic into utility functions ([#39](https://github.com/y3owk1n/dotmd.nvim/issues/39)) ([8e77063](https://github.com/y3owk1n/dotmd.nvim/commit/8e77063741071e625506c92b99b654e6c797da36))
* **directories.get_picker_dirs:** only pass the `type` to picker instead of the whole `opts` ([#38](https://github.com/y3owk1n/dotmd.nvim/issues/38)) ([f888231](https://github.com/y3owk1n/dotmd.nvim/commit/f888231a183db9dcb85c119b7446442932246d1f))
* **utils.open_file:** pass only `split` opts to `open_file` ([#36](https://github.com/y3owk1n/dotmd.nvim/issues/36)) ([6249116](https://github.com/y3owk1n/dotmd.nvim/commit/6249116f6b55135e0b8372be8f7409d464126cd6))

## [1.1.0](https://github.com/y3owk1n/dotmd.nvim/compare/v1.0.3...v1.1.0) (2025-04-11)


### Features

* **setup:** add user command with `DotMd` prefix during setup ([#29](https://github.com/y3owk1n/dotmd.nvim/issues/29)) ([4b6f4b3](https://github.com/y3owk1n/dotmd.nvim/commit/4b6f4b3df12ff2f89aedebc56e601e48b2732e10))


### Bug Fixes

* **commands:** remove `open_file` opts and always open the file ([#32](https://github.com/y3owk1n/dotmd.nvim/issues/32)) ([526f526](https://github.com/y3owk1n/dotmd.nvim/commit/526f52697f755f1694fc6ae41ad60a6ac8abc55d))
* **config:** add configurable `rollover_todo` for config ([#34](https://github.com/y3owk1n/dotmd.nvim/issues/34)) ([07f8520](https://github.com/y3owk1n/dotmd.nvim/commit/07f8520fac44d18ae909394fef823090309e0ee2))
* **utils.merge_default_create_file_opts:** remove hardcoded `vertical` for `opts.split` ([#31](https://github.com/y3owk1n/dotmd.nvim/issues/31)) ([5c8f84a](https://github.com/y3owk1n/dotmd.nvim/commit/5c8f84ac7d958214260062156de3d949994f8cfd))

## [1.0.3](https://github.com/y3owk1n/dotmd.nvim/compare/v1.0.2...v1.0.3) (2025-04-10)


### Bug Fixes

* add confirmation prompt to prevent accidental creation ([#24](https://github.com/y3owk1n/dotmd.nvim/issues/24)) ([2d313df](https://github.com/y3owk1n/dotmd.nvim/commit/2d313df5130da827fa50e4dc25c178452638553b))
* **commands.inbox:** use `get_root_dir` function instead of just expanding the rootdir ([#25](https://github.com/y3owk1n/dotmd.nvim/issues/25)) ([d34d476](https://github.com/y3owk1n/dotmd.nvim/commit/d34d47636cf403da6a99d890857d7dbc6c500aa6))
* **commands.navigate:** support `journal` and `todo` navigation automagically ([#26](https://github.com/y3owk1n/dotmd.nvim/issues/26)) ([a588dfc](https://github.com/y3owk1n/dotmd.nvim/commit/a588dfce8a3d0db4a3bfebe2405f2f0e3c5796f8))
* **directories.get_subdir:** make sure handling trailing slashes correctly ([#22](https://github.com/y3owk1n/dotmd.nvim/issues/22)) ([107861a](https://github.com/y3owk1n/dotmd.nvim/commit/107861ac0d21596d42398fdd772c07b619ef6e94))

## [1.0.2](https://github.com/y3owk1n/dotmd.nvim/compare/v1.0.1...v1.0.2) (2025-04-10)


### Bug Fixes

* **commands.create_note:** allow create/select subdirectory before creating a new note ([#20](https://github.com/y3owk1n/dotmd.nvim/issues/20)) ([2ca4aaa](https://github.com/y3owk1n/dotmd.nvim/commit/2ca4aaa0bd6da1c258968d76d0977ff48302b04f))

## [1.0.1](https://github.com/y3owk1n/dotmd.nvim/compare/v1.0.0...v1.0.1) (2025-04-10)


### Bug Fixes

* **commands.todo_navigate:** get nearest prev or next todos instead of just +/- 1 day ([#15](https://github.com/y3owk1n/dotmd.nvim/issues/15)) ([df08f58](https://github.com/y3owk1n/dotmd.nvim/commit/df08f58bf6931fd57d8fecf6d14477dbbde6614e))
* **health:** properly check the `root_dir` from config ([#19](https://github.com/y3owk1n/dotmd.nvim/issues/19)) ([15c4ded](https://github.com/y3owk1n/dotmd.nvim/commit/15c4ded2168aa933dbaf5b5ef883b460360824dc))
* **health:** remove grep checks from healthcheck ([#17](https://github.com/y3owk1n/dotmd.nvim/issues/17)) ([6b77563](https://github.com/y3owk1n/dotmd.nvim/commit/6b77563d22cdeac0812b69d633e00e036ae99246))

## 1.0.0 (2025-04-09)


### Features

* add healthcheck ([#7](https://github.com/y3owk1n/dotmd.nvim/issues/7)) ([7ce2568](https://github.com/y3owk1n/dotmd.nvim/commit/7ce25687a33bbaa1f2f388eca0df36f402e51a55))
* port code from nvim config ([#2](https://github.com/y3owk1n/dotmd.nvim/issues/2)) ([76acd25](https://github.com/y3owk1n/dotmd.nvim/commit/76acd25f26fbca622569817fb381b9d2dfe6909b))


### Bug Fixes

* add more annotations ([#6](https://github.com/y3owk1n/dotmd.nvim/issues/6)) ([60d96e3](https://github.com/y3owk1n/dotmd.nvim/commit/60d96e3f8e743c6ba8e6826c0d293a2c5ad167b5))
* **config:** set `root_dir` to "~/dotmd/ ([#13](https://github.com/y3owk1n/dotmd.nvim/issues/13)) ([c4f8d7e](https://github.com/y3owk1n/dotmd.nvim/commit/c4f8d7e796c6a09681746d33e1cc547e6e2a4cb0))
* **config:** set default_split to "none" ([#11](https://github.com/y3owk1n/dotmd.nvim/issues/11)) ([9dbe716](https://github.com/y3owk1n/dotmd.nvim/commit/9dbe716f7f7fefe1c7b5970999ef8cbd7887ce80))
