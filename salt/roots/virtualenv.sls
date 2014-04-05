requirements-deps:
  pkg.installed:
    - names:
      - python-dev
      - git
      - mercurial

python-virtualenv:
  pkg.installed

/vagrant/requirements.txt:
  file.exists

/home/vagrant/.virtualenv:
  virtualenv.managed:
    # The following directive fixes relative dirs for requirements*.txt for some reason
    - no_chown: True
    - requirements: /vagrant/requirements/dev.txt
    - watch:
      - file: /vagrant/requirements.txt
{%- if grains['os'] != 'Ubuntu' %}{# requires pip >= 1.4 #}
    - use_wheel: True
{%- endif %}
    - user: vagrant
    - require:
      - pkg: python-virtualenv
      - pkg: requirements-deps
