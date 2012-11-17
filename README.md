shadow
======


これは影（透明度・大きさ・輪郭）の調整をするコマンドです。

（This is a command to control the shadow(Transparency, Size, Outline).）


<table>
<tr>
<td><img src="https://dl.dropbox.com/u/2281410/images/sample.png" width=267 /></td>
<td>OSX Screenshot</td>
<td>Shadow is too big!</td>
</tr>

<tr>
<td align="center"><img src="https://dl.dropbox.com/u/2281410/images/sample-shadow.png" width=139 /></td>
<td>shadow sample.png</td>
<td>Default shadow</td>
</tr>

<tr>
<td align="center"><img src="https://dl.dropbox.com/u/2281410/images/sample-shadow-b4.png" width=131 /></td>
<td>shadow -b4 sample.png</td>
<td>Nano shadow</td>
</tr>

<tr>
<td align="center"><img src="https://dl.dropbox.com/u/2281410/images/sample-shadow-b2.png" width=127 /></td>
<td>shadow -b2 sample.png</td>
<td>Line shadow</td>
</tr>

<tr>
<td align="center"><img src="https://dl.dropbox.com/u/2281410/images/sample-shadow-b0-a0.png" width=123 />
<td align="center">shadow -b0 -a0 sample.png</td>
<td>None shadow</td>
</tr>
</table>


利用環境
-------

* OSX 10.6以上


インストール
----------

* command/shadow を /usr/local/bin/shadow へ、インストールすることをお勧めします。
* （Please move to `/usr/local/bin/shadow`）


使い方
-----

````
Usage: dropshadow [-a ALPAH_VALUE(0-1)] [-b BLUR_RADIUS(0<=)] [-owh] [FILE ...]
  -o  Without outline.
  -w  Rewrite original file.
  -h  Help.

Example:
  shadow test.png             ->  Default shadow(= shadow -a0.5 -b8 test.png)
  shadow -b4 test.png         ->  Nano shadow
  shadow -b2 test.png         ->  Line shadow
  shadow -b0 -a0 test.png     ->  None shadow
  shadow -b56 -a0.8 test.png  ->  OS X shadow
````

* -a `ALPAH_VALUE`    `ALPAH_VALUE`は、影の透明度（0から1までの少数値、デフォルト=0.5）
* -b `BLUR_RADIUS`    `BLUR_RADIUS`は、影のぼけ具合（0以上の整数値、デフォルト=8）
* -o                  輪郭なし
* -w                  同じ画像ファイルに上書きする
* -h                  このヘルプを表示する
