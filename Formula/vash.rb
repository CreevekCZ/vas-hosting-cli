class Vash < Formula
  desc "CLI controller for vas-hosting.cz hosting API"
  homepage "https://github.com/jankoznarek/vas-hosting-cli"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jankoznarek/vas-hosting-cli/releases/download/v#{version}/vash-v#{version}-macos-arm64.tar.gz"
      sha256 "REPLACE_WITH_ARM64_SHA256"
    else
      url "https://github.com/jankoznarek/vas-hosting-cli/releases/download/v#{version}/vash-v#{version}-macos-x86_64.tar.gz"
      sha256 "REPLACE_WITH_X86_64_SHA256"
    end
  end

  on_linux do
    url "https://github.com/jankoznarek/vas-hosting-cli/releases/download/v#{version}/vash-v#{version}-linux-x86_64.tar.gz"
    sha256 "REPLACE_WITH_LINUX_SHA256"
  end

  def install
    bin.install "vash"
  end

  test do
    assert_match "vas-hosting.cz", shell_output("#{bin}/vash --help")
  end
end
