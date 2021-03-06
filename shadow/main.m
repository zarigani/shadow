//
//  main.m
//  shadow
//
//  Created by zarigani on 2012/11/15.
//  Copyright (c) 2012年 bebe工房. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern float const BBKAlphaLimit;
float const BBKAlphaLimit = 0.95;
extern float const BBKRateLimit;
float const BBKRateLimit = 8.0;

// ディスプレイスケールを取得する  // NSLog(@"scale = %f", scale);  //例 Retina scale = 2.000000
CGFloat displayScale()
{
    // http://stackoverflow.com/questions/11344076/how-to-get-nsscreen-backingscalefactor-on-cocoa-targeting-10-6
    // building for the OS X 10.7 SDK, with the deployment target set to 10.6.
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
        return [ [NSScreen mainScreen] backingScaleFactor];
    }else{
        return 1.0;
    }
}

// 指定した値より透明なピクセルを透明度0（透過率100%）にした画像を返す
//      setColorは処理が遅い、よって巨大な画像では時間がかかる
NSImage* transparentImageByAlphaValue(NSImage* image)
{
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    NSColor *color;
    CGFloat r,g,b,a;
    for (int y=0; y<imageRep.pixelsHigh; y++) {
        for (int x=0; x<imageRep.pixelsWide; x++) {
            color = [imageRep colorAtX:x y:y];
            [color getRed:&r green:&g blue:&b alpha:&a];
            if (a < BBKAlphaLimit) {
//                NSLog(@"(%i, %i) %f %f %f %f", x, y,a, r, g, b);
                // alpha:0.0よりも、alpha:a*rよりも、alpha:a*r*g*bの方が、アンチエイリアスが残って秀逸
//                color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a*r*g*b];
                color = [NSColor colorWithCalibratedRed:r/a green:g/a blue:b/a alpha:a*r*g*b];
                [imageRep setColor:color atX:x y:y];
            }
        }
    }
    CGImageRef cgimage = [imageRep CGImage];
    NSImage *transparentImage = [[NSImage alloc] initWithCGImage:cgimage size:NSZeroSize];
    return transparentImage;
}

// 左側の境界座標を返す
NSInteger trimLeft(NSBitmapImageRep *imageRep)
{
    for (int x=0; x<imageRep.pixelsWide; x++) {
        for (int y=0; y<imageRep.pixelsHigh; y++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return x;
        }
    }
    return 0;
}

// 右側の境界座標を返す
NSInteger trimRight(NSBitmapImageRep *imageRep)
{
    for (NSInteger x=imageRep.pixelsWide; x>=0; x--) {
        for (NSInteger y=0; y<imageRep.pixelsHigh; y++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return (x + 1);
        }
    }
    return 0;
}

// 上側の境界座標を返す
NSInteger trimTop(NSBitmapImageRep *imageRep)
{
    for (NSInteger y=0; y<imageRep.pixelsHigh; y++) {
        for (NSInteger x=0; x<imageRep.pixelsWide; x++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return (imageRep.pixelsHigh - y);
        }
    }
    return 0;
}

// 下側の境界座標を返す
NSInteger trimBottom(NSBitmapImageRep *imageRep)
{
    for (NSInteger y=imageRep.pixelsHigh; y>=0; y--) {
        for (NSInteger x=0; x<imageRep.pixelsWide; x++) {
            NSColor *color = [imageRep colorAtX:x y:y];
            if ([color alphaComponent] >= BBKAlphaLimit) return (imageRep.pixelsHigh - y - 1);
        }
    }
    return 0;
}

// 指定した透明度以上の領域を含む最小のrectを返す
NSRect trimRectFromImageByAlphaValue(NSImage *image)
{
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation] ];
    CGFloat scale = displayScale();
    
    NSRect trimRect = NSZeroRect;
    trimRect.origin.x = (float)trimLeft(imageRep)/scale;
    trimRect.origin.y = (float)trimBottom(imageRep)/scale;
    trimRect.size.width = (float)trimRight(imageRep)/scale - trimRect.origin.x;
    trimRect.size.height = (float)trimTop(imageRep)/scale - trimRect.origin.y;
    
//    NSLog(@"%f, %f, %f, %f", trimRect.origin.x, trimRect.origin.y, trimRect.size.width, trimRect.size.height);
    return trimRect;
}

// 指定した範囲に画像を切り取って返す
NSImage* trimImageByRect(NSImage *image, NSRect trimRect)
{
    CGFloat scale = displayScale();
    //Retina環境に応じたポイントサイズを取得する
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation] ];
    NSSize pointSize = NSMakeSize(imageRep.pixelsWide/scale, imageRep.pixelsHigh/scale);
    //解像度を統一する（画像によって72dpiと144dpiの2つの設定があるので）
    [image setSize:pointSize];
    //描画する場所を準備
    NSRect newRect = NSZeroRect;
    newRect.size = trimRect.size;
    NSImage *newImage = [ [NSImage alloc] initWithSize:newRect.size];
    //描画する場所=newImageに狙いを定める、描画環境を保存しておく
    [newImage lockFocus];
    [NSGraphicsContext saveGraphicsState];
    //拡大・縮小した時の補間品質の指定
    [ [NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    //描画する
    [image drawAtPoint:NSZeroPoint fromRect:trimRect operation:NSCompositeSourceOver fraction:1.0];
    //描画環境を元に戻す、描画する場所=newImageから狙いを外す
    [NSGraphicsContext restoreGraphicsState];
    [newImage unlockFocus];
    
    return newImage;
}

NSSize resizeWidth(NSSize aSize, float pxRate)
{
    if (pxRate > BBKRateLimit) {
        return NSMakeSize(pxRate, roundf(aSize.height * pxRate / aSize.width));
    }else{
        return NSMakeSize(roundf(aSize.width * pxRate), roundf(aSize.height * pxRate));
    }
}

NSSize resizeHeight(NSSize aSize, float pxRate)
{
    if (pxRate > BBKRateLimit) {
        return NSMakeSize(roundf(aSize.width * pxRate / aSize.height), pxRate);
    }else{
        return NSMakeSize(roundf(aSize.width * pxRate), roundf(aSize.height * pxRate));
    }
}

NSSize resize(NSSize aSize, float pxRate, NSString *zoomOpt)
{
    if (zoomOpt == @"W") return resizeWidth(aSize, pxRate);
    if (zoomOpt == @"H") return resizeHeight(aSize, pxRate);
    if (aSize.width > aSize.height) {
        return resizeWidth(aSize, pxRate);
    }else{
        return resizeHeight(aSize, pxRate);
    }
}

// イメージを拡大・縮小して返す
NSImage* zoomImage(NSImage *image, float blurRadius, float pxRate, NSString *zoomOpt)
{
    float margin = blurRadius;
    CGFloat scale = displayScale();
    //Retina環境に応じたポイントサイズを取得する
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    NSSize pixelSize = NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh);
    NSSize inSize;
    if (pxRate > BBKRateLimit && pxRate >= pixelSize.width + margin*2 && pxRate >= pixelSize.height + margin*2) {
        inSize = pixelSize;
    }else if (pxRate > BBKRateLimit) {
        inSize = resize(pixelSize, pxRate - margin*scale*2, zoomOpt);
    }else{
        inSize = resize(pixelSize, pxRate, zoomOpt);
    }
    
    //描画する場所を準備
    NSImage *newImage = [[NSImage alloc] initWithSize:resize(inSize, 1/scale, zoomOpt)];
    //描画する場所=newImageに狙いを定める、描画環境を保存しておく
    [newImage lockFocus];
    [NSGraphicsContext saveGraphicsState];
    //拡大・縮小した時の補間品質の指定
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    //描画する
    NSRect drawRect = {NSZeroPoint, resize(inSize, 1/scale, zoomOpt)};
    //[image drawAtPoint:drawRect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    //drawAtPointでは、画像によっては解像度に2倍の差が出てしまうため、drawInRectで描画した
    [imageRep drawInRect:drawRect
             fromRect:NSZeroRect
            operation:NSCompositeCopy
             fraction:1.0
       respectFlipped:YES
                hints:nil];
    
    //描画環境を元に戻す、描画する場所=newImageから狙いを外す
    [NSGraphicsContext restoreGraphicsState];
    [newImage unlockFocus];
    
    return newImage;
}


// 影付きイメージを描画して返す
NSImage* dropshadowImage(NSImage *image, float blurRadius, float alphaValue, bool outline)
{
    float margin = blurRadius;
    CGFloat scale = displayScale();
    //Retina環境に応じたポイントサイズを取得する
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    NSSize pointSize = NSMakeSize(imageRep.pixelsWide/scale, imageRep.pixelsHigh/scale);
    //描画する場所を準備
    NSRect newRect = NSZeroRect;
    newRect.size.width = pointSize.width + margin*2;
    newRect.size.height = pointSize.height + margin*2;
    NSImage *newImage = [[NSImage alloc] initWithSize:newRect.size];
    //描画する場所=newImageに狙いを定める、描画環境を保存しておく
    [newImage lockFocus];
    [NSGraphicsContext saveGraphicsState];
    //拡大・縮小した時の補間品質の指定
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    NSRect drawRect;
    drawRect.origin = NSMakePoint(margin, roundf(margin*1.25));
    drawRect.size = pointSize;
    if (outline) {
        //影の設定（輪郭線のため）
        [shadow setShadowOffset:NSZeroSize];
        [shadow setShadowBlurRadius:1.0];
        [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:alphaValue]];
        [shadow set];
        //描画する（輪郭線のため）
        //[image drawAtPoint:drawRect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        //drawAtPointでは、画像によっては解像度に2倍の差が出てしまうため、drawInRectで描画した
        [image drawInRect:drawRect
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1.0
           respectFlipped:YES
                    hints:nil];
    }
    //影の設定
    [shadow setShadowOffset:NSMakeSize(0.0, -blurRadius * 0.25)];
    [shadow setShadowBlurRadius:blurRadius];
    [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:alphaValue]];
    [shadow set];
    //描画する
    //[image drawAtPoint:drawRect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    //drawAtPointでは、画像によっては解像度に2倍の差が出てしまうため、drawInRectで描画した
    [image drawInRect:drawRect
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0
       respectFlipped:YES
                hints:nil];
    
    //描画環境を元に戻す、描画する場所=newImageから狙いを外す
    [NSGraphicsContext restoreGraphicsState];
    [newImage unlockFocus];
    
    return newImage;
}

// PNGファイルとして保存する
void saveImageByPNG(NSImage *image, NSString* fileName)
{
    NSData *data = [image TIFFRepresentation];
    NSBitmapImageRep* bitmapImageRep = [NSBitmapImageRep imageRepWithData:data];
    NSDictionary* properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                           forKey:NSImageInterlaced];
    data = [bitmapImageRep representationUsingType:NSPNGFileType properties:properties];
    [data writeToFile:fileName atomically:YES];
}

void showUsage()
{
    printf("\n");
    printf("Usage: shadow [-a ALPAH_VALUE] [-b BLUR_RADIUS] [-s SUFFIX] [-z PXorRATE] [-owh] [FILE ...]\n");
    printf("  -a ALPAH_VALUE    Shadow opacity (0 <= ALPAH_VALUE <= 1, Default: 0.5).\n");
    printf("  -b BLUR_RADIUS    Shadow blur (0 <= BLUR_RADIUS, Default: 8.0).\n");
    printf("  -s 'SUFFIX'       Add suffix.\n");
    printf("  -z PXorRATE       Zoom output size (0 <= PXorRATE, Default: 1.0).\n");
    printf("  -W                'Wz900' resample width to 900px. It may expand.\n");
    printf("  -H                'Hz900' resample Height to 900px. It may expand.\n");
    printf("  -o                Without outline.\n");
    printf("  -w                Rewrite original file.\n");
    printf("  -h                Help.\n");
    printf("\n");
    printf("Example:\n");
    printf("  shadow test.png             ->  Default shadow(= shadow -a0.5 -b8 test.png)\n");
    printf("  shadow -b4 test.png         ->  Nano shadow\n");
    printf("  shadow -b2 test.png         ->  Line shadow\n");
    printf("  shadow -b0 -a0 test.png     ->  None shadow\n");
    printf("  shadow -b56 -a0.8 test.png  ->  OS X shadow\n");
    printf("  shadow test.png -s '-nano'  ->  Output file name is 'test-nano.png'.\n");
    printf("  shadow test.png -w          ->  Original 'test.png' is over written.\n");
    printf("  shadow -z 500 test.png      ->  Limit maximum size to 500px.\n");
    printf("  shadow -z 0.7 test.png      ->  Zoom size to 0.7 times.\n");
}




int main(int argc, char * argv[])
{
    
    @autoreleasepool {
        int opt, i;
        float blurRadius = 8.0; // -b
        float alphaValue = 0.5; // -a
        float zoomPxRate = 1;   // -z
        bool outline = YES;     // -o
        bool rewrite = NO;      // -w
        NSString *suffix = @""; // -s
        NSString *zoomOpt = @"";// -WH
        NSString *optText = @"-shadow";
        
        //opterr = 0;/* エラーメッセージを非表示にする */
        
        while((opt = getopt(argc, argv, "a:b:WHz:s:owh")) != -1){
            optText = [optText stringByAppendingString:[NSString stringWithFormat:@"-%c%s", opt, optarg ? optarg : ""]];
            switch(opt){
                case 'a':
                    sscanf(optarg, "%f", &alphaValue);
                    break;
                case 'b':
                    sscanf(optarg, "%f", &blurRadius);
                    break;
                case 'z':
                    sscanf(optarg, "%f", &zoomPxRate);
                    break;
                case 's':
                    suffix = [NSString stringWithUTF8String:optarg];
                    break;
                case 'W':
                    zoomOpt = @"W";
                    break;
                case 'H':
                    zoomOpt = @"H";
                    break;
                case 'o':
                    outline = NO;
                    break;
                case 'w':
                    rewrite = YES;
                    break;
                case 'h':
                    showUsage();
                    return 0;
                
                // 解析できないオプションが見つかった場合は「?」を返す
                // オプション引数が不足している場合も「?」を返す
                case '?':
                    showUsage();
                    return 1;
            }
        }
        
        for(i = optind; i < argc; i++){
            // ファイルパスをパースしておく
//            NSString *aPath = @"~/a/b/c.d.e";
            NSString *aPath = [NSString stringWithUTF8String:argv[i]];
            NSString *fPath = [aPath stringByStandardizingPath];        // /Users/HOME/a/b/c.d.e
//          NSString *fDir = [fPath stringByDeletingLastPathComponent]; // /Users/HOME/a/b
//          NSString *fNameExt = [fPath lastPathComponent];             // c.d.e
            NSString *fExt = [fPath pathExtension];                     // e
            NSString *fDirName = [fPath stringByDeletingPathExtension]; // /Users/HOME/a/b/c.d
//            NSLog(@"name.ext=%@  ext=%@  dir=%@  dir/name=%@", fNameExt, fExt, fDir, fDirName);
            NSString *outputPath;
            if (rewrite) {
                outputPath = fPath;
            }else{
                outputPath = [NSString stringWithFormat:@"%@%@.%@", fDirName, (suffix==@"")?optText:suffix, fExt];
            }
            
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:fPath];
            NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
            NSRect trimRect = trimRectFromImageByAlphaValue(image);
            if (!NSEqualRects(trimRect, imageRect)) {
                // 影の領域を削除した画像にする
                image = trimImageByRect(image, trimRect);
                // 影の部分を透明にする
                image = transparentImageByAlphaValue(image);
            }
            // イメージを拡大・縮小する
            image = zoomImage(image, blurRadius, zoomPxRate, zoomOpt);
            // 影付きイメージを生成する
            image = dropshadowImage(image, blurRadius, alphaValue, outline);
            // PNG画像として保存する
            saveImageByPNG(image, outputPath);
            // 変換した画像のファイルパスを出力する
            puts([outputPath UTF8String]);
        }        
    }
    return 0;
}
