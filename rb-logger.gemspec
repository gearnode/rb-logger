# Copyright (c) 2020 Bryan Frimin <bryan@frimin.fr>.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

Gem::Specification.new do |spec|
  spec.name          = "rb-logger"
  spec.version       = "1.0.0"
  spec.authors       = ["gearnode"]
  spec.email         = ["bryan@frimin.fr"]

  spec.summary       = "A modern logger for Ruby application"
  spec.description   = ""
  spec.homepage      = "https://git.frimin.fr/?p=rb-logger.git;a=summary"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://git.frimin.fr/?p=rb-logger.git;a=summary"
  spec.metadata["changelog_uri"] = "https://git.frimin.fr/?p=rb-logger.git;a=summary"

  spec.files = ["lib/rb-logger.rb", "lib/rb-logger/standard_logger.rb", "LICENSE.txt"]
  spec.require_paths = ["lib"]
end
