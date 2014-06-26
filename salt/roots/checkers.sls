checkers:
  npm.installed:
    - names:
      - coffeedoc
      - coffeelint
      - csslint
    - require:
      - pkg: nodejs
  gem.installed:
    - names:
      - scss-lint
    - require:
      - pkg: ruby1.9.3
