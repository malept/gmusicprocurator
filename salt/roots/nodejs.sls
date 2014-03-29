{% if grains['os'] == 'Ubuntu' %}
nodejs.ppa:
  pkgrepo.managed:
    - humanname: node.js PPA
    - name: deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu precise main
    - dist: precise
    - file: /etc/apt/sources.list.d/nodejs.list
    - keyid: "C7917B12"
    - keyserver: keyserver.ubuntu.com
    - require_in:
      pkg: nodejs
{% endif %}

nodejs:
  pkg.installed
