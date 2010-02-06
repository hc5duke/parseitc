Gem::Specification.new do |s|
  s.name = %q{parseitc}
  s.version = "0.1.3"
  s.date = %q{2010-02-05}
  s.authors = ["HJ Choi"]
  s.email = %q{hc5duke@gmail.com}
  s.summary = %q{Parse iTunes Connect transaction reports}
  s.homepage = %q{http://www.choibean.com/parseitc}
  s.description = %q{ParseITC (Parse iTunes Connect) provides parsing of iPhone app transaction reports from iTunes Connect.}
  s.files = [ "README.textile", "Changelog", "LICENSE", "demo.rb", "demo1.txt", "demo2.txt",
    "lib/parseitc.rb", "lib/parseitc/parser.rb", "lib/parseitc/transaction.rb",
    "spec/rcov.opts", "spec/spec.opts", "spec/spec_helper.rb", "spec/parser_spec.rb", "spec/transaction_spec.rb",
    "spec/fixtures/uploads/bad_demo1.txt", "spec/fixtures/uploads/demo1.txt", "spec/fixtures/uploads/demo2.txt"
    ]
end