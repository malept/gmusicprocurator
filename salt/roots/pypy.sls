{% if grains['os'] == 'Ubuntu' %}
pypy.ppa:
  pkgrepo.managed:
    - humanname: PyPy PPA
    - name: deb http://ppa.launchpad.net/pypy/ppa/ubuntu precise main
    - dist: precise
    - file: /etc/apt/sources.list.d/pypy.list
    - keyid: "68854915"
    - keyserver: keyserver.ubuntu.com
    - require_in:
      pkg: pypy-dev
{% endif %}

pypy-dev:
  pkg.installed
