[Dock]et
========
Simple wrapper around [`dockutil`] to easily configure your [Dock] with a
`dock`[`et`]`.`[`y`\[`a`\]`ml`] or [`.json`] file located in the current directory, else globally in [`$XDG_CONFIG_HOME`]`/dock`[`et`]`.y`[`a`]`ml` or `~/.dock`[`et`]`.y`[`a`]`ml`.

Install
-------
~~~ sh
brew tap danielbayley/docket https://github.com/danielbayley/docket
brew install docket
~~~
or with [`brew bundle`] using a _[Brewfile]_:
~~~ rb
# Brewfile
repo = "danielbayley/docket"
tap repo, "https://github.com/#{repo}"
brew "docket"
~~~

License
-------
[MIT] © [Daniel Bayley]

[MIT]:                LICENSE.md
[Daniel Bayley]:      https://github.com/danielbayley

[`dockutil`]:         https://github.com/kcrawford/dockutil
[dock]:               https://support.apple.com/guide/mac-help/mh35859/mac

[`y`\[`a`\]`ml`]:     https://yaml.org
[`.json`]:            https://json.org

[homebrew]:           https://brew.sh
[`brew bundle`]:      https://docs.brew.sh/Manpage#bundle-subcommand
[brewfile]:           https://github.com/Homebrew/homebrew-bundle#usage

[`$XDG_CONFIG_HOME`]: https://wiki.archlinux.org/title/XDG_Base_Directory#Specification
