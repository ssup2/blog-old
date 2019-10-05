---
title: slabtop
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

Slab 사용량을 출력하는 slabtop의 사용법을 정리한다.

### 1. slabtop

#### 1.1. # slabtop (-s o)

{% highlight console %}
 Active / Total Objects (% used)    : 3108938 / 3354154 (92.7%)
 Active / Total Slabs (% used)      : 118963 / 118963 (100.0%)
 Active / Total Caches (% used)     : 86 / 124 (69.4%)
 Active / Total Size (% used)       : 892011.17K / 929895.83K (95.9%)
 Minimum / Average / Maximum Object : 0.01K / 0.28K / 8.00K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
703560 518344   0%    0.10K  18040       39     72160K buffer_head
590793 560567   0%    0.19K  28133       21    112532K dentry
533970 529404   0%    0.04K   5235      102     20940K ext4_extent_status
461160 456150   0%    1.06K  30744       15    491904K ext4_inode_cache
274200 272799   0%    0.13K   9140       30     36560K kernfs_node_cache
213952 212839   0%    0.06K   3343       64     13372K kmalloc-64
113610 111480   0%    0.09K   2705       42     10820K kmalloc-96
 86744  80971   0%    0.57K   6196       14     49568K radix_tree_node
 77454  76476   0%    0.59K   5958       13     47664K inode_cache
 52480  51713   0%    0.12K   1640       32      6560K kmalloc-128
 49408  48879   0%    0.03K    386      128      1544K kmalloc-32
 20736  20736 100%    0.02K     81      256       324K kmalloc-16
 20096  17863   0%    0.06K    314       64      1256K pid
 18636  18316   0%    0.66K   1553       12     12424K proc_inode_cache
 14122  14122 100%    0.67K    614       23      9824K ovl_inode
 11172  10774   0%    0.20K    588       19      2352K vm_area_struct
 10626  10304   0%    0.09K    231       46       924K anon_vma
  9456   8372   0%    0.25K    591       16      2364K filp
  8740   8740 100%    0.81K    460       19      7360K fuse_inode
  8192   8192 100%    0.01K     16      512        64K kmalloc-8
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] slabtop</figcaption>
</figure>

Slab Object가 많은 순서대로 Slab 사용량을 출력한다. [Shell 1]은 "slabtop"을 이용하여 Slab Object가 많은 순서대로 Slab 사용량을 출력한다. [Shell 1]에서 각 열을 아래의 의미를 나타낸다.

* OBJS : 전체 Slab Object의 개수를 나타낸다.
* ACTIVE : Active 상태의 Slab Object의 개수를 나타낸다.
* USE : Cache 이용률을 나타낸다.
* OBJ SIZE : Slab Object의 개수를 나타낸다.
* SLABS : Slab의 개수를 나타낸다.
* OBJ/SLAB : Slab당 Slab Object의 개수를 나타낸다.
* CACHE SIZE : Cache의 크기를 나타낸다.
* NAME : Slab의 이름을 나타낸다.

Cache는 다수의 Slab의 집합으로 구성되고, 각 Slab은 Slab Object의 집합으로 구성된다. 각 Slab은 Page Size 크기를 갖는다. 일반적으로 Page Size는 4KB이기 때문에 아래와 같은 공식이 성립한다.

* 4KB * SLABS = CACHE SIZE
* OBJ/SLAB * OBJ SIZE < 4KB

#### 1.2. # slabtop [-s a|b|c|l|v|n|p|s|u ]

특정 기준에 맞게 정렬하여 Slab 사용량을 출력한다. 기준은 아래와 같다.
* a : ACTIVE
* b : OBJ/SLAB
* c : CACHE SIZE
* l : SLABS
* v : Active Slab의 개수
* n : NAME
* p : Page당 Slab의 개수
* s : OBJ SIZE
* u : USE

### 2. 참고

* [http://books.gigatux.nl/mirror/kerneldevelopment/0672327201/ch11lev1sec6.html](http://books.gigatux.nl/mirror/kerneldevelopment/0672327201/ch11lev1sec6.html)
* [https://lascrea.tistory.com/66](https://lascrea.tistory.com/66)
