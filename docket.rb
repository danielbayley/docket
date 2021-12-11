class Docket < Formula
  desc "Simple wrapper around dockutil to easily configure your Dock"
  homepage "https://github.com/danielbayley/docket"
  url "#{homepage}/trunk", using: :svn
  version "latest"
  license "MIT"

  depends_on "dockutil"

  def install
    token = name.demodulize.downcase
    (bin/token).write "#!/bin/zsh\n#{HOMEBREW_BREW_FILE} #{token} $@"
    doc.install Dir["*.md"]
  end

  test do
    assert_match desc, shell_output(bin/"#{name.demodulize.downcase} --help")
  end
end
