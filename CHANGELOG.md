# Changelog

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
