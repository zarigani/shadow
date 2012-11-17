shadow
======

これは影の領域の大きさを変更するコマンドです。


This is command controling shadow size.


![sample.png](https://dl.dropbox.com/u/2281410/images/sample.png)


![sample-shadow.png](https://dl.dropbox.com/u/2281410/images/sample-shadow.png)


![sample-shadow-b4.png](https://dl.dropbox.com/u/2281410/images/sample-shadow-b4.png)


![sample-shadow-b2.png](https://dl.dropbox.com/u/2281410/images/sample-shadow-b2.png)


![sample-shadow-b0-a0.png](https://dl.dropbox.com/u/2281410/images/sample-shadow-b0-a0.png)


![sample-shadow-b56-a0.8.png](https://dl.dropbox.com/u/2281410/images/sample-shadow-b56-a0.8.png)


利用環境
-------

* OSX 10.6以上

インストール
----------

* command/shadowを/usr/local/bin/shadowへ、インストールすることをお勧めします。(Please move to `/usr/local/bin/shadow`)

使い方
-----

````
Usage: dropshadow [-a ALPAH_VALUE(0-1)] [-b BLUR_RADIUS(0<=)] [-owh] [FILE ...]
  -o  Without outline.
  -w  Rewrite original file.
  -h  Help.

Example:
  shadow test.png              ->  Default shadow(= shadow -a0.5 -b8 test.png)
  shadow -b4 test.png          ->  Nano shadow
  shadow -b2 test.png          ->  Line shadow
  shadow -b0 -a0 test.png      ->  None shadow
  shadow -b56 -a0.75 test.png  ->  OS X shadow
````

* -a `ALPAH_VALUE`    `ALPAH_VALUE`は、影の透明度（0から1までの少数値、デフォルト=0.5）
* -b `BLUR_RADIUS`    `BLUR_RADIUS`は、影のぼけ具合（0以上の整数値、デフォルト=8）
* -o                  輪郭なし
* -w                  同じ画像ファイルに上書きする
* -h                  このヘルプを表示する
