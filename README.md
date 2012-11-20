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
Usage: shadow [-a ALPAH_VALUE] [-b BLUR_RADIUS] [-s SUFFIX] [-z PXorRATE] [-owh] [FILE ...]
  -a ALPAH\_VALUE    影の不透明度 (0 <= ALPAH_VALUE <= 1, デフォルト: 0.5).
  -b BLUR\_RADIUS    影のぼけ具合 (0 <= BLUR_RADIUS, デフォルト: 8.0).
  -s 'SUFFIX'       出力画像のファイル名に付加する文字列指定する.
  -z PXorRATE       出力画像のサイズを指定する (0 <= PXorRATE, Default: 1.0).
  -o                輪郭なし.
  -w                同じ画像ファイルに上書きする.
  -h                このヘルプを表示する.

Example:
  shadow test.png             ->  Default shadow(= shadow -a0.5 -b8 test.png)
  shadow -b4 test.png         ->  Nano shadow
  shadow -b2 test.png         ->  Line shadow
  shadow -b0 -a0 test.png     ->  None shadow
  shadow -b56 -a0.8 test.png  ->  OS X shadow
  shadow test.png -s '-nano'  ->  出力画像のファイル名が'test-nano.png'になる.
  shadow test.png -w          ->  元画像の'test.png'に上書きする.
  shadow -z 500 test.png      ->  出力画像の最大サイズを500pxに制限する (Retina環境では1000px).
  shadow -z 0.7 test.png      ->  出力画像のサイズを0.7倍する.
````

````
Usage: shadow [-a ALPAH_VALUE] [-b BLUR_RADIUS] [-s SUFFIX] [-z PXorRATE] [-owh] [FILE ...]
  -a ALPAH\_VALUE    Shadow opacity (0 <= ALPAH_VALUE <= 1, Default: 0.5).
  -b BLUR\_RADIUS    Shadow blur (0 <= BLUR_RADIUS, Default: 8.0).
  -s 'SUFFIX'       Add suffix.
  -z PXorRATE       Zoom output size (0 <= PXorRATE, Default: 1.0).
  -o                Without outline.
  -w                Rewrite original file.
  -h                Help.

Example:
  shadow test.png             ->  Default shadow(= shadow -a0.5 -b8 test.png)
  shadow -b4 test.png         ->  Nano shadow
  shadow -b2 test.png         ->  Line shadow
  shadow -b0 -a0 test.png     ->  None shadow
  shadow -b56 -a0.8 test.png  ->  OS X shadow
  shadow test.png -s '-nano'  ->  Output file name is 'test-nano.png'.
  shadow test.png -w          ->  Original 'test.png' is over written.
  shadow -z 500 test.png      ->  Limit maximum size to 500px (Retina is 1000px).
  shadow -z 0.7 test.png      ->  Zoom size to 0.7 times.
````
