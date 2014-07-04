assets-deps:
  npm.bootstrap:
    - name: /vagrant
    - user: vagrant
    - require:
      - pkg: nodejs
  gem.installed:
    - names:
      - sass
