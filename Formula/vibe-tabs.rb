class VibeTabs < Formula
  desc "Restore named tmux workspaces for AI coding agents on macOS"
  homepage "https://github.com/TakeOnePiece/vibe-tabs"
  url "https://github.com/TakeOnePiece/vibe-tabs/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "08eb60141e9c2d1183034ea85ce8c95c9a395daa8114e842a74147de234191b4"
  license "MIT"
  head "https://github.com/TakeOnePiece/vibe-tabs.git", branch: "main"

  depends_on "jq"
  depends_on :macos
  depends_on "ripgrep"
  depends_on "tmux"
  depends_on "yq"

  def install
    libexec.install Dir["libexec/*"]
    bin.install "bin/vibe-tab", "bin/vibe-tabs"
    pkgshare.install ".vibe-tabs.yml.example"

    app = buildpath/"Vibe Tabs.app"
    system "/usr/bin/osacompile", "-o", app, "libexec/open-vibe-tabs.applescript"
    cp "assets/applet.icns", app/"Contents/Resources/applet.icns"
    touch app
    system "/usr/bin/codesign", "--force", "--deep", "--sign", "-", app
    prefix.install app
  end

  def caveats
    <<~EOS
      Create your config from the example:
        cp "#{pkgshare}/.vibe-tabs.yml.example" "$HOME/.vibe-tabs.yml"

      Launch configured workspaces:
        vibe-tabs

      Open the macOS app, which you can then keep in the Dock:
        vibe-tabs --app
    EOS
  end

  test do
    assert_match "Usage: vibe-tab", shell_output("#{bin}/vibe-tab 2>&1", 1)
    assert_predicate prefix/"Vibe Tabs.app", :directory?
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", prefix/"Vibe Tabs.app"
  end
end
