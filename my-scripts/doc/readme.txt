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

official-upstream       git://git.yoctoproject.org/meta-virtualization (fetch)
official-upstream       git://git.yoctoproject.org/meta-virtualization (push)
origin  git@github.com:RobertBerger/meta-virtualization.git (fetch)
origin  git@github.com:RobertBerger/meta-virtualization.git (push)

>> git fetch official-upstream
remote: Counting objects: 4043, done.
remote: Compressing objects: 100% (1273/1273), done.
remote: Total 4043 (delta 3130), reused 3632 (delta 2727)
Receiving objects: 100% (4043/4043), 721.50 KiB | 402.00 KiB/s, done.
Resolving deltas: 100% (3130/3130), completed with 502 local objects.
From git://git.yoctoproject.org/meta-virtualization
   62591d9..e758547  master     -> official-upstream/master
 + 2942327...a382678 master-next -> official-upstream/master-next  (forced update)
   a3fa5ce..6a1f33c  morty      -> official-upstream/morty
---

7) My own branch:
git co master
git co official-upstream/warrior
git checkout -b 2019-09-09-warrior-2.7+
git co master
cd my-scripts
./push-all-to-github.sh

8) apply patches

cd meta-virtualization

git co 2019-09-09-warrior-2.7+ 

stg init

stg series

stg import --mail ../meta-virtualization-patches/2019-09-09-warrior-2.7+/0001-use-systemd-as-cgroup-manager-for-docker-While-it-s-.patch

import all patches

...

stg series 

stg commit --all

git log

git co master

9) push to my upstream

my-scripts/push-all-to-github.sh

