#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ~/perl5/perlbrew/etc/bashrc
cd $DIR
echo "doing cpanm --installdeps on $DIR"
cd $DIR/schema; sqitch deploy -t $1
cd $DIR;
cpanm -n Module::Install::Catalyst App::Sqitch App::ForkProve
cpanm -n --installdeps .
TRACE=1 forkprove -MTupa::Web::App -j 1 -lvr t/

