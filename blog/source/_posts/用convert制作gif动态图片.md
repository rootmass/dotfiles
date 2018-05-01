---
title: Convert制作gif动态图片
date: 2017-03-27 00:34:58
tags:
---

Create an animated GIF on linux with `convert`

```
// 把当前目录下的所有bmp文件合成一个gif图片动画, 每帧间隔0ms, 重复播放.
//      -delay n     迟延n*10毫秒
//      -loop  n     播放n轮, 0表示不断地重复播放
$ convert -delay 0 *.input.jpg -loop 0 out.gif

// So to create an animation we use the convert command
$ convert -delay 50 frame1.gif frame1.gif frame1.gif -loop 0 out.gif

// Also if we want to add a pause between each loop
$ convert -delay 50 frame1.gif -delay 100 frame1.gif -delay 150 frame1.gif -loop 0 -pause 200 out.gif

// Also using convert we can combine 2 animated gifs
$ convert anim1.gif anim2.gif out.gif

Enjoy!
Bookmark/Search this post with

// 把图片放缩为640x480
$ mogrify -resize 640x480 *.jpg
```

