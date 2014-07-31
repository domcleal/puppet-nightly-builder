#!/bin/bash -xe

ssh -o "BatchMode yes" people.redhat.com "rm public_html/puppet-nightly/*" || true

for d in facter puppet; do
  if [ -e $d ]; then
    (cd $d && git pull)
  else
    git clone https://github.com/puppetlabs/$d
  fi

  pushd $d
  [ -e pkg/srpm ] && rm -rf pkg/srpm
  rake package:bootstrap
  rake package:srpm
  scp -o "BatchMode yes" pkg/srpm/*.rpm people.redhat.com:public_html/puppet-nightly/
  for f in pkg/srpm/*.rpm; do
    copr-cli build puppet-nightly \
      http://people.redhat.com/~dcleal/puppet-nightly/$(basename $f)
  done
  popd
done
