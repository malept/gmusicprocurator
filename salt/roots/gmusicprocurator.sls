/home/vagrant/.config/gmusicapi:
  file.directory:
    - user: vagrant
    - group: vagrant
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
