1) I forked meta-sca on github

2) add upstream

cd meta-sca

git remote add official-upstream git://github.com/priv-kweihmann/meta-sca

git fetch official-upstream

git branch -a

3) use specific upstream branch/commit and make own branch

syntax: git fetch url-to-repo branchname:refs/remotes/origin/branchname

# I think like this we get the latest and greatest upstream master:

git fetch git://github.com/priv-kweihmann/meta-sca master:refs/remotes/official-upstream/master

4) Update from upstream
git co master
>> git remote -v

official-upstream       git://github.com/priv-kweihmann/meta-sca (fetch)
official-upstream       git://github.com/priv-kweihmann/meta-sca (push)
origin  git@github.com:RobertBerger/meta-sca.git (fetch)
origin  git@github.com:RobertBerger/meta-sca.git (push)

>> git fetch official-upstream
---

5) My own branch:
git co master
git co official-upstream/master
git checkout -b 2019-09-09-warrior-2.7+
git co master
cd my-scripts
./push-all-to-github.sh

6) apply patches

cd meta-virtualization

git co 2019-09-10-sca-v1.16-warrior-2.7

stg init

stg series

stg import --mail ../meta-sca-patches/2019-09-10-sca-v1.16-warrior-2.7/0001-use-systemd-as-cgroup-manager-for-docker-While-it-s-.patch

import all patches

...

stg series 

stg commit --all

git log

git co master

7) push to my upstream

my-scripts/push-all-to-github.sh

