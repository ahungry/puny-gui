(declare-project
  :name "json"
  :author "Calvin Rose"
  :license "MIT"
  :url "https://github.com/janet-lang/json"
  :repo "git+https://github.com/janet-lang/json.git")

(declare-native
  :name "json"
  :source @["json.c"])
